<p align="center">
  <img src="eyecandy/icon.png" width="128" height="128" alt="wuon">
</p>

<h1 align="center">wuon</h1>

<p align="center">
  <i>歌声合成フロントエンド — muon フォーク (eol)</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-linux%20%7C%20windows%20%7C%20macos-lightgrey">
  <img src="https://img.shields.io/badge/dart-%3E%3D3.0-blue">
  <img src="https://img.shields.io/badge/neutrino-tau_v3.2.2-ff69b4">
</p>

---

**wuon** は、ピアノロールでボーカルを作曲し、[NEUTRINO](https://studio-neutrino.com/) でレンダリングするためのデスクトップアプリです。複数の音声モデル、MIDI インポート、WAV エクスポート、GPU アクセラレーションによる合成に対応しています。

## クイックスタート

```
git clone https://github.com/kotbruhxd/wfad
git clone https://github.com/kotbruhxd/wsynaps
git clone https://github.com/kotbruhxd/wuon
cd wuon
flutter pub get
flutter build linux   # または macos / windows
```

初回起動時に NEUTRINO ディレクトリを設定すれば、すぐに作曲を始められます。

実行ファイル: `build/linux/x64/release/bundle/wuon`

## 機能

- **ピアノロール** — ノートの追加・移動・リサイズ・削除
- **スクロール** — ホイールで水平（タイムライン）、Shift+ホイールで垂直（ピッチ）
- **ズーム** — Ctrl+ホイールで垂直ズーム、Ctrl+Shift+ホイールで水平ズーム
- **ピッチエンベロープエディター** — ノートごとのピッチベンドカーブ、ドラッグ可能なコントロールポイント（ダブルクリックで削除、ライン上をドラッグで作成）、Catmull-Rom スプライン補間
- **ビブラート** — ノートごとの正弦波ビブラート（深さ・周波数・アタック設定可能）、プリセット（Light/Medium/Wide/Fast/Slow）
- **ノートプロパティ** — ノートをダブルクリックで専用ダイアログを開き、歌詞・チューン・ビブラートを編集
- **ノート単位チューン** — ノートごとにセミトーン単位でピッチシフト (−12～+12)、NEUTRINO レンダリング時に反映
- **ボイス単位チューン** — スタイルシフトとトランスポーズをサイドバーで調整
- **再生** — 全ボイスを逐次コンパイルし、WAV ミックス後に再生
- **モデル切り替え** — ボイスモデルを変更すると次回再生時に再レンダリング
- **WAV エクスポート** — More メニューから全ボイスの WAV を出力
- **GPU アクセラレーション** — CUDA を自動検出
- **MIDI インポート** — 標準 MIDI ファイルをボイスとして読み込み
- **プロジェクト** — JSON 形式で保存・読み込み
- **リサイズ可能なサイドバー** — 右端のドラッグハンドルで幅を調節 (180～500 px)
- **適応型ピアノ鍵盤** — 画面幅に合わせて鍵盤幅を自動調整 (100～220 px)
- **テーマ** — ダーク/ライトモード切替
- **ショートカット** — Space（再生/停止）、Ctrl+S（保存）、Ctrl+Z（元に戻す）、Ctrl+Y（やり直し）、Del（選択ノート削除）

## 必要環境

- [NEUTRINO](https://studio-neutrino.com/) (Tau v3.2.2+) と音声モデル
- [Flutter](https://flutter.dev/) SDK 3.0+（ビルド用）

### NEUTRINO ディレクトリ構成

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

## コード構成

```
lib/
├── actions/        元に戻す/やり直しアクション
├── controllers/    リアクティブステート (wsynaps)
├── logic/          ヘルパー、MusicXML、日本語処理、WAV ミキサー
├── pianoroll/      ピアノロールウィジェット + モジュール (notes, pitch, waila)
├── serializable/   データモデル (JSON)
└── widgets/        アプリバー、サイドバー、ダイアログ
```

## クレジット

- [NEUTRINO](https://studio-neutrino.com/) — 合成エンジン
- [Muon](https://github.com/SwadicalRag/muon) — 元プロジェクト
- [wsynaps](https://github.com/kotbruhxd/wsynaps) — 状態管理
- [wfad](https://github.com/kotbruhxd/wfad) — オーディオ再生
- [miniaudio](https://miniaud.io/) — オーディオバックエンド
