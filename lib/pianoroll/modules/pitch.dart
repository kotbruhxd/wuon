import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wuon/controllers/muonnote.dart';
import 'package:wuon/pianoroll/pianoroll.dart';
import 'package:wuon/serializable/muon.dart';

List<Offset> _crSeg(Offset p0, Offset p1, Offset p2, Offset p3, int n) {
  final r = <Offset>[];
  for (int i = 0; i < n; i++) {
    final t = i / n;
    final t2 = t * t;
    final t3 = t2 * t;
    r.add(Offset(
      0.5 * ((2 * p1.dx) +
          (-p0.dx + p2.dx) * t +
          (2 * p0.dx - 5 * p1.dx + 4 * p2.dx - p3.dx) * t2 +
          (-p0.dx + 3 * p1.dx - 3 * p2.dx + p3.dx) * t3),
      0.5 * ((2 * p1.dy) +
          (-p0.dy + p2.dy) * t +
          (2 * p0.dy - 5 * p1.dy + 4 * p2.dy - p3.dy) * t2 +
          (-p0.dy + 3 * p1.dy - 3 * p2.dy + p3.dy) * t3),
    ));
  }
  return r;
}

double _evalCR(List<Offset> ctrl, double t) {
  if (ctrl.length < 2) return 0;
  if (t <= 0) return ctrl.first.dy;
  if (t >= 1) return ctrl.last.dy;
  final segCount = ctrl.length - 1;
  final segT = t * segCount;
  final idx = segT.floor().clamp(0, segCount - 1);
  final lt = segT - idx;
  final a = idx > 0 ? ctrl[idx - 1] : ctrl[idx];
  final b = ctrl[idx];
  final c = ctrl[idx + 1];
  final d = idx + 2 < ctrl.length ? ctrl[idx + 2] : ctrl[idx + 1];
  final t2 = lt * lt;
  final t3 = t2 * lt;
  return 0.5 * ((2 * b.dy) +
      (-a.dy + c.dy) * lt +
      (2 * a.dy - 5 * b.dy + 4 * c.dy - d.dy) * t2 +
      (-a.dy + 3 * b.dy - 3 * c.dy + d.dy) * t3);
}

class PianoRollPitchModule extends PianoRollModule {
  _PitchPointRef? _dragPoint;
  double? _dragOffsetX;
  double? _dragOffsetY;

  static const double _pbb = 500;

  @override
  bool hitTest(Point point) => _getPointAtScreen(point) != null;

  _PitchPointRef? _getPointAtScreen(Point<num> screenPos) {
    const hr = 8.0;
    final cv = painter.screenPosToCanvasPos(screenPos, false);
    for (final voice in project.voices) {
      for (final note in voice.notes) {
        for (int i = 0; i < note.pitchPoints.length; i++) {
          final pp = note.pitchPoints[i];
          final pos = _ptCanvas(note, pp);
          final dx = cv.x - pos.x;
          final dy = cv.y - pos.y;
          if (dx * dx + dy * dy < (hr / painter.xScale) * (hr / painter.xScale)) {
            return _PitchPointRef(note, i);
          }
        }
      }
    }
    return null;
  }

  Point<num> _ptCanvas(MuonNoteController note, PitchPoint pp, {int? pendingOff, double? pendingCents}) {
    final off = pendingOff ?? pp.offset;
    final cents = pendingCents ?? pp.cents;
    final x = (note.startAtTime + off) * _pbb / project.timeUnitsPerBeat;
    final y = PianoRollPainter.pitchToYAxis(note) - cents / 100 * 20;
    return Point(x, y);
  }

  double _yFor(MuonNoteController note, int i) {
    final pp = note.pitchPoints[i];
    final noteY = PianoRollPainter.pitchToYAxis(note);
    if (_dragPoint != null &&
        identical(_dragPoint!.note, note) &&
        _dragPoint!.index == i) {
      return noteY - (_dragPoint!.pendingCents ?? pp.cents) / 100 * 20;
    }
    return noteY - pp.cents / 100 * 20;
  }

  double _xFor(MuonNoteController note, int i) {
    final pp = note.pitchPoints[i];
    if (_dragPoint != null &&
        identical(_dragPoint!.note, note) &&
        _dragPoint!.index == i) {
      return (note.startAtTime + (_dragPoint!.pendingOffset ?? pp.offset)) * _pbb / project.timeUnitsPerBeat;
    }
    return (note.startAtTime + pp.offset) * _pbb / project.timeUnitsPerBeat;
  }

  @override
  void onHover(PointerEvent mouseEvent) {
    final hit = _getPointAtScreen(Point(mouseEvent.localPosition.dx, mouseEvent.localPosition.dy));
    state.setCursor(hit != null ? SystemMouseCursors.click : MouseCursor.defer);
  }

  @override
  void onClick(PointerEvent mouseEvent, int numClicks) {
    final hit = _getPointAtScreen(Point(mouseEvent.localPosition.dx, mouseEvent.localPosition.dy));
    if (hit != null && numClicks == 2) {
      hit.note.pitchPoints.removeAt(hit.index);
      state.repaintNotifier.value++;
    }
  }

  @override
  void onSelect(PointerEvent mouseEvent, Rect selectionBox) {}

  @override
  void onKey(RawKeyEvent keyEvent) {}

  @override
  void onDragStart(PointerEvent mouseEvent, Point mouseStartPos) {
    _dragPoint = _getPointAtScreen(mouseStartPos);

    if (_dragPoint == null) {
      final cv = painter.screenPosToCanvasPos(mouseStartPos, false);
      final note = _noteAtCanvasPos(cv);
      if (note != null && note.pitchPoints.length >= 2) {
        final relTime = ((cv.x * project.timeUnitsPerBeat / _pbb) - note.startAtTime)
            .round()
            .clamp(0, note.duration);
        final noteY = PianoRollPainter.pitchToYAxis(note);
        final cents = ((noteY - cv.y) / 20 * 100).roundToDouble();

        int idx = 0;
        for (int i = 0; i < note.pitchPoints.length; i++) {
          if (note.pitchPoints[i].offset <= relTime) idx = i + 1;
        }
        note.pitchPoints.insert(idx, PitchPoint(relTime, cents));
        _dragPoint = _PitchPointRef(note, idx);
      }
    }

    if (_dragPoint != null) {
      final pos = _ptCanvas(_dragPoint!.note, _dragPoint!.note.pitchPoints[_dragPoint!.index]);
      final sp = painter.canvasPosToScreenPos(pos, false);
      _dragOffsetX = (sp.x - mouseStartPos.x).toDouble();
      _dragOffsetY = (sp.y - mouseStartPos.y).toDouble();
    }
  }

  @override
  void onDragging(PointerEvent mouseEvent, Point mouseStartPos) {
    if (_dragPoint == null) return;

    final sp = Point(
      mouseEvent.localPosition.dx + (_dragOffsetX ?? 0),
      mouseEvent.localPosition.dy + (_dragOffsetY ?? 0),
    );
    final cv = painter.screenPosToCanvasPos(sp, false);
    final note = _dragPoint!.note;

    final relTime = ((cv.x * project.timeUnitsPerBeat / _pbb) - note.startAtTime).round();
    _dragPoint!.pendingOffset = relTime.clamp(0, note.duration) as int;

    final noteY = PianoRollPainter.pitchToYAxis(note);
    _dragPoint!.pendingCents = ((noteY - cv.y) / 20 * 100).toDouble();

    state.repaintNotifier.value++;
  }

  @override
  void onDragEnd(PointerEvent mouseEvent, Point mouseStartPos) {
    if (_dragPoint != null) {
      final note = _dragPoint!.note;
      final pp = note.pitchPoints[_dragPoint!.index];
      pp.offset = _dragPoint!.pendingOffset ?? pp.offset;
      pp.cents = _dragPoint!.pendingCents ?? pp.cents;
    }
    _dragPoint = null;
    _dragOffsetX = null;
    _dragOffsetY = null;
    state.repaintNotifier.value++;
  }

  // --- helpers ---

  MuonNoteController? _noteAtCanvasPos(Point<num> cv) {
    for (final voice in project.voices) {
      for (final note in voice.notes) {
        final nx = note.startAtTime * _pbb / project.timeUnitsPerBeat;
        final nw = note.duration * _pbb / project.timeUnitsPerBeat;
        final ny = PianoRollPainter.pitchToYAxis(note);
        if (cv.x >= nx && cv.x <= nx + nw &&
            cv.y >= ny - 10 && cv.y <= ny + 30) {
          return note;
        }
      }
    }
    return null;
  }

  // --- paint ---

  @override
  void paint(Canvas canvas, Size size) {
    final theme = painter.themeData;
    final isDark = theme.brightness == Brightness.dark;

    for (final voice in project.voices) {
      final color = voice.color as Color;

      // 1. Collect all pitch points across notes, sorted by canvas X
      final pts = <_Pt>[];
      for (final note in voice.notes) {
        for (int i = 0; i < note.pitchPoints.length; i++) {
          pts.add(_Pt(_xFor(note, i), _yFor(note, i), note, i));
        }
      }
      pts.sort((a, b) => a.x.compareTo(b.x));
      if (pts.length < 2) continue;

      // 2. Build note X ranges for vibrato lookup (cache for this voice)
      final vibRanges = <_VibRange>[];
      for (final note in voice.notes) {
        if (note.vibratoEnabled && note.vibratoDepth > 0) {
          final nx = note.startAtTime * _pbb / project.timeUnitsPerBeat;
          final nw = note.duration * _pbb / project.timeUnitsPerBeat;
          vibRanges.add(_VibRange(note, nx, nx + nw));
        }
      }
      final hasVib = vibRanges.isNotEmpty;

      // 3. Build continuous base path (Catmull-Rom)
      final basePath = Path();
      const seg = 24;
      for (int i = 0; i < pts.length - 1; i++) {
        final a = i > 0 ? pts[i - 1] : pts[i];
        final b = pts[i];
        final c = pts[i + 1];
        final d = i + 2 < pts.length ? pts[i + 2] : pts[i + 1];
        final samples = _crSeg(Offset(a.x, a.y), Offset(b.x, b.y),
            Offset(c.x, c.y), Offset(d.x, d.y), seg);
        if (i == 0) basePath.moveTo(samples.first.dx, samples.first.dy);
        for (final p in samples.skip(1)) basePath.lineTo(p.dx, p.dy);
      }

      // 4. If any note has vibrato, sample at high res and modulate
      Path renderPath = basePath;
      if (hasVib) {
        final ctrlPts = pts.map((p) => Offset(p.x, p.y)).toList();
        final x0 = pts.first.x;
        final x1 = pts.last.x;
        final span = x1 - x0;
        const pxPerSample = 3.0;
        final n = (span * painter.xScale / pxPerSample).round().clamp(24, 600);
        final beatSec = 60.0 / project.bpm;

        renderPath = Path();
        for (int i = 0; i < n; i++) {
          final t = i / (n - 1);
          final x = x0 + t * span;
          final baseY = _evalCR(ctrlPts, t);

          double y = baseY;
          for (final vr in vibRanges) {
            if (x >= vr.x1 && x < vr.x2) {
              final localT = (x - vr.x1) / (vr.x2 - vr.x1);
              final attack = vr.note.vibratoAttack;
              final envelope = localT < attack ? (localT / attack) : 1.0;
              // convert X to time in seconds for frequency
              final ticks = x * project.timeUnitsPerBeat / _pbb;
              final timeSec = ticks * beatSec / project.timeUnitsPerBeat;
              final vibOffset = vr.note.vibratoDepth / 100 * 20 *
                  envelope * sin(2 * pi * vr.note.vibratoFrequency * timeSec);
              y = baseY + vibOffset;
              break;
            }
          }
          if (i == 0) renderPath.moveTo(x, y);
          else renderPath.lineTo(x, y);
        }
      }

      // 5. Draw glow
      canvas.drawPath(renderPath, Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 / painter.xScale
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

      // 6. Draw main line
      canvas.drawPath(renderPath, Paint()
        ..color = color.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 / painter.xScale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round);

      // 7. Control points
      for (final pt in pts) {
        final isDragged = _dragPoint != null &&
            identical(_dragPoint!.note, pt.note) &&
            _dragPoint!.index == pt.idx;
        final center = Offset(pt.x, pt.y);
        final r = isDragged ? 5 / painter.xScale : 3.5 / painter.xScale;

        canvas.drawCircle(center, r * 2.5, Paint()
          ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

        canvas.drawCircle(center, r, Paint()
          ..color = color
          ..style = PaintingStyle.fill);

        canvas.drawCircle(center, r, Paint()
          ..color = isDark ? Colors.white : Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8 / painter.xScale);

        if (isDragged) {
          canvas.drawCircle(center, r + 2 / painter.xScale, Paint()
            ..color = color.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5 / painter.xScale);
        }
      }
    }
  }
}

class _PitchPointRef {
  final MuonNoteController note;
  final int index;
  int? pendingOffset;
  double? pendingCents;
  _PitchPointRef(this.note, this.index);
}

class _Pt {
  final double x, y;
  final MuonNoteController note;
  final int idx;
  _Pt(this.x, this.y, this.note, this.idx);
}

class _VibRange {
  final MuonNoteController note;
  final double x1, x2;
  _VibRange(this.note, this.x1, this.x2);
}
