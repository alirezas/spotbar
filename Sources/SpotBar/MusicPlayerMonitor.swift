import Foundation
import Combine
import AppKit

class MusicPlayerMonitor: ObservableObject {
    @Published var currentTrack: String = ""

    private var timer: Timer?
    private let pollQueue = DispatchQueue(label: "com.dot.spotbar.poll", qos: .userInitiated)

    init() {
        startMonitoring()
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.pollQueue.async {
                self?.updateTrackInfo()
            }
        }
        pollQueue.async { [weak self] in
            self?.updateTrackInfo()
        }
    }

    private func updateTrackInfo() {
        let track = getSpotifyTrack() ?? getBrowserTrack()

        DispatchQueue.main.async {
            self.currentTrack = track ?? ""
        }
    }

    private func runAppleScript(_ source: String) -> String? {
        guard let script = NSAppleScript(source: source) else { return nil }
        var error: NSDictionary?
        let result = script.executeAndReturnError(&error)
        guard error == nil else { return nil }
        return result.stringValue
    }

    private func getSpotifyTrack() -> String? {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify"
                if player state is playing then
                    set artistName to artist of current track
                    set trackName to name of current track
                    return artistName & " - " & trackName
                end if
            end tell
        end if
        """
        return runAppleScript(script)
    }

    private func getBrowserTrack() -> String? {
        // Check Chrome for audible YouTube or SoundCloud tabs
        let script = """
        if application "Google Chrome" is running then
            tell application "Google Chrome"
                repeat with w in every window
                    repeat with t in every tab of w
                        set tabURL to URL of t
                        if tabURL contains "youtube.com/watch" or tabURL contains "music.youtube.com" or tabURL contains "soundcloud.com" then
                            try
                                if audible of t then return title of t
                            on error
                                return title of t
                            end try
                        end if
                    end repeat
                end repeat
            end tell
        end if
        """

        guard let title = runAppleScript(script) else { return nil }
        return cleanBrowserTitle(title)
    }

    private func cleanBrowserTitle(_ title: String) -> String? {
        var cleaned = title

        let suffixes = [
            " - YouTube Music",
            " - YouTube",
            " | SoundCloud",
            " on SoundCloud",
            " | Free Listening on SoundCloud",
        ]
        for suffix in suffixes {
            if cleaned.hasSuffix(suffix) {
                cleaned = String(cleaned.dropLast(suffix.count))
                break
            }
        }

        cleaned = cleaned.trimmingCharacters(in: .whitespaces)
        return cleaned.isEmpty ? nil : cleaned
    }

    deinit {
        timer?.invalidate()
    }
}
