import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var marqueeController: MarqueeController?
    var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: 90)
        
        guard let statusItem = statusItem else { return }
        marqueeController = MarqueeController(statusItem: statusItem)
        
        let menu = NSMenu()
        menu.addItem(withTitle: "Restart", action: #selector(restartApp), keyEquivalent: "")
        menu.addItem(withTitle: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q")
        statusItem.menu = menu
        
        updateStatusItem()
        
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(updateStatusItem), userInfo: nil, repeats: true)
    }
    
    @objc func updateStatusItem() {
        let songInfo = getCurrentSong()
        
        if songInfo == "Paused" || songInfo == "Spotify not running" || songInfo.hasPrefix("Error") {
            statusItem?.length = 0
            marqueeController?.updateSong(title: "", artist: "")
        } else {
            statusItem?.length = 90
            let components = songInfo.components(separatedBy: " - ")
            if components.count >= 2 {
                let title = components[0]
                let artist = components.dropFirst().joined(separator: " - ")
                marqueeController?.updateSong(title: title, artist: artist)
            } else {
                marqueeController?.updateSong(title: songInfo, artist: "")
            }
        }
    }
    
    @objc func restartApp() {
        let bundlePath = Bundle.main.bundlePath
        NSWorkspace.shared.open(URL(fileURLWithPath: bundlePath))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NSApp.terminate(nil)
        }
    }
    
    func getCurrentSong() -> String {
        let script = """
        tell application "Spotify"
            if it is running and player state is playing then
                return (name of current track) & " - " & (artist of current track)
            else if it is running then
                return "Paused"
            else
                return "Spotify not running"
            end if
        end tell
        """
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Error"
            return output
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
}