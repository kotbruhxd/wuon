# wuon

A cross-platform UTAU-like singing synthesizer frontend built with Flutter.

Fork of [Muon](https://github.com/SwadicalRag/muon) (end of life).

## Overview

wuon is a desktop application for composing vocal parts using a piano roll interface and rendering them through the [NEUTRINO](https://studio-neutrino.com/) singing synthesis engine. It supports multiple voice models, MusicXML import/export, and real-time audio playback.

## Features

- Piano roll editor with note input, selection, move, resize, delete
- Multiple voice tracks with per-voice model selection
- NEUTRINO integration for high-quality singing synthesis
- MusicXML export to third-party tools
- MIDI file import via MusicXML conversion
- Project save/load (JSON format)
- Dark/light theme
- Cross-platform (Linux, Windows, macOS)

## Prerequisites

- [NEUTRINO](https://studio-neutrino.com/) (Tau v3.2.2 or compatible) with voice model directories
- [Flutter](https://flutter.dev/) SDK 3.0+ (for development)

## Setup

1.  Install NEUTRINO and place voice models in `NEUTRINO/model/`
2.  Launch wuon — on first run, you'll be prompted to select the NEUTRINO directory
3.  Create or open a project and start composing

### Build from source

```sh
flutter pub get
flutter build linux   # or macos / windows
git clone https://github.com/kotbruhxd/wsynaps #
```

The binary will be at `build/linux/x64/release/bundle/wuon` change the linux to your os eg, windows.

### NEUTRINO directory structure

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

## Usage

- **Space** — play/stop
- **Ctrl+S** — save project
- **Ctrl+Z** — undo
- **Ctrl+Y** — redo
- Render button — compiles all voices and plays from playhead

## Project structure

```
lib/
├── actions/        # Undo/redo actions
├── controllers/    # Reactive state controllers (synaps)
├── logic/          # Helpers, MusicXML, Japanese text utils
├── pianoroll/      # Piano roll widget + modules
├── serializable/   # Data models (JSON serialization)
└── widgets/        # UI components (appbar, sidebar, dialogs)
```

## Acknowledgments

- [NEUTRINO](https://studio-neutrino.com/) — singing synthesis engine
- [Muon](https://github.com/SwadicalRag/muon) — original project this was forked from
- [synaps](https://github.com/SwadicalRag/synaps) — reactive state management
- [flutter_audio_desktop](https://github.com/SwadicalRag/flutter_audio_desktop) — audio playback
- [miniaudio](https://miniaud.io/) — audio backend
