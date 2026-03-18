# CapsSwitch — keyboard layout converter

AutoHotkey script that converts typed text between Russian and English keyboard layouts without retyping.

## How it works

Type in wrong layout → press **CapsLock twice** → the last word gets retyped in the correct layout.

## Files

| File | Description |
|------|-------------|
| `CapsSwitch.ahk` | Base script. Run this on any machine with AutoHotkey installed. |
| `CapsSwitchEx.ahk` | Extended mode (includes CapsSwitch.ahk). Adds extra hotkeys and tray menu items. |

## Usage

**Basic:**
```
Run CapsSwitch.ahk
```

**Extended mode:**
```
Run CapsSwitchEx.ahk
```

## Hotkeys (CapsSwitch)

| Hotkey | Action |
|--------|--------|
| CapsLock × 2 | Convert last typed word to other layout |
| CapsLock (single) | Switch keyboard layout (Ctrl+Shift) |

## Requirements

- Windows
- [AutoHotkey v1](https://www.autohotkey.com/) — or use compiled `.exe`
