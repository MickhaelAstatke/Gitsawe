//
//  Handler.swift
//  SampleBufferPlayer
//
//  Created by Fekadesilassie on 2/4/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation


import AVKit
import CoreMedia
import AVFoundation
import MediaPlayer
import AVFoundation

class AudioHandler:ObservableObject, RemoteCommandHandler {
    
    static let loopControlChanged = Notification.Name("AudioHandlerLOOPControlChanged")
    static let playBackSpeedChanged = Notification.Name("AudioHandlerPlayBackSpeedChanged")
    static let resetLoopCounter = Notification.Name("AudioHandlerResetLoopCounter")
    static let setMaxLoopCounter = Notification.Name("AudioHandlerSetMaxLoopCounter")
    
    @Published var sampleBufferPlayer = SampleBufferPlayer()
    @Published var state: PlaybackState = .none;
    @Published var currentTrack: PlaylistItem?
    @Published var currentDuration: Double = 0.0
    @Published var currentTime: Double = 0.0
    
    
    // Private observers.
    private var currentOffsetObserver: NSObjectProtocol!
    private var currentItemObserver: NSObjectProtocol!
    private var playbackRateObserver: NSObjectProtocol!
    var audioSessionObserver: Any!
    var timeObserverActive = true;
    
    @Published var loop: Behavior = .norepeat
    @Published var rate: PlaybackRate = .normal
    
    private var currentLoopCount = 1;
    private var maxRepeat = 2;
    
    private var originalItems: [PlaylistItem] = []
    
    init(){
        
        self.maxRepeat = UserDefaults.standard.integer(forKey: "com.gitsawe.REPEAT_COUNT")
        if(self.maxRepeat == 0){
            self.maxRepeat = 100;
        }
        
        // Observe various notifications.
        let notificationCenter = NotificationCenter.default
        
        audioSessionObserver = notificationCenter.addObserver(forName: AVAudioSession.mediaServicesWereResetNotification,
                                                              object: nil,
                                                              queue: nil) {_ in
            self.setUpAudioSession()
        }
        
        currentOffsetObserver = notificationCenter.addObserver(forName: SampleBufferPlayer.currentOffsetDidChange,
                                                               object: sampleBufferPlayer,
                                                               queue: .main) { [unowned self] notification in

            if timeObserverActive{
                let offset = (notification.userInfo? [SampleBufferPlayer.currentOffsetKey] as? NSValue)?.timeValue.seconds
                self.updateOffsetLabel(offset)
            }
        }
        
        
        currentItemObserver = notificationCenter.addObserver(forName: SampleBufferPlayer.currentItemDidChange,
                                                             object: sampleBufferPlayer,
                                                             queue: .main) { [unowned self] _ in
            self.updateCurrentItemInfo()
        }
        
        playbackRateObserver = notificationCenter.addObserver(forName: SampleBufferPlayer.playbackRateDidChange,
                                                              object: sampleBufferPlayer,
                                                              queue: .main) { [unowned self] _ in
            self.updatePlayPauseButton()
            self.updateCurrentPlaybackInfo()
        }
        
        
        notificationCenter.addObserver(forName: SampleBufferSerializer.playbackCompleted,
                                                              object: nil,
                                                              queue: nil) {value in
            
            self.replaceAllItems()
            if self.loop == .repeatAll && self.currentLoopCount < self.maxRepeat{
                self.sampleBufferPlayer.play()
                self.currentLoopCount += 1;
                
            }
        }
        
        
        notificationCenter.addObserver(forName: AudioHandler.setMaxLoopCounter,
                                                              object: nil,
                                                              queue: nil) {value in
            self.maxRepeat = value.object as! Int;
        }
        
        
        let loopString = UserDefaults.standard.string(forKey: "com.gitsawe.LOOP")
        self.loop = Behavior(rawValue: loopString ?? "repeat.circle") ?? .norepeat
        
        
        let rateFloat = UserDefaults.standard.float(forKey: "com.gitsawe.SPEED")
        self.rate = PlaybackRate(rawValue: rateFloat) ?? .normal
        
        self.setUpAudioSession()
        
        updateOffsetLabel(0)
        updatePlayPauseButton()
        
        // Start using the Now Playing info panel.
        RemoteCommandCenter.handleRemoteCommands(using: self)
        
        // Configure the Now Playing info initially.
        updateCurrentItemInfo()
        
        notificationCenter.addObserver(forName: Notification.Name("com.gitsawe.LOAD"),
                                                              object: nil,
                                                              queue: nil) {value in
            self.currentLoopCount = 1;
            if(value.object != nil){
                self.loadPlaylist(tracks: value.object as! [AudioTrack])
            }else{
                self.loadPlaylist(tracks: [])
            }
        }

        
    }
    
    func toggleLoop(){
        self.loop = self.loop.next()
        NotificationCenter.default.post(name: AudioHandler.loopControlChanged, object: self.loop)
    }
    
    func toggleRate(){
        self.rate = self.rate.next()
        NotificationCenter.default.post(name: AudioHandler.playBackSpeedChanged, object: self.rate)
    }
    
    private func setUpAudioSession() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .longFormAudio)
        } catch {
            print("Failed to set audio session route sharing policy: \(error)")
        }
    }
    
    func loadPlaylist(tracks: [AudioTrack]){
        
        if sampleBufferPlayer.isPlaying {
            sampleBufferPlayer.pause()
        }
        
        self.currentLoopCount = 1;
        // Create placeholder items.
        
        // Note that this simplifies the next step by creating the entire array.
        // Real items replace array entries as asset loading completes,
        // which may happen in any item order.
        var newItems = tracks.map { PlaylistItem(title: $0.title, artist: $0.subtitle, artwork: $0.image) }
        
        // Start loading the durations of each of the items.
        
        // Note that loading is asynchronous, so the system uses a dispatch group to
        // detect when all item loading is complete.
        let group = DispatchGroup()
        
        for itemIndex in 0 ..< tracks.count {
            
            // Find the existing placeholder item to replace.
            let placeholder = tracks [itemIndex]
            let title = placeholder.title
            let artist = placeholder.subtitle
            let artwork = placeholder.image
            
            // Locate the asset file for this item, if possible,
            // otherwise, replace the placeholder with an error item.
            var url = placeholder.url;
            
            if((url == nil)){
                guard let newurl = Bundle.main.url(forResource: title, withExtension: "mp3") else {
                    
                    let error = NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError)
                    let item = PlaylistItem(title: title, artist: artist, error: error)
                    
                    newItems [itemIndex] = item
                    
                    continue
                }
                url = newurl;
            }
            
            if((url == nil)){
                continue;
            }
            
            // Load the asset duration for this item asynchronously.
            group.enter()
            
            let asset = AVURLAsset(url: url!)
            asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                
                var error: NSError? = nil
                let item: PlaylistItem
                
                // If the duration loads, construct a "normal" item,
                // otherwise, construct an error item.
                switch asset.statusOfValue(forKey: "duration", error: &error) {
                case .loaded:
                    item = PlaylistItem(url: url!, title: title, artist: artist, artwork: artwork, duration: asset.duration)
                    
                case .failed where error != nil:
                    item = PlaylistItem(title: title, artist: artist, error: error!)
                    
                default:
                    let error = NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError)
                    item = PlaylistItem(title: title, artist: artist, error: error)
                }
                
                // Replace the placeholder with the constructed item.
                newItems [itemIndex] = item
                
                group.leave()
            }
        }
        
        // After replacing all of the items, make the playlist available for use.
        group.notify(queue: .main) {
            self.originalItems = newItems
            self.replaceAllItems()
            
            self.state = newItems.count > 0 ? .none : .disable
            self.currentTrack = newItems.count > 0 ? newItems[0] : nil 
        }
    }
    
    func destruct(){
        self.state = .none;
        UserDefaults.standard.set(self.loop.rawValue, forKey: "com.gitsawe.LOOP")
        UserDefaults.standard.set(self.rate.rawValue, forKey: "com.gitsawe.SPEED")
    }
    
    // A helper method that updates the play/pause button state.
    private func updatePlayPauseButton() {
        if(self.currentTrack != nil){
            self.state = sampleBufferPlayer.isPlaying ? .playing : .paused
        }
    }
    
    private static let format = NSLocalizedString("%.1f", comment: "")

    // A helper method that updates the elapsed time within the current playlist item.
    private func updateOffsetLabel(_ offset: Double?) {
        
        // Otherwise, update the label and the slider position when something is playing.
        if let currentOffset = offset {
            self.currentTime = currentOffset
        }
        // Or update the label and the slider position when the player stops.
        else {
            self.currentTime = 0.0
        }
    }
    
    // A helper method that updates the current playlist item's fixed information when the item changes.
    private func updateCurrentItemInfo() {
        
        // Update the Now Playing info with the new item information.
        NowPlayingCenter.handleItemChange(item: sampleBufferPlayer.currentItem,
                                          index: sampleBufferPlayer.currentItemIndex ?? 0,
                                          count: sampleBufferPlayer.itemCount)
        // Update the item information when something is playing.
        if let currentItem = sampleBufferPlayer.currentItem {
            
            self.currentTrack = currentItem
            self.currentDuration = currentItem.duration.seconds
            updateCurrentPlaybackInfo()
        }
        
        // Or update the Now Playing info when the player stops.
        else {
            self.currentTrack = originalItems.count > 0 ? originalItems[0] : nil;
            self.currentDuration = originalItems.count > 0 ? originalItems[0].duration.seconds : 0
            self.currentTime = 0
            self.state = .none
        }
    }
    
    // A helper method that updates the Now Playing playback information.
    private func updateCurrentPlaybackInfo() {
        
        NowPlayingCenter.handlePlaybackChange(playing: sampleBufferPlayer.isPlaying,
                                              rate: sampleBufferPlayer.rate,
                                              position: sampleBufferPlayer.currentItemEndOffset?.seconds ?? 0,
                                              duration: sampleBufferPlayer.currentItem?.duration.seconds ?? 0)
    }
    
    // Performs the remote command.
    func performRemoteCommand(_ command: RemoteCommand) {
        
        switch command {
            
        case .pause:
            sampleBufferPlayer.pause()
            
        case .play:
            sampleBufferPlayer.play()
            
        case .nextTrack:
            next()
            
        case .previousTrack:
            skipToCurrentItem(offsetBy: -1)
            
        case .skipForward(let distance):
            skip(by: distance)
            
        case .skipBackward(let distance):
            skip(by: -distance)

        case .changePlaybackPosition(let offset):
            skip(to: offset)
        }
    }
    
    func togglePlayPause() {
       if sampleBufferPlayer.isPlaying {
           sampleBufferPlayer.pause()
       } else {
           sampleBufferPlayer.play()
       }
   }
    
    // A helper method that skips to a different playlist item.
    private func skipToCurrentItem(offsetBy offset: Int) {
        guard let index = sampleBufferPlayer.currentItemIndex else {return}

        let trackIndex = (index + offset + sampleBufferPlayer.itemCount) % sampleBufferPlayer.itemCount
        sampleBufferPlayer.seekToItem(at: trackIndex)
        
        NotificationCenter.default.post(name: AudioHandler.resetLoopCounter, object: 0)
    }
    
    
    func back(){
        skipToCurrentItem(offsetBy: -1)
    }
    
    func next(){
        skipToCurrentItem(offsetBy: 1)
    }
    
    // A helper method that skips to a playlist item offset, making sure to update the Now Playing info.
    func skip(to offset: TimeInterval) {
        
        sampleBufferPlayer.seekToOffset(CMTime(seconds: Double(offset), preferredTimescale: 1000))
        updateCurrentPlaybackInfo()
    }
    
    // A helper method that skips a specified distance in the current item, making sure to update the Now Playing info.
    func skip(by distance: TimeInterval) {
        
        guard let offset = sampleBufferPlayer.currentItemEndOffset else { return }
        
        sampleBufferPlayer.seekToOffset(offset + CMTime(seconds: distance, preferredTimescale: 1000))
        updateCurrentPlaybackInfo()
    }
    
    // A helper method that replaces the table view contents.
    private func replaceAllItems() {
        sampleBufferPlayer.replaceItems(with: originalItems)
    }
    
    // A helper method that replaces a single item in the table view.
    private func replaceItem(at row: Int, with newItem: PlaylistItem) {
        sampleBufferPlayer.replaceItem(at: row, with: newItem)
    }
    
    // A helper method that removes an item from the table view.
    private func removeItem(at row: Int) {
        sampleBufferPlayer.removeItem(at: row)
    }
    
    // A helper method that moves an item within the table view.
    private func moveItem(from sourceRow: Int, to destinationRow: Int) {
        sampleBufferPlayer.moveItem(at: sourceRow, to: destinationRow)
    }
    
    // A helper method that duplicates the item in the table view, placing the
    // duplicated item at the end of the playlist.
    private func duplicateItem(at row: Int) {
        let item = sampleBufferPlayer.item(at: row)
        sampleBufferPlayer.insertItem(item, at: sampleBufferPlayer.itemCount)
    }
    
}
