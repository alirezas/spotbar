import Foundation
import MediaPlayer
import Combine
import AppKit

class MusicPlayerMonitor: ObservableObject {
    @Published var currentTrack: String = ""
    
    private var timer: Timer?
    private let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        // Poll for updates every 0.5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateTrackInfo()
        }
        
        // Initial update
        updateTrackInfo()
    }
    
    @objc private func updateTrackInfo() {
        // Try MPNowPlayingInfoCenter first
        if let nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo {
            let artist = nowPlayingInfo[MPMediaItemPropertyArtist] as? String ?? "Unknown Artist"
            let title = nowPlayingInfo[MPMediaItemPropertyTitle] as? String ?? "Unknown Title"
            
            let trackString = "\(artist) - \(title)"
            
            DispatchQueue.main.async {
                self.currentTrack = trackString
            }
            return
        }
        
        // Fallback: Try Spotify via AppleScript
        if let spotifyTrack = getSpotifyTrack() {
            DispatchQueue.main.async {
                self.currentTrack = spotifyTrack
            }
            return
        }
        
        // No music playing
        DispatchQueue.main.async {
            self.currentTrack = ""
        }
    }
    
    private func getSpotifyTrack() -> String? {
        let script = """
        tell application "Spotify"
            if player state is playing then
                set artistName to artist of current track
                set trackName to name of current track
                return artistName & " - " & trackName
            end if
        end tell
        """
        
        guard let appleScript = NSAppleScript(source: script) else { return nil }
        
        var error: NSDictionary?
        let result = appleScript.executeAndReturnError(&error)
        
        if error == nil {
            return result.stringValue
        }
        
        return nil
    }
    
    deinit {
        timer?.invalidate()
    }
}
