import Cocoa
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var windowTracker: WindowTracker!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "burst", accessibilityDescription: "Boom")
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
        let enabling = SMAppService.mainApp.status != .enabled
        try? enabling ? SMAppService.mainApp.register() : SMAppService.mainApp.unregister()
        sender.state = enabling ? .on : .off
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        menu.items.first?.state = SMAppService.mainApp.status == .enabled ? .on : .off
    }
}
