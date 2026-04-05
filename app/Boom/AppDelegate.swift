import Cocoa
import MacAppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var windowTracker: WindowTracker!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            let image = NSImage(contentsOfFile: Bundle.main.path(forResource: "boom-18x2", ofType: "png")!)!
            image.size = NSSize(width: 18, height: 18)
            image.isTemplate = true
            button.image = image
        }

        let menu = NSMenu()
        menu.delegate = self
        menu.addItem(NSMenuItem(title: "Start on Login", action: #selector(toggleLogin), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Boom", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        menu.items.first?.target = self
        statusItem.menu = menu

        windowTracker = WindowTracker()
        windowTracker.start()
    }

    @objc private func toggleLogin(_ sender: NSMenuItem) {
        LoginItem.toggle()
        sender.state = LoginItem.isEnabled ? .on : .off
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        menu.items.first?.state = LoginItem.isEnabled ? .on : .off
    }
}
