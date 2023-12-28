/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The `PlaylistItem` structure is a playable track as an item in a playlist.
*/

import AVFoundation

struct PlaylistItem {
    
    /// The URL of the local file that contains the track's audio.
    let url: URL!
    
    /// An error that prevents the track from playing.
    let error: Error?
    
    /// The title of the track.
    let title: String
    
    /// The artist for the track.
    let artist: String
    
    /// The duration of the audio file.
    let duration: CMTime
    
    /// The artist for the track.
    let artwork: String
    
    let script: String
    
    /// Creates a valid item.
    init(url: URL, title: String, artist: String, artwork: String, duration: CMTime) {
        self.url = url
        self.title = title
        self.artist = artist
        self.duration = duration
        self.artwork = artwork
        self.script = ""
        self.error = nil
    }
    
    /// Creates an invalid item.
    init(title: String, artist: String, error: Error) {
        self.url = nil
        self.title = title
        self.artist = artist
        self.duration = .zero
        self.artwork = ""
        self.script = ""
        self.error = error
    }
    
    /// Creates a placeholder item.
    init(title: String, artist: String, artwork: String) {
        self.url = nil
        self.title = title
        self.artist = artist
        self.duration = .zero
        self.artwork = artwork
        self.script = ""
        self.error = nil
    }
}
