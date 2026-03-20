import Cocoa

private struct WinInfo {
    let frame: CGRect
    let pid: pid_t
}

@MainActor
class WindowTracker {
    private var tracked: [CGWindowID: WinInfo] = [:]
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

        var current = [CGWindowID: WinInfo](minimumCapacity: list.count)
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
            current[CGWindowID(num)] = WinInfo(frame: CGRect(x: x, y: y, width: w, height: h), pid: pid_t(pid))
        }

        // Windows that appeared this cycle (new IDs not in tracked)
        let appeared = current.filter { tracked[$0.key] == nil }

        for wid in tracked.keys where current[wid] == nil {
            guard !windowExists(wid), let old = tracked[wid] else { continue }

            // Tab switch: same app gained a new window at ~same position
            let isTabSwitch = appeared.values.contains { new in
                new.pid == old.pid && overlaps(old.frame, new.frame)
            }
            if !isTabSwitch {
                DissolveEffect.show(frame: old.frame)
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

    /// True if the two frames overlap by more than half the smaller area.
    private func overlaps(_ a: CGRect, _ b: CGRect) -> Bool {
        let intersection = a.intersection(b)
        guard !intersection.isNull else { return false }
        let overlapArea = intersection.width * intersection.height
        let smallerArea = min(a.width * a.height, b.width * b.height)
        return overlapArea > smallerArea * 0.5
    }
}
