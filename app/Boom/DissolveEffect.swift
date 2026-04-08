import Cocoa

@MainActor
enum DissolveEffect {
    private static var active: [NSWindow] = []
    private static let maxConcurrent = 5
    private static let texturePx = 16

    /// Pure CGImage — no NSImage conversion, known pixel size, GPU-upload friendly.
    private static let circleImage: CGImage = {
        let sz = texturePx
        let ctx = CGContext(
            data: nil, width: sz, height: sz,
            bitsPerComponent: 8, bytesPerRow: sz * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        ctx.setFillColor(.white)
        ctx.fillEllipse(in: CGRect(x: 0, y: 0, width: sz, height: sz))
        return ctx.makeImage()!
    }()

    static func show(frame: CGRect) {
        guard active.count < maxConcurrent,
              let screenH = NSScreen.screens.first?.frame.height else { return }

        let padding: CGFloat = 120
        let nsFrame = CGRect(
            x: frame.origin.x - padding,
            y: screenH - frame.origin.y - frame.height - padding,
            width: frame.width + padding * 2,
            height: frame.height + padding * 2
        )

        let window = NSWindow(
            contentRect: nsFrame, styleMask: .borderless, backing: .buffered, defer: false
        )
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        window.isReleasedWhenClosed = false

        let view = NSView(frame: NSRect(origin: .zero, size: nsFrame.size))
        view.wantsLayer = true
        window.contentView = view

        let targetScreen = NSScreen.screens.first { $0.frame.intersects(nsFrame) }
        let screenScale = targetScreen?.backingScaleFactor ?? 2
        let emitter = makeEmitter(windowSize: frame.size, viewSize: nsFrame.size, screenScale: screenScale)
        view.layer?.addSublayer(emitter)

        active.append(window)
        window.orderFrontRegardless()

        Task {
            try? await Task.sleep(for: .seconds(0.08))
            emitter.birthRate = 0
            try? await Task.sleep(for: .seconds(0.55))
            window.close()
            active.removeAll { $0 === window }
        }
    }

    private static func makeEmitter(windowSize: CGSize, viewSize: CGSize, screenScale: CGFloat) -> CAEmitterLayer {

        let emitter = CAEmitterLayer()
        emitter.frame = CGRect(origin: .zero, size: viewSize)
        emitter.contentsScale = screenScale
        emitter.emitterPosition = CGPoint(x: viewSize.width / 2, y: viewSize.height / 2)
        emitter.emitterSize = windowSize
        emitter.emitterShape = .rectangle
        emitter.emitterMode = .surface
        emitter.renderMode = .unordered  // fastest — no depth sorting needed

        let totalParticles = min(windowSize.width * windowSize.height / 60, 15000)
        let totalRate = Float(totalParticles) / 0.08

        let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        let baseW: CGFloat = isDark ? 0.21 : 0.93
        let pScale: CGFloat = 0.125

        let base = makeCell(particleScale: pScale)
        base.color = NSColor(white: baseW, alpha: 1).cgColor
        base.redRange = 0.03
        base.greenRange = 0.03
        base.blueRange = 0.03
        base.birthRate = totalRate * 0.70

        let accent = makeCell(particleScale: pScale)
        accent.color = NSColor(white: baseW, alpha: 1).cgColor
        accent.redRange = 0.1
        accent.greenRange = 0.08
        accent.blueRange = 0.1
        accent.birthRate = totalRate * 0.24

        // ~6% colorful particles: random hues, high saturation, matching brightness
        let colorBrightness: CGFloat = isDark ? 0.38 : 0.93
        let hues: [CGFloat] = [0.0, 0.15, 0.33, 0.5, 0.66, 0.83]
        let colorRate = totalRate * 0.06 / Float(hues.count)
        let colorCells = hues.map { hue -> CAEmitterCell in
            let cell = makeCell(particleScale: pScale)
            cell.color = NSColor(hue: hue, saturation: 0.7, brightness: colorBrightness, alpha: 1).cgColor
            cell.redRange = 0.08
            cell.greenRange = 0.08
            cell.blueRange = 0.08
            cell.birthRate = colorRate
            return cell
        }

        emitter.emitterCells = [base, accent] + colorCells
        return emitter
    }

    private static func makeCell(particleScale: CGFloat) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contents = circleImage
        cell.lifetime = 0.35
        cell.lifetimeRange = 0.15
        cell.velocity = 40
        cell.velocityRange = 25
        cell.emissionLongitude = .pi / 2
        cell.emissionRange = .pi / 2.5
        cell.spin = 0.5
        cell.spinRange = 1.5
        cell.scale = particleScale
        cell.scaleRange = particleScale * 0.3
        cell.scaleSpeed = -particleScale * 0.4
        cell.alphaSpeed = -2.0
        return cell
    }
}
