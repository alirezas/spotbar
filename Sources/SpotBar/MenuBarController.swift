import SwiftUI
import AppKit
import Combine

final class MenuBarMarqueeView: NSView {
    private let label: NSTextField = {
        let field = NSTextField(labelWithString: "")
        field.isEditable = false
        field.isBordered = false
        field.drawsBackground = false
        field.lineBreakMode = .byClipping
        field.cell?.truncatesLastVisibleLine = false
        field.cell?.lineBreakMode = .byClipping
        field.cell?.wraps = false
        field.cell?.isScrollable = true
        field.alignment = .left
        return field
    }()
    
    private var timer: Timer?
    private var sourceText: String = ""
    private var loopText: String = ""
    private var textWidth: CGFloat = 0
    private var offset: CGFloat = 0
    
    private let font: NSFont
    private let scrollInterval: TimeInterval = 0.035
    private let scrollStep: CGFloat = 1.25
    private let padding = "   "
    
    init(width: CGFloat, font: NSFont) {
        self.font = font
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: 22))
        wantsLayer = true
        layer?.masksToBounds = true
        
        label.font = font
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func update(text: String) {
        if text.isEmpty {
            sourceText = ""
            stop()
            label.stringValue = ""
            return
        }
        
        // Avoid resetting marquee on identical text
        guard text != sourceText else { return }
        sourceText = text
        
        loopText = text + padding
        let singleWidth = textWidth(for: loopText)
        textWidth = singleWidth
        offset = 0
        
        if singleWidth <= bounds.width {
            stop()
            label.stringValue = text
            label.sizeToFit()
            centerLabelVertically()
            label.frame.origin.x = 0
        } else {
            label.stringValue = loopText + loopText
            label.sizeToFit()
            centerLabelVertically()
            label.frame.origin.x = 0
            start()
        }
    }
    
    private func start() {
        stop()
        
        let timer = Timer(timeInterval: scrollInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }
    
    private func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func tick() {
        guard !loopText.isEmpty else { return }
        
        offset += scrollStep
        if offset >= textWidth {
            offset = 0
        }
        
        label.frame.origin.x = -offset
    }
    
    private func textWidth(for text: String) -> CGFloat {
        (text as NSString).size(withAttributes: [.font: font]).width
    }
    
    private func centerLabelVertically() {
        let labelHeight = label.frame.height
        let y = (bounds.height - labelHeight) / 2
        label.frame.origin.y = y
    }
}

class MenuBarController: ObservableObject {
    private var statusItem: NSStatusItem?
    private let musicMonitor = MusicPlayerMonitor()
    private var cancellables = Set<AnyCancellable>()
    private let statusItemWidth: CGFloat = 80
    private var marqueeView: MenuBarMarqueeView?
    
    init() {
        setupStatusBar()
        observeMusicUpdates()
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: statusItemWidth)
        
        guard let statusItem = statusItem else { return }
        
        let font = NSFont.systemFont(ofSize: 13)
        let view = MenuBarMarqueeView(width: statusItemWidth, font: font)
        marqueeView = view
        statusItem.view = view
    }
    
    private func observeMusicUpdates() {
        musicMonitor.$currentTrack
            .receive(on: DispatchQueue.main)
            .sink { [weak self] track in
                self?.updateMenuBarText(track)
            }
            .store(in: &cancellables)
    }
    
    private func updateMenuBarText(_ text: String) {
        let targetWidth: CGFloat = text.isEmpty ? 0 : statusItemWidth
        
        if let statusItem = statusItem {
            statusItem.length = targetWidth
        }
        
        if let view = marqueeView {
            view.setFrameSize(NSSize(width: targetWidth, height: view.frame.height))
            view.needsLayout = true
            view.needsDisplay = true
            view.update(text: text)
        }
    }
}
