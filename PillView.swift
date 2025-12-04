import AppKit

class PillView: NSView {
    var songTitle: String = "" {
        didSet {
            updateTextField()
        }
    }
    
    private var textField: NSTextField!
    private var scrollTimer: Timer?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Transparent pill background
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        layer?.cornerRadius = bounds.height / 2
        
        // Create text field
        textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 1000, height: bounds.height))
        textField.isEditable = false
        textField.isBordered = false
        textField.backgroundColor = .clear
        textField.textColor = .labelColor // Adapt to theme
        textField.font = NSFont.systemFont(ofSize: 12)
        textField.alignment = .left
        addSubview(textField)
    }
    
    private func updateTextField() {
        textField.stringValue = songTitle
        
        let textWidth = textField.attributedStringValue.size().width
        if textWidth > bounds.width {
            startScrolling()
        } else {
            stopScrolling()
            textField.frame.origin.x = (bounds.width - textWidth) / 2  // center
        }
    }
    
    private func startScrolling() {
        stopScrolling()
        scrollTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(scrollText), userInfo: nil, repeats: true)
    }
    
    private func stopScrolling() {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
    
    @objc private func scrollText() {
        textField.frame.origin.x -= 1
        let textWidth = textField.attributedStringValue.size().width
        if textField.frame.origin.x < -textWidth {
            textField.frame.origin.x = bounds.width
        }
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        textField.frame.size.height = newSize.height
        updateTextField()  // to recenter
    }
    
    override func mouseDown(with event: NSEvent) {
        if let appDelegate = NSApp.delegate as? AppDelegate, let menu = appDelegate.statusItem?.menu {
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: bounds.height), in: self)
        }
    }
}