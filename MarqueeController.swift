import AppKit

class MarqueeController {
    private weak var statusItem: NSStatusItem?
    private var timer: Timer?
    private var idx = 0
    private var source = ""
    
    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
        guard let btn = statusItem.button else { return }
        if #available(macOS 10.15, *) {
            btn.font = NSFont.monospacedSystemFont(ofSize: 10, weight: .regular)
        } else {
            btn.font = NSFont(name: "Menlo", size: 10)
        }
        btn.alignment = .left
        btn.cell?.wraps = false
        btn.cell?.lineBreakMode = .byClipping
    }
    
    func updateSong(title: String, artist: String) {
        timer?.invalidate()
        idx = 0
        
        if title.isEmpty && artist.isEmpty {
            source = ""
            statusItem?.button?.title = ""
            return
        }
        
        let full = artist.isEmpty ? title : artist + " - " + title
        if full.count <= 11 {
            source = ""
            statusItem?.button?.title = full
            return
        }
        
        source = full + "     "
        tick()
        timer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    @objc func tick() {
        let arr = Array(source)
        var s = ""
        for i in 0..<11 {
            s.append(arr[(idx + i) % arr.count])
        }
        statusItem?.button?.title = s
        idx = (idx + 1) % arr.count
    }
    
    deinit { timer?.invalidate() }
}

