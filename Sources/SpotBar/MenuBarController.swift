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
    private let marqueeWidth: CGFloat = 80
    private let buttonWidth: CGFloat = 20
    private var totalWidth: CGFloat { buttonWidth + marqueeWidth }
    private var marqueeView: MenuBarMarqueeView?
    private var playPauseButton: NSButton?
    private var settingsWindow: NSWindow?
    private lazy var statusMenu: NSMenu = {
        let menu = NSMenu()

        let settingsItem = NSMenuItem(
            title: "Settings…",
            action: #selector(openSettings),
            keyEquivalent: ""
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit SpotBar",
            action: #selector(quitApp),
            keyEquivalent: ""
        )
        quitItem.target = self
        menu.addItem(quitItem)
        return menu
    }()

    init() {
        setupStatusBar()
        observeMusicUpdates()
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: totalWidth)

        guard let statusItem = statusItem,
              let button = statusItem.button else { return }

        // Use sendAction for left-click instead of menu (menu would intercept button clicks)
        button.target = self
        button.action = #selector(statusBarClicked)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])

        // Play/pause button on the left
        let btn = NSButton(frame: NSRect(x: 0, y: 0, width: buttonWidth, height: 22))
        btn.bezelStyle = .inline
        btn.isBordered = false
        btn.imagePosition = .imageOnly
        btn.imageScaling = .scaleProportionallyDown
        btn.image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: "Pause")
        btn.target = self
        btn.action = #selector(playPauseTapped)
        btn.autoresizingMask = [.maxXMargin]
        playPauseButton = btn
        button.addSubview(btn)

        // Marquee view to the right of the button
        let font = NSFont.systemFont(ofSize: 13)
        let view = MenuBarMarqueeView(width: marqueeWidth, font: font)
        view.frame = NSRect(x: buttonWidth, y: 0, width: marqueeWidth, height: 22)
        view.autoresizingMask = [.width, .height]
        marqueeView = view
        button.addSubview(view)
    }

    private func observeMusicUpdates() {
        musicMonitor.$currentTrack
            .combineLatest(musicMonitor.$isPlaying)
            .removeDuplicates { $0.0 == $1.0 && $0.1 == $1.1 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] track, isPlaying in
                self?.updateMenuBar(track: track, isPlaying: isPlaying)
            }
            .store(in: &cancellables)
    }

    private func updateMenuBar(track: String, isPlaying: Bool) {
        let shouldShow = !track.isEmpty && isPlaying
        let targetWidth: CGFloat = shouldShow ? totalWidth : 0

        if let statusItem = statusItem {
            statusItem.length = targetWidth
        }

        playPauseButton?.isHidden = !shouldShow
        if shouldShow {
            let iconName = isPlaying ? "pause.fill" : "play.fill"
            let label = isPlaying ? "Pause" : "Play"
            playPauseButton?.image = NSImage(systemSymbolName: iconName, accessibilityDescription: label)
        }

        if let view = marqueeView {
            let mWidth: CGFloat = shouldShow ? marqueeWidth : 0
            view.setFrameSize(NSSize(width: mWidth, height: view.frame.height))
            view.needsLayout = true
            view.needsDisplay = true
            view.update(text: shouldShow ? track : "")
        }
    }

    @objc private func statusBarClicked() {
        guard let event = NSApp.currentEvent, event.type == .rightMouseUp else { return }
        statusItem?.menu = statusMenu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @objc private func playPauseTapped() {
        musicMonitor.togglePlayPause()
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            let hosting = NSHostingController(rootView: SettingsView())
            let window = NSWindow(contentViewController: hosting)
            window.title = "SpotBar Settings"
            window.styleMask = [.titled, .closable]
            window.isReleasedWhenClosed = false
            window.center()
            settingsWindow = window
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
