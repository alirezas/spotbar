import SwiftUI
import AppKit
import Combine

class MenuBarController: ObservableObject {
    private var statusItem: NSStatusItem?
    private let musicMonitor = MusicPlayerMonitor()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupStatusBar()
        observeMusicUpdates()
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let statusItem = statusItem else { return }
        
        if let button = statusItem.button {
            button.title = ""
            button.font = NSFont.systemFont(ofSize: 13)
        }
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
        guard let statusItem = statusItem,
              let button = statusItem.button else { return }
        
        // Show nothing if no music is playing
        guard !text.isEmpty else {
            button.title = ""
            return
        }
        
        // Truncate if too long (menubar has limited space)
        let maxLength = 50
        let displayText = text.count > maxLength 
            ? String(text.prefix(maxLength - 3)) + "..."
            : text
        
        button.title = displayText
    }
}
