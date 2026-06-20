<p align="center">
  <img src="eyecandy/icon.png" width="128" height="128" alt="wuon">
</p>

<h1 align="center">wuon</h1>

<p align="center">
  <i>singing synthesizer frontend — fork of muon (eol)</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-linux%20%7C%20windows%20%7C%20macos-lightgrey">
  <img src="https://img.shields.io/badge/dart-%3E%3D3.0-blue">
  <img src="https://img.shields.io/badge/neutrino-tau_v3.2.2-ff69b4">
</p>

---

**wuon** is a desktop app for composing vocals with a piano roll and rendering them through [NEUTRINO](https://studio-neutrino.com/). It supports multiple voice models, MIDI import, WAV export, and GPU-accelerated synthesis.

## quick start

```
git clone https://github.com/kotbruhxd/wfad
git clone https://github.com/kotbruhxd/wsynaps
git clone https://github.com/kotbruhxd/wuon
cd wuon
flutter pub get
flutter build linux   # or: macos / windows
```

Point wuon at your NEUTRINO directory on first launch, then start composing.

Binary: `build/linux/x64/release/bundle/wuon`

## features

- **piano roll** — add, move, resize, delete notes; click and drag
- **scroll** — wheel scrolls horizontally (timeline), shift+wheel scrolls vertically (pitch)
- **zoom** — ctrl+wheel zooms vertically, ctrl+shift+wheel zooms horizontally; zoom overlay in bottom-left corner
- **pitch envelope editor** — per-note pitch bend curve with draggable control points (double-click to delete, drag on line to create); smooth Catmull-Rom spline interpolation, continuous across notes
- **vibrato** — per-note sinusoidal vibrato with configurable depth, frequency and attack; preset dropdown (Light/Medium/Wide/Fast/Slow)
- **note properties** — double-click a note to open a dedicated dialog with lyric, tune, vibrato controls
- **per-note tuning** — semitone offset (−12…+12) per note, applied during NEUTRINO rendering
- **per-voice tuning** — style shift and transpose with ± buttons in the sidebar
- **play** — compiles all voices (sequential, mixed into one WAV), then plays from playhead position
- **model switching** — change voice model and it re-renders on next play
- **wav export** — exports all voice WAVs to a directory via the More menu
- **gpu acceleration** — CUDA auto-detected when available
- **midi import** — imports standard MIDI files as new voices
- **projects** — save/load JSON project files
- **resizable sidebar** — drag handle on right edge (180–500 px range)
- **adaptive piano keys** — width adjusts to viewport (100–220 px)
- **themes** — dark/light mode toggle
- **controls** — space (play/stop), ctrl+s (save), ctrl+z (undo), ctrl+y (redo), del (delete selected notes)

## requirements

- [NEUTRINO](https://studio-neutrino.com/) (Tau v3.2.2+) with voice models
- [Flutter](https://flutter.dev/) SDK 3.0+ (to build)

### NEUTRINO layout

```
NEUTRINO/
├── bin/
│   ├── neutrino
│   ├── musicXMLtoLabel
│   └── ...
├── model/
│   ├── MERROW/
│   ├── NAKUMO/
│   └── ...
└── settings/
    └── dic/
```

## codebase

```
lib/
├── actions/        undo/redo actions
├── controllers/    reactive state (wsynaps)
├── logic/          helpers, musicxml, japanese text, wav mixer
├── pianoroll/      piano roll widget + modules (notes, pitch, waila)
├── serializable/   data models (json)
└── widgets/        appbar, sidebar, dialogs
```

## credits

- [NEUTRINO](https://studio-neutrino.com/) — synthesis engine
- [Muon](https://github.com/SwadicalRag/muon) — original project
- [wsynaps](https://github.com/kotbruhxd/wsynaps) — state management
- [wfad](https://github.com/kotbruhxd/wfad) — audio playback
- [miniaudio](https://miniaud.io/) — audio backend
