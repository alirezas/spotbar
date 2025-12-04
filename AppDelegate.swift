import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var pillView: PillView?
    var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        pillView = PillView(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        statusItem?.view = pillView
        
        let menu = NSMenu()
        menu.addItem(withTitle: "Restart", action: #selector(restartApp), keyEquivalent: "")
        menu.addItem(withTitle: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q")
        statusItem?.menu = menu
        
        updateStatusItem()
        
        // Update every 5 seconds
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updateStatusItem), userInfo: nil, repeats: true)
    }
    
    @objc func updateStatusItem() {
        let songInfo = getCurrentSong()
        pillView?.songTitle = songInfo
        
        // Calculate width
        let font = NSFont.systemFont(ofSize: 12)
        let size = (songInfo as NSString).size(withAttributes: [.font: font])
        let width = min(size.width, 300) // Max width 300, no padding
        statusItem?.length = width
        pillView?.frame.size.width = width
        pillView?.needsDisplay = true
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