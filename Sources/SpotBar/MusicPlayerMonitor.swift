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

        // Check Google Chrome for audible media (e.g., YouTube)
        if let chromeVideoTitle = getChromeVideoTitle() {
            DispatchQueue.main.async {
                self.currentTrack = chromeVideoTitle
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

    private func getChromeVideoTitle() -> String? {
        let script = """
        tell application "Google Chrome"
            if application "Google Chrome" is not running then return missing value
            if (count of windows) is 0 then return missing value
            
            set targetTitle to missing value
            set jsCheck to "(() => { const media = Array.from(document.querySelectorAll('video,audio')); const playing = media.find(m => !m.paused && !m.ended && m.currentTime > 0); if (!playing) return ''; return document.title || ''; })();"
            
            repeat with w in every window
                repeat with t in every tab of w
                    -- Try JS; swallow errors so the script doesn't abort
                    set playingTitle to ""
                    try
                        set playingTitle to execute javascript jsCheck in t
                    end try
                    
                    if playingTitle is not "" then
                        set targetTitle to playingTitle
                        exit repeat
                    end if
                    
                    -- Fallback: if it's a YouTube watch tab, use the tab title
                    set tabURL to URL of t
                    if tabURL contains "youtube.com/watch" then
                        set targetTitle to title of t
                        exit repeat
                    end if
                    
                    set isAudible to false
                    try
                        set isAudible to audible of t
                    end try
                    
                    if isAudible is true then
                        set targetTitle to title of t
                        exit repeat
                    end if
                end repeat
                
                if targetTitle is not missing value then exit repeat
            end repeat
            
            return targetTitle
        end tell
        """
        
        guard let appleScript = NSAppleScript(source: script) else { return nil }
        
        var error: NSDictionary?
        let result = appleScript.executeAndReturnError(&error)
        
        if let error = error {
            // -1743 is "Not permitted to send Apple events"
            if let code = error[NSAppleScript.errorNumber] as? Int, code == -1743 {
                return "Allow Chrome automation in System Settings → Privacy & Security → Automation"
            }
            if let code = error[NSAppleScript.errorNumber] as? Int, code == 12 {
                return "Enable Chrome: View → Developer → Allow JavaScript from Apple Events"
            }
            return nil
        }
        
        if let title = result.stringValue, !title.isEmpty {
            return "Chrome - \(title)"
        }

        return nil
    }
    
    deinit {
        timer?.invalidate()
    }
}
