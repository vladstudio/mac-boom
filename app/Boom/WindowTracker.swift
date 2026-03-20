import Cocoa

@MainActor
class WindowTracker {
    private var tracked: [CGWindowID: CGRect] = [:]
    private let myPID = ProcessInfo.processInfo.processIdentifier

    func start() {
        poll()
        Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.poll() }
        }
    }

    private func poll() {
        guard let list = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID
        ) as? [[String: Any]] else { return }

        var current = [CGWindowID: CGRect](minimumCapacity: list.count)
        for info in list {
            guard let num = info[kCGWindowNumber as String] as? Int,
                  let pid = info[kCGWindowOwnerPID as String] as? Int,
                  let layer = info[kCGWindowLayer as String] as? Int,
                  layer == 0, pid_t(pid) != myPID,
                  let bounds = info[kCGWindowBounds as String] as? [String: Any],
                  let x = bounds["X"] as? Double,
                  let y = bounds["Y"] as? Double,
                  let w = bounds["Width"] as? Double,
                  let h = bounds["Height"] as? Double,
                  w >= 100, h >= 50
            else { continue }
            current[CGWindowID(num)] = CGRect(x: x, y: y, width: w, height: h)
        }

        for wid in tracked.keys where current[wid] == nil {
            if !windowExists(wid), let frame = tracked[wid] {
                DissolveEffect.show(frame: frame)
            }
        }

        tracked = current
    }

    /// O(1) check via CGWindowListCreateDescriptionFromArray instead of enumerating all windows.
    private func windowExists(_ wid: CGWindowID) -> Bool {
        guard let descs = CGWindowListCreateDescriptionFromArray(
            [NSNumber(value: wid)] as CFArray
        ) as? [[String: Any]] else {
            return false
        }
        return !descs.isEmpty
    }
}
