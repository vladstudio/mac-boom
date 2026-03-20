import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var windowTracker: WindowTracker!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "burst", accessibilityDescription: "Boom")
        }
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit Boom", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu

        windowTracker = WindowTracker()
        windowTracker.start()
    }
}
