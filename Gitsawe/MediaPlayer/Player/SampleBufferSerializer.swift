/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The `SampleBufferSerializer` class implements the player logic that executes on a serial queue.
*/

import AVFoundation

// In this sample project, the audio player implements a persistent list of tracks that a user can play multiple times.
 
// Your player might not need a persistent list of tracks. For example, a streaming player might need only a temporary
// queue of items, where you remove items from the queue as soon as their playback ends. In that case, you can ignore
// the `SampleBufferPlayer` class, and use only the `SampleBufferSerializer` class, eliminating the complexity of making
// the playlist editable.
 
// You pass `SampleBufferSerializer` a complete queue of items to play. If you want to play a different or rearranged
// queue, you must construct that queue yourself. You pass the queue to one of the following public methods of
// `SampleBufferSerializer`:
 
// • `restartQueue(with:atOffset:)` — Stops any current playback and restarts playback with the specified list of items.
 
// • `continueQueue(with:)` — Continues playback of any identical items at the start of both the playing list and the
//   specified list. It then finishes playback with nonidentical items from the specified list.
 
// In this scenario, items in the queue must each have a unique identification, so the queue actually consists of unique
// `SampleBufferItem` values that wrap (possibly nonunique) `PlaylistItem` values. To create a `SampleBufferItem` value
// from a `PlaylistItem` value, use the `sampleBufferItem(playlistItem:fromOffset:)` method of `SampleBufferSerializer`.
class SampleBufferSerializer {
    
    // Notifications for playback events.
    static let currentOffsetKey = "SampleBufferSerializerCurrentOffsetKey"

    static let currentOffsetDidChange = Notification.Name("SampleBufferSerializerCurrentOffsetDidChange")
    static let currentItemDidChange = Notification.Name("SampleBufferSerializerCurrentItemDidChange")
    static let playbackRateDidChange = Notification.Name("SampleBufferSerializerPlaybackRateDidChange")
    static let playbackCompleted = Notification.Name("SampleBufferSerializerPlaybackComplted")
    
    // Private observers.
    private var periodicTimeObserver: Any!
    private var automaticFlushObserver: NSObjectProtocol!
    
    // The serial queue on which all nonpublic methods of this class must execute.
    private let serializationQueue = DispatchQueue(label: "sample.buffer.player.serialization.queue")

    // The playback infrastructure.
    private let audioRenderer = AVSampleBufferAudioRenderer()
    private let renderSynchronizer = AVSampleBufferRenderSynchronizer()
    
    private var currentLoopCount = 1;
    private var maxRepeat = 2;
    
    // The items playing.
    // Note that the system removes items from the beginning of this array as they finish
    // playback, so that the first item is always the currently playing item.
    private var items: [SampleBufferItem] = []
    
    // The current item, if any.
    var currentItem: SampleBufferItem? {
        return items.first
    }
    
    // The index of the item in "items" that is currently providing sample buffers.
    // Note that the system can enqueue buffers "ahead" from multiple items.
    private var enqueuingIndex = 0
    
    // The playback time, relative to the synchronizer timeline, up to the start of the current item,
    // of the currently enqueued buffers.
    private var enqueuingPlaybackEndTime = CMTime.zero
    
    // The playback time offset, in the current item, of the currently enqueued buffers.
    // Note that the total of `enqueuingPlaybackEndTime + enqueuingPlaybackEndOffset` represents the
    // end time of all the currently enqueued playback, in terms of the synchronizer's timeline.
    private var enqueuingPlaybackEndOffset = CMTime.zero
    
    var loop: Behavior = .norepeat;
    
    var rate: PlaybackRate = .normal;
    
    // Creates a sample buffer serializer.
    init() {
        renderSynchronizer.addRenderer(audioRenderer)
        
        // Start generating automatic flush notifications on the serializer thread.
        automaticFlushObserver = NotificationCenter.default.addObserver(forName: .AVSampleBufferAudioRendererWasFlushedAutomatically,
                                                                        object: audioRenderer,
                                                                        queue: nil) { [unowned self] notification in
            self.serializationQueue.async {
                // If possible, restart from the point where the flush interrupts the audio.
                let restartTime = (notification.userInfo?[AVSampleBufferAudioRendererFlushTimeKey] as? NSValue)?.timeValue
                self.autoflushPlayback(restartingAt: restartTime)
            }
        }
        
        let loopString = UserDefaults.standard.string(forKey: "com.gitsawe.LOOP")
        self.loop = Behavior(rawValue: loopString ?? "repeat.circle") ?? .norepeat
        
        
        let rateFloat = UserDefaults.standard.float(forKey: "com.gitsawe.SPEED")
        self.rate = PlaybackRate(rawValue: rateFloat) ?? .normal
        
        
        self.maxRepeat = UserDefaults.standard.integer(forKey: "com.gitsawe.REPEAT_COUNT")
        if(self.maxRepeat == 0){
            self.maxRepeat = 100;
        }
        
        NotificationCenter.default.addObserver(forName: AudioHandler.loopControlChanged,
                                                              object: nil,
                                                              queue: nil) {value in
            self.loop = value.object as! Behavior
        }
        
        
        NotificationCenter.default.addObserver(forName: AudioHandler.playBackSpeedChanged,
                                                              object: nil,
                                                              queue: nil) {value in
            self.rate = value.object as! PlaybackRate
            self.updatePlaybackRate()
        }
        
        
        NotificationCenter.default.addObserver(forName: AudioHandler.resetLoopCounter,
                                                              object: nil,
                                                              queue: nil) {value in
            self.currentLoopCount = 1;
        }
        
        
        NotificationCenter.default.addObserver(forName: AudioHandler.setMaxLoopCounter,
                                                              object: nil,
                                                              queue: nil) {value in
            self.maxRepeat = value.object as! Int;
        }
        
    }
    
    func updatePlaybackRate(){
        //If playing, update speed. Other wise, on resume speed will be set
        if(renderSynchronizer.rate > 0){
            renderSynchronizer.rate = self.rate.rawValue
        }
    }
    
    // Stops playing the current item without starting any subsequent playback.
    func stopQueue() {
        serializationQueue.async {
            self.stopPlayback()
        }
    }
    
    private func stopPlayback() {
        
        printLog(component: .serializer, message: "stopped playback")
        
        // Make sure to generate rate change notifications.
        let rate = renderSynchronizer.rate
        defer { notifyPlaybackRateChanged(from: rate) }
        
        // Stop playback if something is playing.
        stopEnqueuingItems()
    }
    
    // Stops playing the current item, if any, and then starts playing the specified playback item list.
    func restartQueue(with newItems: [SampleBufferItem], atOffset offset: CMTime) {
        let newUniqueIDs = Set<UUID>(newItems.map { $0.uniqueID })
        precondition(newUniqueIDs.count == newItems.count, "SampleBufferSerializer.restartQueue cannot have duplicate items.")
        
        serializationQueue.async {
            self.restartPlayback(with: newItems, atOffset: offset)
        }
    }
    
    /// - Tag: SerializerRestart
    private func restartPlayback(with newItems: [SampleBufferItem], atOffset offset: CMTime) {
        printLog(component: .serializer, message: "restarted playback with \(newItems.count) items, offset +", at: offset)
        var elapsed = CMTime.zero
        for (index, item) in newItems.enumerated() {
            elapsed = elapsed + item.playlistItem.duration
            printLog(component: .serializer, message: "item \(index): \(item.logID) ending @", at: elapsed)
        }
        
        // Make sure to generate rate change notifications.
        let rate = renderSynchronizer.rate
        defer { notifyPlaybackRateChanged(from: rate) }
        
        // Stop playback if something is playing.
        stopEnqueuingItems()
        
        // Remember the new playback items, except items with zero duration.
        items = newItems.filter { $0.playlistItem.duration > .zero }
        items.forEach { $0.startOffset = .zero }
        
        // Prepare to play the first item, if there is one, at the original rate.
        // Note that the zero point on the synchronizer's timeline is set to match the zero
        // point on the first item, but playback will actually start at the specified offset
        // from the zero point.
        guard let firstItem = items.first else { return }
        firstItem.startOffset = offset
        
        // Reset the enqueuing state.
        enqueuingIndex = 0
        enqueuingPlaybackEndTime = .zero
        enqueuingPlaybackEndOffset = .zero
        
        // Make the first item current.
        updateCurrentPlayerItem(at: .zero)
        
        // Start providing sample buffers to the audio renderer.
        printLog(component: .serializer, message: "started enqueuing items at enqueuing#0")
        provideMediaData(for: CMTime(seconds: 0.25, preferredTimescale: 1000))
        audioRenderer.requestMediaDataWhenReady(on: serializationQueue) {
            [unowned self] in
            self.provideMediaData()
        }
        
        // Play the first item.
        renderSynchronizer.setRate(rate, time: firstItem.startOffset)
    }
    
    // Continues playing with a list of specified items, starting with the current item,
    // and preserving as much buffered content as possible.
    func continueQueue(with specifiedItems: [SampleBufferItem]) {
        
        let specifiedUniqueIDs = Set<UUID>(specifiedItems.map { $0.uniqueID })
        precondition(specifiedUniqueIDs.count == specifiedItems.count, "SampleBufferSerializer.continueQueue cannot have duplicate items.")
        
        serializationQueue.async {
            self.continuePlayback(with: specifiedItems)
        }
    }
    
    /// - Tag: SerializerContinue
    private func continuePlayback(with specifiedItems: [SampleBufferItem]) {
        
        let newItems: [SampleBufferItem]
        
        // If the first item isn't the current item, that presumably means that
        // the current item advanced since invoking `continuePlayback` on
        // the serial queue. In that case, if the current item is the second
        // specified item, drop the first current item from the list.
        if let currentItem = items.first,
            specifiedItems.count > 1,
            currentItem.uniqueID != items [0].uniqueID,
            currentItem.uniqueID == items [1].uniqueID {
            
            newItems = Array(specifiedItems [1...])
            printLog(component: .serializer, message: "continued playback dropping first of \(newItems.count) items")
        }
        
        // Otherwise, use the list as-is.
        else {
            newItems = specifiedItems
            printLog(component: .serializer, message: "continued playback with \(newItems.count) items")
        }
        
        // Count the number of items at the start of the playback item list that have enqueued buffers,
        // and are in both the old and new lists.
        var initialItemCount = 0
        var initialTime = CMTime.zero
        
        for index in 0 ..< min(items.count, newItems.count) {
            
            let item = items [index]
            guard item.uniqueID == newItems [index].uniqueID, item.isEnqueued else { break }
            
            initialItemCount += 1
            initialTime = initialTime + item.endOffset
        }
        
        // If the first item is changing there is no need to preserve any playback state,
        // so just restart playback with the new item list, at the current rate.
        guard initialItemCount > 0 else { restartPlayback(with: newItems, atOffset: .zero); return }
        
        // Flush enqueued buffers you no longer want to play, and then continue
        // in the `flush` completion handler.
        printLog(component: .serializer, message: "requested flush after \(initialItemCount) items, time @", at: initialTime)
        audioRenderer.stopRequestingMediaData()
        audioRenderer.flush(fromSourceTime: initialTime) { succeeded in
            self.serializationQueue.async {
                self.finishContinuePlayback(with: newItems, didFlush: succeeded)
            }
        }
    }
    
    // A helper method that finishes continued playback after flushing audio buffers.
    // Note that the item list may change after requesting the flush, but before
    // invoking this method, so you must recheck that playback can continue.
    private func finishContinuePlayback(with newItems: [SampleBufferItem], didFlush: Bool) {
        
        // If the flush fails, don't try to continue.
        guard didFlush else { self.restartPlayback(with: newItems, atOffset: .zero); return }
        
        // Recount the number of items at the start of the item list that have enqueued buffers,
        // and are in both the old and new item lists.
        var initialItemCount = 0
        var initialEndTime = CMTime.zero
        
        for index in 0 ..< min(items.count, newItems.count) {
            
            let item = items [index]
            guard item.uniqueID == newItems [index].uniqueID, item.isEnqueued else { break }
            
            initialItemCount += 1
            initialEndTime = initialEndTime + item.endOffset
        }
        
        // If the first item is now different, don't try to continue.
        printLog(component: .serializer, message: "flush succeeded after \(initialItemCount) items")
        guard initialItemCount > 0 else { restartPlayback(with: newItems, atOffset: .zero); return }
        
        // Discard any unwanted item sources.
        for item in self.items [initialItemCount...] {
            flushItem(item)
        }
        
        // Make a combined playback item list, consisting of in-use items from the old list,
        // plus the nonmatching items from the new list.
        self.items = Array(self.items [0 ..< initialItemCount] + newItems [initialItemCount...])
        
        // Adjust the enqueuing state to the start of the new items, if it is already
        // past the end of the old items.
        if enqueuingIndex > initialItemCount {
            enqueuingIndex = initialItemCount
            enqueuingPlaybackEndTime = initialEndTime
        }
        
        // Start providing sample buffers to the audio renderer again.
        printLog(component: .serializer, message: "restarted enqueuing items at enqueuing#\(enqueuingIndex)")
        provideMediaData(for: CMTime(seconds: 0.25, preferredTimescale: 1000))
        self.audioRenderer.requestMediaDataWhenReady(on: serializationQueue) {
            [unowned self] in
            self.provideMediaData()
        }
    }
    
    // A helper method to stop enqueuing audio buffers.
    private func stopEnqueuingItems() {
        
        // Stop playback if something is playing.
        renderSynchronizer.rate = 0
        audioRenderer.stopRequestingMediaData()
        audioRenderer.flush()
        
        // Discard any unwanted item sources.
        for item in items {
            flushItem(item)
        }
        
        // Stop generating periodic time notifications.
        if let observer = periodicTimeObserver {
            printLog(component: .serializer, message: "discarding periodic observer")
            renderSynchronizer.removeTimeObserver(observer)
            periodicTimeObserver = nil
        }
    }
    
    // A helper method that provides more sample buffers when the renderer asks for more,
    // with an optional time limit on how much data to provide.
    /// - Tag: ProvideMedia
    private func provideMediaData(for limitedTime: CMTime? = nil) {
        
        // When playback is stopped and the renderer is flushed, it may have an outstanding request
        // for data that needs a response.
        guard enqueuingIndex < items.count else {
            printLog(component: .serializer, message: "renderer requested more data at end")
            audioRenderer.stopRequestingMediaData()
            return
        }
        
        // Continue providing more media data until the renderer needs no more.
        var currentItem = items [enqueuingIndex]
        var remainingTime = limitedTime
        if let seconds = remainingTime?.seconds {
            printLog(component: .enqueuer, message: "providing \(seconds)s of data for item #\(enqueuingIndex), ID: \(currentItem.logID)")
        } else {
            printLog(component: .enqueuer, message: "providing more data for item #\(enqueuingIndex), ID: \(currentItem.logID)")
        }
        while audioRenderer.isReadyForMoreMediaData {
            
            // Stop providing data when you exceed the requested time limit.
            guard remainingTime != .invalid else { break }
            
            // Use the current sample buffer item until it runs out of media data.
            if let sampleBuffer = currentItem.nextSampleBuffer() {
                
                // Adjust the presentation time of this sample buffer from item-relative to playback-relative.
                let pts = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)
                if let time = remainingTime {
                    let duration = CMSampleBufferGetDuration(sampleBuffer)
                    remainingTime = duration >= time ? .invalid : time - duration
                }
                CMSampleBufferSetOutputPresentationTimeStamp(sampleBuffer, newValue: enqueuingPlaybackEndTime + pts)
                
                // Remember the offset of the next buffer to enqueue.
                enqueuingPlaybackEndOffset = currentItem.endOffset
                
                // Feed the sample buffer to the renderer.
                audioRenderer.enqueue(sampleBuffer)
            }
            
            // Otherwise, go to the next sample buffer item, if any.
            else{
                // Invalidate the current item source.
                currentItem.invalidateSource()
                enqueuingPlaybackEndTime = enqueuingPlaybackEndTime + currentItem.endOffset
                
                if !(loop == .repeatSingle) { // && self.currentLoopCount < self.maxRepeat){
                    enqueuingIndex += 1
                }
                
                // At the end of queuing sample buffers for the current item, establish a boundary observer
                // that fires when the item's last sample buffer plays.
                printLog(component: .serializer, message: "adding boundary observer at @", at: enqueuingPlaybackEndTime)
                let boundaryTime = enqueuingPlaybackEndTime
                let timeValue = NSValue(time: enqueuingPlaybackEndTime)
                currentItem.boundaryTimeObserver = renderSynchronizer.addBoundaryTimeObserver(forTimes: [timeValue], queue: serializationQueue) {
                    [unowned self] in
                    if loop == .repeatSingle { //} && self.currentLoopCount < self.maxRepeat{
                        self.currentLoopCount += 1;
                    }else if(items.count > 0){
                        self.currentLoopCount = 1;
                    }
                    self.updateCurrentPlayerItem(at: boundaryTime)
                }
                
                // Go to the next item, if any.
                guard enqueuingIndex < items.count else {
                    printLog(component: .serializer, message: "no more items")
                    audioRenderer.stopRequestingMediaData()
                    break
                }
                
                currentItem = items [enqueuingIndex]
                currentItem.resetSource()
            }
        }
    }
    
    // A helper method that handles the transition to a new sample buffer item, if any.
    /// - Tag: UpdateCurrent
    private func updateCurrentPlayerItem(at boundaryTime: CMTime) {
        //print("In updateCurrentPlayerItem \(boundaryTime)")
        
        // Clear any periodic time observers.
        if let observer = periodicTimeObserver {
            printLog(component: .serializer, message: "removing periodic observer")
            renderSynchronizer.removeTimeObserver(observer)
            periodicTimeObserver = nil
        }

        if enqueuingIndex > 0 {
            // Remove the item that just finished playing from the list of items,
            // and its corresponding boundary time observer.
            let item = items.removeFirst()
            flushItem(item)
            printLog(component: .serializer, message: "removing first item, ID: \(item.logID)")
            enqueuingIndex -= 1
        }
        
        // Update the player's current item.
        NotificationCenter.default.post(name: SampleBufferSerializer.currentItemDidChange, object: self)

        // Establish a periodic notification, if there is a new item.
        if items.first != nil {
            
            printLog(component: .serializer, message: "adding periodic observer")
            let periodicInterval = CMTime(seconds: 0.1, preferredTimescale: 1000)
            periodicTimeObserver = renderSynchronizer.addPeriodicTimeObserver(forInterval: periodicInterval,
                                                                              queue: .main) { [unowned self] _ in
                self.notifyTimeOffsetChanged(from: boundaryTime)
            }
        }
        
        // Otherwise, you're done so set the playback rate back to 0.
        else {
            
            let rate = renderSynchronizer.rate
            defer { notifyPlaybackRateChanged(from: rate) }
            
            renderSynchronizer.rate = 0
            NotificationCenter.default.post(name: SampleBufferSerializer.playbackCompleted, object: self)
        }
    }

    // A helper method that sends a periodic time offset update notification.
    private func notifyTimeOffsetChanged(from baseTime: CMTime) {
        
        let offset = renderSynchronizer.currentTime() - baseTime
        let userInfo = [SampleBufferSerializer.currentOffsetKey: NSValue(time: offset)]
        
        NotificationCenter.default.post(name: SampleBufferSerializer.currentOffsetDidChange, object: self, userInfo: userInfo)
    }
    
    // Sets the playback rate to 0.
    func pauseQueue() {
        serializationQueue.async {
            self.pausePlayback()
        }
    }
    
    private func pausePlayback() {
        
        // Make sure to generate rate change notifications.
        printLog(component: .serializer, message: "pausing playback")
        let rate = renderSynchronizer.rate
        guard rate != 0 else { return }
        
        defer { notifyPlaybackRateChanged(from: rate) }
        
        renderSynchronizer.rate = 0
    }
    
    // Sets the playback rate to 1.
    func resumeQueue() {
        
        serializationQueue.async {
            self.resumePlayback()
        }
    }
    
    private func resumePlayback() {
        
        // Make sure to generate rate change notifications.
        printLog(component: .serializer, message: "resuming playback")
        let rate = renderSynchronizer.rate
        guard rate == 0, !items.isEmpty else { return }
        
        defer { notifyPlaybackRateChanged(from: rate) }
        
        renderSynchronizer.rate = self.rate.rawValue
    }
    
    // A helper method that resumes playback after an automatic flush.
    private func autoflushPlayback(restartingAt sampleTime: CMTime?) {
        
        // Determine the restart time as the supplied sample time, or
        // the current synchronizer time.
        let restartTime = sampleTime ?? renderSynchronizer.currentTime()
        printLog(component: .serializer, message: "automatic flush from @", at: restartTime)
        
        // At this point `enqueuingIndex` points to the last
        // item with enqueued buffers (whether partially
        // or completely).
        
        // Step backward to point to the first item
        // that contains buffers that need to reenqueue after
        // the flush (that is, the first item with an end time that is
        // after the restart time).
        while enqueuingIndex > 0, restartTime < enqueuingPlaybackEndTime {

            // Compute the duration of the previously enqueued buffers
            // for the item at `enqueuingIndex`.
            let item = items[enqueuingIndex - 1]
            let duration = item.endOffset - item.startOffset
            
            // Step backward to the previous item.
            enqueuingIndex -= 1
            enqueuingPlaybackEndTime = enqueuingPlaybackEndTime - duration
        }
        
        // Keep items containing samples that you need to reenqueue,
        // if there are any.
        let newItems: [SampleBufferItem]
        let offset: CMTime
        
        if (0 ..< items.count).contains(enqueuingIndex) {
            
            newItems = Array(items[enqueuingIndex...])
            
            let firstItem = newItems[0]
            offset = max(min(restartTime - enqueuingPlaybackEndTime, firstItem.endOffset), firstItem.startOffset)
            printLog(component: .serializer, message: "restarting playback at ID: \(firstItem.logID), offset +", at: offset)
        }
        
        // Otherwise, there's nothing to play.
        else {
            newItems = []
            offset = .zero
            printLog(component: .serializer, message: "stopping playback")
        }
        
        // Restart playback with the new item  queue.
        restartPlayback(with: newItems, atOffset: offset)
    }
    
    // Get the playback rate.
    // Note that this method doesn't need synchronization using the serialization queue.
    var playbackRate: Float {
        return renderSynchronizer.rate
    }
    
    // A helper method that sends a rate-changed notification on the main thread.
    private func notifyPlaybackRateChanged(from oldRate: Float) {
        
        guard renderSynchronizer.rate != oldRate else { return }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: SampleBufferSerializer.playbackRateDidChange, object: self)
        }
    }
    
    // Creates a new sample buffer item from a playback list item.
    func sampleBufferItem(playlistItem: PlaylistItem, fromOffset offset: CMTime) -> SampleBufferItem {
        return SampleBufferItem(playlistItem: playlistItem, fromOffset: offset, printLog: printLog)
    }
    
    // A helper method that flushes a sample buffer item.
    private func flushItem(_ item: SampleBufferItem) {
        
        // Remove its boundary observer, if any.
        if let observer = item.boundaryTimeObserver {
            renderSynchronizer.removeTimeObserver(observer)
            printLog(component: .serializer, message: "ID: \(item.logID) removed boundary observer")
        }
        
        // Close its source file, if any.
        item.flushSource()
    }
}

// This extension to the SampleBufferSerializer class adds some useful logging methods.
extension SampleBufferSerializer {
    
    enum LogComponentType {
        
        case player, serializer, enqueuer
        
        var description: String {
            
            switch self {
            case .player:     return "sb player    "
            case .serializer: return "sb serializer"
            case .enqueuer:   return "sb enqueuer  "
            }
        }
    }
    
    /// - Tag: ControlLogging
    private static var shouldLogEnqueuerMessages = true
    
    func printLog(component: LogComponentType, message: String, at time: CMTime? = nil) {
        
        guard component != .enqueuer || SampleBufferSerializer.shouldLogEnqueuerMessages else { return }
        
        let componentString = "**** " + component.description + " ****"
        let timestamp = String(format: "  %09.4f", renderSynchronizer.currentTime().seconds)
       // print(componentString, timestamp, message + printLogTime(time))
    }
    
    private func printLogTime(_ time: CMTime?) -> String {
        guard let time = time else { return "" }
        return String(format: "%.4f", time.seconds)
    }
    
}
