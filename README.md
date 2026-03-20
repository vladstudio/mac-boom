# Boom

A macOS menu bar app that adds a particle dissolution effect when any window closes.

When you close a window, it explodes into tiny particles that drift upward and fade away. That's it.

## Requirements

- macOS 15 (Sequoia) or later

## Install

```
git clone https://github.com/nicedoc/mac-boom.git
cd mac-boom
./build.sh
```

This builds a release binary, packages it as `Boom.app`, and installs it to `/Applications`.

No Xcode project needed — just Swift Package Manager.

## How it works

- Polls `CGWindowListCopyWindowInfo` at 30 Hz to track visible windows
- When a window disappears and is confirmed closed (not minimized/hidden), a `CAEmitterLayer` burst fires at the window's last position
- Particles are GPU-rendered — zero main-thread rendering cost
- No permissions required (no Accessibility, no Screen Recording)

## License

MIT
