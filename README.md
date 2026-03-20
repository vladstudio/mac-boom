# Boom

<img src="app-icon.png" width="128" alt="Boom icon">

A macOS menu bar app that adds a particle dissolution effect when any window closes.

When you close a window, it explodes into tiny particles that drift upward and fade away. That's it.

## Requirements

- macOS 15 (Sequoia) or later
- Xcode Command Line Tools

## Install

### From release

```bash
curl -sL https://raw.githubusercontent.com/nicedoc/mac-boom/main/install.sh | bash
```

### From source

```bash
git clone https://github.com/nicedoc/mac-boom.git
cd mac-boom
./build.sh
```

## How it works

- Polls `CGWindowListCopyWindowInfo` at 30 Hz to track visible windows
- When a window disappears and is confirmed closed (not minimized/hidden), a `CAEmitterLayer` burst fires at the window's last position
- Skips overlays, dialogs, sheets, and tab switches
- Particles are GPU-rendered — zero main-thread rendering cost
- No permissions required (no Accessibility, no Screen Recording)

## License

MIT
