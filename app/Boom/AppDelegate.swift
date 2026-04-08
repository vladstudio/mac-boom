import Cocoa
import MacAppKit

@MainActor class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var windowTracker: WindowTracker!
    private var permissionItem: NSMenuItem?
    private var permissionSeparator: NSMenuItem?
    private var permissionTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button,
           let path = Bundle.main.path(forResource: "boom-18x2", ofType: "png"),
           let image = NSImage(contentsOfFile: path) {
            image.size = NSSize(width: 18, height: 18)
            image.isTemplate = true
            button.image = image
        }

        let menu = NSMenu()
        menu.delegate = self
        menu.addItem(NSMenuItem(title: "Start on Login", action: #selector(toggleLogin), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "About Boom", action: #selector(openAbout), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Boom", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        for item in menu.items where item.action != #selector(NSApplication.terminate(_:)) {
            item.target = self
        }
        statusItem.menu = menu

        windowTracker = WindowTracker()
        ensurePermissions()
    }

    // MARK: - Permissions

    private func ensurePermissions() {
        if Permissions.isGranted(.screenRecording) {
            permissionsGranted()
        } else {
            Permissions.request(.screenRecording)
            promptPermission()
        }
    }

    private func promptPermission() {
        let menu = statusItem.menu!
        if permissionItem == nil {
            let item = NSMenuItem(title: "Grant Screen Recording Access…",
                                  action: #selector(openScreenRecordingSettings), keyEquivalent: "")
            item.target = self
            menu.insertItem(item, at: 0)
            permissionItem = item
            let sep = NSMenuItem.separator()
            menu.insertItem(sep, at: 1)
            permissionSeparator = sep
        }

        guard permissionTimer == nil else { return }
        permissionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, Permissions.isGranted(.screenRecording) else { return }
                self.permissionsGranted()
            }
        }
    }

    private func permissionsGranted() {
        permissionTimer?.invalidate()
        permissionTimer = nil
        if let item = permissionItem { statusItem.menu?.removeItem(item); permissionItem = nil }
        if let sep = permissionSeparator { statusItem.menu?.removeItem(sep); permissionSeparator = nil }
        windowTracker.start()
    }

    @objc private func openScreenRecordingSettings() {
        Permissions.openSettings(.screenRecording)
    }

    // MARK: - Menu actions

    @objc private func toggleLogin(_ sender: NSMenuItem) {
        LoginItem.toggle()
        sender.state = LoginItem.isEnabled ? .on : .off
    }

    @objc private func openAbout() {
        NSWorkspace.shared.open(URL(string: "https://apps.vlad.studio/boom")!)
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        if let loginItem = menu.items.first(where: { $0.action == #selector(toggleLogin) }) {
            loginItem.state = LoginItem.isEnabled ? .on : .off
        }
    }
}
