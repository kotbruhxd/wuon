import 'dart:io';
import 'dart:typed_data';

import 'package:wuon/controllers/muonproject.dart';

/// Mixes multiple mono 16-bit PCM WAV files into one.
String mixVoiceWavs(MuonProjectController project) {
  final voiceFiles = <String>[];
  for (final voice in project.voices) {
    final path = project.getProjectFilePath("audio/${voice.voiceFileName}.wav");
    if (File(path).existsSync()) {
      voiceFiles.add(path);
    }
  }
  if (voiceFiles.isEmpty) return "";
  if (voiceFiles.length == 1) return voiceFiles.first;

  final outPath = project.getProjectFilePath("audio/mixed.wav");

  // Parse each WAV and accumulate PCM samples
  final buffers = <List<int>>[];
  int maxFrames = 0;
  int sampleRate = 44100;
  int bitsPerSample = 16;

  for (final path in voiceFiles) {
    final bytes = File(path).readAsBytesSync();
    final view = ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes);

    // Parse WAV header to find data chunk
    if (bytes.length < 44) continue;
    int offset = 12; // skip RIFF header
    int dataSize = 0;
    int numChannels = 1;
    while (offset + 8 <= bytes.length) {
      final chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final chunkSize = view.getUint32(offset + 4, Endian.little);
      if (chunkId == "fmt ") {
        final audioFormat = view.getUint16(offset + 8, Endian.little);
        numChannels = view.getUint16(offset + 10, Endian.little);
        sampleRate = view.getUint32(offset + 12, Endian.little);
        bitsPerSample = view.getUint16(offset + 22, Endian.little);
        if (audioFormat != 1) continue; // PCM only
      } else if (chunkId == "data") {
        dataSize = chunkSize;
        final dataOffset = offset + 8;
        // Read PCM samples
        final frames = dataSize ~/ (bitsPerSample ~/ 8 * numChannels);
        final samples = <int>[];
        for (int i = 0; i < frames * numChannels; i++) {
          if (bitsPerSample == 16) {
            samples.add(view.getInt16(dataOffset + i * 2, Endian.little));
          }
        }
        // Average channels to mono
        if (numChannels > 1) {
          final mono = <int>[];
          for (int i = 0; i < samples.length; i += numChannels) {
            int sum = 0;
            for (int ch = 0; ch < numChannels; ch++) {
              sum += samples[i + ch];
            }
            mono.add(sum ~/ numChannels);
          }
          buffers.add(mono);
        } else {
          buffers.add(samples);
        }
        maxFrames = maxFrames > frames ? maxFrames : frames;
      }
      offset += 8 + chunkSize;
    }
  }

  if (buffers.isEmpty) return "";

  // Mix: add samples with scaling to avoid clipping
  final mixed = Int16List(maxFrames);
  for (int i = 0; i < maxFrames; i++) {
    int sum = 0;
    for (final buf in buffers) {
      sum += i < buf.length ? buf[i] : 0;
    }
    // Soft clip to 16-bit range
    if (sum > 32767) sum = 32767;
    if (sum < -32768) sum = -32768;
    mixed[i] = sum;
  }

  // Write output WAV
  final dataSize = mixed.length * 2;
  final fileSize = 36 + dataSize;
  final out = ByteData(fileSize + 8);

  int o = 0;
  // RIFF header
  out.setUint8(o++, 0x52); out.setUint8(o++, 0x49); out.setUint8(o++, 0x46); out.setUint8(o++, 0x46); // "RIFF"
  out.setUint32(o, fileSize, Endian.little); o += 4;
  out.setUint8(o++, 0x57); out.setUint8(o++, 0x41); out.setUint8(o++, 0x56); out.setUint8(o++, 0x45); // "WAVE"
  // fmt chunk
  out.setUint8(o++, 0x66); out.setUint8(o++, 0x6D); out.setUint8(o++, 0x74); out.setUint8(o++, 0x20); // "fmt "
  out.setUint32(o, 16, Endian.little); o += 4; // chunk size
  out.setUint16(o, 1, Endian.little); o += 2; // PCM
  out.setUint16(o, 1, Endian.little); o += 2; // mono
  out.setUint32(o, sampleRate, Endian.little); o += 4;
  out.setUint32(o, sampleRate * 2, Endian.little); o += 4; // byte rate
  out.setUint16(o, 2, Endian.little); o += 2; // block align
  out.setUint16(o, 16, Endian.little); o += 2; // bits per sample
  // data chunk
  out.setUint8(o++, 0x64); out.setUint8(o++, 0x61); out.setUint8(o++, 0x74); out.setUint8(o++, 0x61); // "data"
  out.setUint32(o, dataSize, Endian.little); o += 4;
  // PCM data
  for (final s in mixed) {
    out.setInt16(o, s, Endian.little);
    o += 2;
  }

  File(outPath).writeAsBytesSync(out.buffer.asUint8List());
  return outPath;
}
