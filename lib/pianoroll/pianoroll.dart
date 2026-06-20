import "dart:async";
import "dart:math";
import "dart:ui";

import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:wuon/controllers/muonnote.dart";
import "package:wuon/helpers.dart";

import "package:wuon/controllers/muonproject.dart";
import "package:wuon/serializable/muon.dart";
import 'package:synaps_flutter/synaps_flutter.dart';

class PianoRollPitch {
  late String note;
  late int octave;
}

class PianoRollControls {
  late PianoRollPainter painter;
  late _PianoRollState state;
}

typedef _onMouseHoverCallbackType = void Function(PianoRollControls pianoRoll,PointerEvent mouseEvent);
typedef _onClickCallbackType = void Function(PianoRollControls pianoRoll,PointerEvent mouseEvent,int numClicks);
typedef _onSelectCallbackType = void Function(PianoRollControls pianoRoll,PointerEvent mouseEvent,Rect selectionBox);
typedef _onKeyCallbackType = void Function(PianoRollControls pianoRoll,RawKeyEvent keyEvent);

abstract class PianoRollModule {
  _PianoRollState? _state;
  _PianoRollState get state => _state!;
  PianoRollPainter? _painter;
  PianoRollPainter get painter => _painter!;
  BuildContext? _context;
  BuildContext get context => _context!;

  PianoRoll get widget => state.widget;
  MuonProjectController get project => widget.project;

  void attach(_PianoRollState state,PianoRollPainter painter,BuildContext context) {
    _state = state;
    _painter = painter;
    _context = context;
  }

  void detach() {
    _state = null;
    _painter = null;
    _context = null;
  }

  void dispose() {}

  /// Returns true if there is an object defined by this Module at this screen coordinate
  bool hitTest(Point point);

  /// Called when the mouse hovers around the screen
  void onHover(PointerEvent mouseEvent);

  /// Called on a mousedown event
  void onClick(PointerEvent mouseEvent,int numClicks);

  /// Called when the mouse starts dragging (slightly later after mouse down)
  /// Internally, it ensures the mouse moves at least 3 square pixels
  void onDragStart(PointerEvent mouseEvent,Point mouseStartPos);

  /// Called while the mouse is dragging something
  void onDragging(PointerEvent mouseEvent,Point mouseStartPos);

  /// Called when the mouse is finished dragging (on mouse up)
  void onDragEnd(PointerEvent mouseEvent,Point mouseStartPos);

  /// Called when the mouse is selecting something on the screen by clicking and dragging
  void onSelect(PointerEvent mouseEvent,Rect selectionBox);

  /// Called when there is a keyboard event
  void onKey(RawKeyEvent keyEvent);

  /// Called by the custom painter to allow this module to paint more things on top of the grid
  void paint(Canvas canvas,Size size);
}

class PianoRoll extends StatefulWidget {
  PianoRoll({
    required this.project,
    this.onHover,
    this.onClick,
    this.onSelect,
    this.onKey,
    this.modules = const [],
  });

  final MuonProjectController project;
  final _onMouseHoverCallbackType? onHover;
  final _onClickCallbackType? onClick;
  final _onSelectCallbackType? onSelect;
  final _onKeyCallbackType? onKey;
  final List<PianoRollModule> modules;

  @override
  _PianoRollState createState() => _PianoRollState();
}

enum _PianoRollPointerMode {
  IDLE,
  LMB_CLICK,
  RMB_CLICK,
  PANNING,
  DRAGGING,
  SELECTING,
  NOTE_CREATING,
}

class _PianoRollState extends State<PianoRoll> {
  _PianoRollState();
  
  // Used by the custompainter
  double pianoKeysWidth = 150.0;

  // Used by the scrollzoompan controller
  // and also made available to any modules
  bool isCtrlKeyHeld = false;
  bool isAltKeyHeld = false;
  bool isShiftKeyHeld = false;

  // used by the mouse controller
  _PianoRollPointerMode pointerMode = _PianoRollPointerMode.IDLE;
  bool _hasMouseMovedSignificantly = false;
  Point<num>? _firstMouseDownPos;
  Timer? _lastClickTimeDecay;
  int _lastClickCount = 0;
  PianoRollModule? currentlyDraggingModule;
  Rect? selectionRect;
  PointerEvent? lastPointerEvent;

  /// Ghost note for click-drag creation
  Rect? _ghostNoteRect;
  Point<num>? _noteCreateStartCanvas;

  /// Current mouse cursor
  MouseCursor cursor = MouseCursor.defer;

  /// Current mouse position
  Point<num>? curMousePos;

  /// Mutable view state shared with the painter for scroll/zoom (avoids full rebuilds)
  final viewState = _PianoRollViewState();
  final repaintNotifier = ValueNotifier(0);
  PianoRollPainter? _painter;

  // Why am I doing this, you ask?
  // Because flutter uses arrow keys for Focus traversal
  // but i don't want that. I couldn't find an easy way to achieve this
  // whilst preserving my onKey callback, so we're using this ugly hack
  // Enjoy!
  final Map<LogicalKeySet, Intent> _disabledNavigationKeys = <LogicalKeySet, Intent>{
    LogicalKeySet(LogicalKeyboardKey.arrowUp): Intent.doNothing,
    LogicalKeySet(LogicalKeyboardKey.arrowDown): Intent.doNothing,
    LogicalKeySet(LogicalKeyboardKey.arrowLeft): Intent.doNothing,
    LogicalKeySet(LogicalKeyboardKey.arrowRight): Intent.doNothing,
  };

  // why initialise the FocusNode here and not in the parent class, you ask?
  // I have no idea why but when I initialise the FocusNode in the parent,
  // focus logic breaks after the first hot reload. I do not have the patience
  // to figure out why.
  final focusNode = FocusNode();

  @override
  void initState() {
    RawKeyboard.instance.addListener(_keyListener);
    super.initState();
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_keyListener);
          
    for(final module in widget.modules) {
      module.dispose();
      module.detach();
    }
    
    super.dispose();
  }

  _keyListener(RawKeyEvent event) {
    isShiftKeyHeld = event.isShiftPressed;
    isAltKeyHeld = event.isAltPressed;
    isCtrlKeyHeld = event.isControlPressed;
  }

  void setCursor(MouseCursor cursor) {
    setState(() {
      this.cursor = cursor;
    });
  }

  double _cachedSongLength = 2400.0;
  bool _songLengthDirty = true;

  double _songLengthBeats() {
    if (!_songLengthDirty) return _cachedSongLength;
    double maxBeat = 0;
    for (final voice in widget.project.voices) {
      for (final note in voice.notes) {
        final end = (note.startAtTime + note.duration).toDouble();
        if (end > maxBeat) maxBeat = end;
      }
    }
    _cachedSongLength = maxBeat / widget.project.timeUnitsPerBeat;
    _songLengthDirty = false;
    return _cachedSongLength;
  }

  void _invalidateSongLength() {
    _songLengthDirty = true;
  }

  void clampXY(double renderBoxHeight, [double? renderBoxWidth]) {
    double totHeight = renderBoxHeight / viewState.yScale;
    viewState.yOffset = min(0, viewState.yOffset);

    if (totHeight < 1920) {
      double requiredExtraHeight = 1920 - totHeight;
      viewState.yOffset = min(0, max(-requiredExtraHeight, viewState.yOffset));
    } else {
      viewState.yOffset = 0;
    }

    if (renderBoxWidth != null) {
      const double pixelsPerBeat = 500;
      final double twentyMinBeats = 2400; // 20 min at 120 BPM
      final songLen = max(twentyMinBeats, _songLengthBeats() + 4);
      final maxX = songLen * pixelsPerBeat - renderBoxWidth / viewState.xScale;
      viewState.xOffset = min(4.0, max(-maxX, viewState.xOffset));
    } else {
      viewState.xOffset = min(4.0, viewState.xOffset);
    }
  }

  void updatePointerEvents() {
    if(pointerMode == _PianoRollPointerMode.DRAGGING) {
      currentlyDraggingModule?.onDragging(lastPointerEvent!,_firstMouseDownPos!);
    }
    else if(pointerMode == _PianoRollPointerMode.SELECTING) {
      for(final module in widget.modules) {
        module.onSelect(lastPointerEvent!,selectionRect!);
      }
    }
  }

  void _createNoteAt(double canvasX, double canvasY, {int? duration}) {
    if (widget.project.voices.isEmpty ||
        widget.project.currentVoiceID >= widget.project.voices.length) return;

    final voice = widget.project.voices[widget.project.currentVoiceID];
    final pitch = PianoRollPainter.pitchMapReverse[
        (((-canvasY / 20) % 12) + 12) % 12] ?? "C";
    final octave = 8 - (canvasY / 20 / 12).floor();

    const double pixelsPerBeat = 500;
    final note = MuonNoteController().ctx();
    note.note = pitch;
    note.octave = octave.clamp(1, 8);
    note.lyric = "あ";
    note.startAtTime = (canvasX / pixelsPerBeat *
            widget.project.timeUnitsPerBeat)
        .floor();
    note.startAtTime = floorToModulus(
        note.startAtTime, widget.project.timeUnitsPerSubdivision);
    note.duration = duration ?? widget.project.timeUnitsPerSubdivision;

    final defDur = note.duration;
    final subDiv = widget.project.timeUnitsPerSubdivision;
    note.pitchPoints = [
      PitchPoint(0, 0),
      PitchPoint(defDur ~/ subDiv * subDiv, 0),
    ];

    voice.addNote(note);
    widget.project.playheadTime = note.startAtTime / widget.project.timeUnitsPerBeat;
  }

  void onScrollZoomPan(PointerScrollEvent details,BoxConstraints constraints) {
    if (isCtrlKeyHeld && isShiftKeyHeld) {
      // horizontal zoom
      double targetScaleX = max(
          0.0625, min(4, viewState.xScale - details.scrollDelta.dy / 320));
      double xPointer = details.localPosition.dx - pianoKeysWidth;
      double xTarget = (xPointer / viewState.xScale - viewState.xOffset);

      viewState.xScale = targetScaleX;
      viewState.xOffset = -xTarget + xPointer / viewState.xScale;
    }
    else if (isCtrlKeyHeld) {
      // vertical zoom
      double targetScaleY = max(
          0.25, min(4, viewState.yScale - details.scrollDelta.dy / 80));
      if (((constraints.maxHeight / targetScaleY) <= 1920) ||
          (details.scrollDelta.dy < 0)) {
        double yPointer = details.localPosition.dy;
        double yTarget = (yPointer / viewState.yScale - viewState.yOffset);

        viewState.yScale = targetScaleY;
        viewState.yOffset = -yTarget + yPointer / viewState.yScale;
      }
    }
    else if (isShiftKeyHeld) {
      // vertical scroll (pitch)
      viewState.yOffset = viewState.yOffset - details.scrollDelta.dy / viewState.yScale;
      viewState.xOffset = viewState.xOffset - details.scrollDelta.dx / viewState.xScale;
    }
    else {
      // horizontal scroll (timeline) — default wheel behavior
      viewState.xOffset = viewState.xOffset - details.scrollDelta.dy / viewState.xScale;
      viewState.yOffset = viewState.yOffset - details.scrollDelta.dx / viewState.yScale;
    }

    this.clampXY(constraints.maxHeight, constraints.maxWidth);
    repaintNotifier.value++;
  }

  void onPointerHover(PointerHoverEvent details,PianoRollControls controls) {
    curMousePos = Point(details.localPosition.dx,details.localPosition.dy);
    final mousePos = curMousePos;
    final firstDown = _firstMouseDownPos;
    if((_lastClickTimeDecay == null) || (firstDown == null) || (mousePos == null)) {
      _lastClickCount = 0;
    }
    else if(mousePos.squaredDistanceTo(firstDown) > 9) {
      _lastClickCount = 0;
    }

    if(widget.onHover != null) {
      widget.onHover!(controls,details);
    }

    for(final module in widget.modules) {
      module.onHover(details);
    }
  }

  void onPointerDown(PointerDownEvent details) {
    if((details.buttons & kMiddleMouseButton) == kMiddleMouseButton) {
      // Middle mouse events are always pans
      pointerMode = _PianoRollPointerMode.PANNING;
    }
    else if((details.buttons & kPrimaryMouseButton) == kPrimaryMouseButton) {
      // Left mouse events are ambiguous.
      // If the mouseup event immediately follows the mousedown OR
      // If the mouse stays within 3 square pixels of the mousedown pos, it's a click
      // Otherwise, two things can happen:
      // 1. If the mousedown occurred over a module.hitTest() == true point, it starts a drag event
      // 2. Elsewhere, it starts a select event
      // This logic is handled in onPointerMove

      final screenPos = Point(details.localPosition.dx,details.localPosition.dy);

      pointerMode = _PianoRollPointerMode.LMB_CLICK;

      // save the first mousedown pos so that onPointerMove can calculate pointer move distance
      // and also use it in the callbacks to modules/etc. 
      _firstMouseDownPos = screenPos;
      _hasMouseMovedSignificantly = false;

      // Reset last click count if the timer has timed out (OR if the user clicks more than 2 times).
      _lastClickCount++;
      if((_lastClickTimeDecay == null) || (_lastClickCount >= 2)) {
        _lastClickCount = 0;
      }
    }
  }

  void onPointerMove(PointerMoveEvent details,BoxConstraints constraints,PianoRollControls controls) {
    final screenPos = Point(details.localPosition.dx,details.localPosition.dy);
    curMousePos = screenPos;

    if(!_hasMouseMovedSignificantly && (pointerMode == _PianoRollPointerMode.LMB_CLICK)) {
      if((curMousePos != null) && (_firstMouseDownPos != null) && (curMousePos!.squaredDistanceTo(_firstMouseDownPos!) > 9)) {
        _hasMouseMovedSignificantly = true;

        PianoRollModule? hitTestPassedModule;
        for(int modIdx=widget.modules.length-1;modIdx >=0;modIdx--) {
          final module = widget.modules[modIdx];

          if(module.hitTest(_firstMouseDownPos!)) {
            hitTestPassedModule = module;
            break;
          }
        }
        
        if(hitTestPassedModule != null) {
          pointerMode = _PianoRollPointerMode.DRAGGING;
          currentlyDraggingModule = hitTestPassedModule;
          lastPointerEvent = details;
          currentlyDraggingModule!.onDragStart(details,_firstMouseDownPos!);
        } else if (!isShiftKeyHeld) {
          // drag on empty space → create note with custom length
          pointerMode = _PianoRollPointerMode.NOTE_CREATING;
          final painter = PianoRollPainter(
            widget.project, Theme.of(context), pianoKeysWidth,
            viewState, null, null, widget.modules);
          final canvasStart = painter.screenPosToCanvasPos(_firstMouseDownPos!, false);
          _noteCreateStartCanvas = canvasStart;
          _ghostNoteRect = Rect.fromPoints(
            Offset(canvasStart.x.toDouble(), canvasStart.y.toDouble()),
            Offset(canvasStart.x.toDouble(), canvasStart.y.toDouble()),
          );
        }
      }
    }

    if(_hasMouseMovedSignificantly) {
      _lastClickCount = 0;
    }

    if (pointerMode == _PianoRollPointerMode.NOTE_CREATING) {
      setState(() {
        final painter = PianoRollPainter(
          widget.project, Theme.of(context), pianoKeysWidth,
          viewState, null, null, widget.modules);
        final canvasEnd = painter.screenPosToCanvasPos(screenPos, false);
        final start = _noteCreateStartCanvas!;
        _ghostNoteRect = Rect.fromLTRB(
          min(start.x, canvasEnd.x).toDouble(),
          (start.y / 20).floorToDouble() * 20,
          max(start.x, canvasEnd.x).toDouble(),
          ((canvasEnd.y / 20).floorToDouble() + 1) * 20,
        );
      });
    } else if (pointerMode == _PianoRollPointerMode.PANNING) {
      viewState.xOffset = viewState.xOffset + details.delta.dx / viewState.xScale;
      viewState.yOffset = viewState.yOffset + details.delta.dy / viewState.yScale;

      this.clampXY(constraints.maxHeight, constraints.maxWidth);
      repaintNotifier.value++;
    }
      else if (pointerMode == _PianoRollPointerMode.SELECTING) {
      lastPointerEvent = details;
      setState(() {
        var left = min(_firstMouseDownPos!.x, details.localPosition.dx).toDouble();
        var right = max(_firstMouseDownPos!.x, details.localPosition.dx).toDouble();
        var top = min(_firstMouseDownPos!.y, details.localPosition.dy).toDouble();
        var bottom = max(_firstMouseDownPos!.y, details.localPosition.dy).toDouble();
        selectionRect = Rect.fromLTRB(left,top,right,bottom);

        if(widget.onSelect != null) {
          widget.onSelect!(controls,details,selectionRect!);
        }

        for(final module in widget.modules) {
          module.onSelect(details,selectionRect!);
        }
      });
    }
    else if (pointerMode == _PianoRollPointerMode.DRAGGING) {
      lastPointerEvent = details;
      currentlyDraggingModule?.onDragging(details,_firstMouseDownPos!);
    }
  }

  void onPointerUp(PointerUpEvent details,PianoRollControls controls) {
    // Pointer has stopped clicking, so it's time to clean up state

    if(pointerMode == _PianoRollPointerMode.SELECTING) {
      // Fire the final onSelect events
      if(widget.onSelect != null) {
        widget.onSelect!(controls,details,selectionRect!);
      }

      for(final module in widget.modules) {
        module.onSelect(details,selectionRect!);
      }

      lastPointerEvent = null;
      setState(() {
        // Free the selection rect
        // (inside setstate because it is used in the custompaint widget)
        selectionRect = null;
      });
    }
    else if(pointerMode == _PianoRollPointerMode.PANNING) {
      // No special state to free
    }
      else if(pointerMode == _PianoRollPointerMode.DRAGGING) {
      // finish dragging something!
      currentlyDraggingModule?.onDragEnd(details,_firstMouseDownPos!);
      currentlyDraggingModule = null;
      lastPointerEvent = null;
    }
    else if(pointerMode == _PianoRollPointerMode.NOTE_CREATING) {
      // finalize the ghost note
      final ghost = _ghostNoteRect;
      if (ghost != null && ghost.width > 2 / viewState.xScale) {
        const double pixelsPerBeat = 500;
        _createNoteAt(
          ghost.center.dx,
          ghost.top,
          duration: ((ghost.width * widget.project.timeUnitsPerBeat) /
                  pixelsPerBeat)
              .round(),
        );
      }
      setState(() {
        _ghostNoteRect = null;
        _noteCreateStartCanvas = null;
      });
    }
    else if(pointerMode == _PianoRollPointerMode.LMB_CLICK) {
      // check if this was a click on empty grid (single click, no note under cursor)
      final mousePos = Point(details.localPosition.dx, details.localPosition.dy);
      bool hitNote = false;
      for (final module in widget.modules) {
        if (module.hitTest(mousePos)) { hitNote = true; break; }
      }
      if (!hitNote && _lastClickCount == 0 && widget.project.voices.isNotEmpty) {
        final painter = PianoRollPainter(
          widget.project, Theme.of(context), pianoKeysWidth,
          viewState, null, null, widget.modules);
        final canvasPos = painter.screenPosToCanvasPos(mousePos, false);
        _createNoteAt(canvasPos.x.toDouble(), canvasPos.y.toDouble());
      }

      if(widget.onClick != null) {
        widget.onClick!(controls,details,_lastClickCount + 1);
      }

      for(final module in widget.modules) {
        module.onClick(details,_lastClickCount + 1);
      }

      _lastClickTimeDecay?.cancel();
    
      _lastClickTimeDecay = new Timer(Duration(milliseconds: 300),() {
        _firstMouseDownPos = null;
        _lastClickTimeDecay = null;
      });
    }

    // Reset hasMouseMovedSignificantly to false
    _hasMouseMovedSignificantly = false;

    pointerMode = _PianoRollPointerMode.IDLE;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Shortcuts(
      // Disable flutter's focus traversal
      shortcuts: _disabledNavigationKeys,

      child: Row(mainAxisSize: MainAxisSize.max, children: [
        Expanded(child: LayoutBuilder(builder: (context, constraints) {
          if (viewState.xOffset == 0 && viewState.yOffset == 0) {
            // first run: scroll to C#6
            viewState.xOffset = 0;
            viewState.yOffset = -PianoRollPainter.pitchToYAxisEx("C#", 6);
          }

          // Use the LayoutBuilder's constraints to ensure that the
          // scale/offsets are appropriate for our current window height
          this.clampXY(constraints.maxHeight, constraints.maxWidth);

          pianoKeysWidth = constraints.maxWidth * 0.08;
          pianoKeysWidth = pianoKeysWidth.clamp(100, 220);

          _painter = PianoRollPainter(widget.project, themeData,
              pianoKeysWidth, viewState, selectionRect, curMousePos, widget.modules, _ghostNoteRect, repaintNotifier);
          var rectPainter = _painter!;

          final controls = PianoRollControls();
          controls.painter = rectPainter;
          controls.state = this;
          
          for(final module in widget.modules) {
            module.attach(this,rectPainter,context);
          }

          return RawKeyboardListener(
            focusNode: focusNode,
            autofocus: true,
            onKey: (RawKeyEvent event) {
              // Forward keyevents to listeners
              if(widget.onKey != null) {
                widget.onKey!(controls,event);
              }

              for(final module in widget.modules) {
                module.onKey(event);
              }

              // Also update pointer events
              // and call drag/select callbacks (in case they)
              // change behavior with keypresses
              updatePointerEvents();
            },
            child: MouseRegion(
              cursor: cursor,
              child: Listener(
                onPointerSignal: (details) {
                  if (details is PointerScrollEvent) {
                    this.onScrollZoomPan(details, constraints);
                  }
                },
                onPointerDown: onPointerDown,
                onPointerUp: (details) => onPointerUp(details,controls),
                onPointerMove: (details) => onPointerMove(details,constraints,controls),
                onPointerHover: (details) => onPointerHover(details,controls),
                child: Stack(
                  children: [
                    Container(
                      color: themeData.scaffoldBackgroundColor,
                      child: RxCustomPaint(
                        painter: rectPainter,
                        child: Container(),
                        willChange: true,
                      ),
                    ),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Material(
                        color: themeData.colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.zoom_out, size: 18),
                              tooltip: "Zoom out vertically",
                              padding: EdgeInsets.all(6),
                              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: () {
                                viewState.yScale = max(0.25, viewState.yScale - 0.25);
                                clampXY(constraints.maxHeight, constraints.maxWidth);
                                repaintNotifier.value++;
                              },
                            ),
                            Text("${(viewState.yScale * 100).round()}%", style: TextStyle(fontSize: 11)),
                            IconButton(
                              icon: const Icon(Icons.zoom_in, size: 18),
                              tooltip: "Zoom in vertically",
                              padding: EdgeInsets.all(6),
                              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: () {
                                viewState.yScale = min(4.0, viewState.yScale + 0.25);
                                clampXY(constraints.maxHeight, constraints.maxWidth);
                                repaintNotifier.value++;
                              },
                            ),
                            SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.zoom_out_map, size: 18),
                              tooltip: "Reset zoom",
                              padding: EdgeInsets.all(6),
                              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: () {
                                viewState.xScale = 1;
                                viewState.yScale = 1;
                                clampXY(constraints.maxHeight, constraints.maxWidth);
                                repaintNotifier.value++;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }))
      ]),
    );
  }
}

class _PianoRollViewState {
  double xOffset = 0;
  double yOffset = 0;
  double xScale = 1;
  double yScale = 1;
}

class PianoRollPainter extends CustomPainter {
  PianoRollPainter(this.project, this.themeData, this.pianoKeysWidth, this.viewState, this.selectionRect, this.curMousePos, this.modules, [this.ghostNoteRect, Listenable? repaint]) : super(repaint: repaint);
  final MuonProjectController project;
  final ThemeData themeData;
  final double pianoKeysWidth;
  final _PianoRollViewState viewState;
  final Rect? selectionRect;
  final Rect? ghostNoteRect;
  final Point<num>? curMousePos;
  final List<PianoRollModule> modules;

  double get xOffset => viewState.xOffset;
  double get yOffset => viewState.yOffset;
  double get xScale => viewState.xScale;
  double get yScale => viewState.yScale;

  final double pixelsPerBeat = 500;

  double get xPos {
    return -xOffset;
  }

  double get yPos {
    return -yOffset;
  }

  static Map<String, int> pitchMap = {
    "C": 11,
    "C#": 10,
    "D": 9,
    "D#": 8,
    "E": 7,
    "F": 6,
    "F#": 5,
    "G": 4,
    "G#": 3,
    "A": 2,
    "A#": 1,
    "B": 0,
  };
  static Map<int, String> pitchMapReverse =
      pitchMap.map((key, value) => new MapEntry(value, key));
  static double pitchToYAxis(MuonNoteController pitch) {
    return pitchToYAxisEx(pitch.note, pitch.octave);
  }

  static double pitchToYAxisEx(String note, int octave) {
    return ((pitchMap[note] ?? 0) * 20 + 12 * 20 * (8 - octave)).toDouble();
  }

  double getCurrentLeftmostBeat() {
    return xPos / pixelsPerBeat;
  }

  Point screenPosToCanvasPos(Point screenPos, bool outsideGrid) {
    if (!outsideGrid) {
      return Point(
        (screenPos.x - pianoKeysWidth) / xScale - xOffset,
        screenPos.y / yScale - yOffset,
      );
    } else {
      return Point(
        screenPos.x / xScale - xOffset,
        screenPos.y / yScale - yOffset,
      );
    }
  }

  Rect screenRectToCanvasRect(Rect screenRect, bool outsideGrid) {
    if (!outsideGrid) {
      return Rect.fromLTRB(
        (screenRect.left - pianoKeysWidth) / xScale - xOffset,
        screenRect.top / yScale - yOffset,
        (screenRect.right - pianoKeysWidth) / xScale - xOffset,
        screenRect.bottom / yScale - yOffset,
      );
    } else {
      return Rect.fromLTRB(
        screenRect.left / xScale - xOffset,
        screenRect.top / yScale - yOffset,
        screenRect.right / xScale - xOffset,
        screenRect.bottom / yScale - yOffset,
      );
    }
  }

  Point canvasPosToScreenPos(Point canvasPos, bool outsideGrid) {
    if (!outsideGrid) {
      return Point(
        (canvasPos.x + xOffset) * xScale + pianoKeysWidth,
        (canvasPos.y + yOffset) * yScale,
      );
    } else {
      return Point(
        (canvasPos.x + xOffset) * xScale,
        (canvasPos.y + yOffset) * yScale,
      );
    }
  }

  Rect deflateScaled(Rect rect,double deflateBy) {
    final deflateByX = deflateBy / xScale;
    final deflateByY = deflateBy / yScale;

    return Rect.fromLTWH(
      rect.left + deflateByX / 2,
      rect.top + deflateByY / 2,
      rect.width - deflateByX,
      rect.height - deflateByY,
    );
  }

  double getBeatNumAtCursor(double screenPosX) {
    var canvasX = screenPosX / xScale - xOffset;
    var internalCanvasX = (canvasX * xScale - pianoKeysWidth) / xScale;

    return internalCanvasX / pixelsPerBeat;
  }

  double screenPixelsToBeats(double screenPixels) {
    return (screenPixels / xScale) / pixelsPerBeat;
  }

  double screenPixelsToSemitones(double screenPixels) {
    return ((-screenPixels / yScale) / 20);
  }

  PianoRollPitch getPitchAtCursor(double screenPosY) {
    var canvasY = screenPosY / yScale - yOffset;

    var pitchDiv = (canvasY / 20).floor();
    var rawOctave = (pitchDiv / 12).floor();
    var noteID = pitchDiv - rawOctave * 12;

    var pitch = new PianoRollPitch();
    pitch.note = pitchMapReverse[noteID] ?? "C";
    pitch.octave = 8 - rawOctave;

    return pitch;
  }

  double scaleTextSize(double textSize) {
    return textSize * yScale;
  }

  /// assumes that we are currently drawing inside the grid
  void drawTextAt(Canvas canvas,Offset point,int textSize, InlineSpan text,[TextAlign textAlign = TextAlign.left]) {
    // clear all transforms
    canvas.restore();

    // draw text
    TextPainter tp = new TextPainter(
      text: text,
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      new Offset(
        (point.dx + xOffset) * xScale + pianoKeysWidth,
        (point.dy + yOffset) * yScale
      ),
    );

    // back up transforms
    canvas.save();
    
    // restore transforms
    noteCoordinateSystem(canvas);
  }

  void noteCoordinateSystem(Canvas canvas) {
    canvas.scale(xScale, yScale);
    canvas.translate(xOffset + pianoKeysWidth / xScale, yOffset);
  }

  void drawUnscaled(Canvas canvas,Function cb) {
    // clear all transforms
    canvas.restore();

    cb();

    // back up transforms
    canvas.save();
    
    // restore transforms
    noteCoordinateSystem(canvas);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Clip to viewable area
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // background fill
    final bgFill = Paint()..color = themeData.brightness == Brightness.light
      ? Color(0xFFF8F6FC)
      : Color(0xFF1E1E2E);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgFill);

    // Save current state
    canvas.save();

    // set up x axis offset for grid
    // and scale appropriately
    noteCoordinateSystem(canvas);

    // draw pitch grid
    Paint pitchGridDiv = Paint()
      ..color = (themeData.brightness == Brightness.light ? Colors.grey[200] : Colors.grey[600])!
      ..strokeWidth = 0.5;
    Paint pitchGridOctaveDiv = Paint()
      ..color = (themeData.brightness == Brightness.light ? Colors.grey[400] : Colors.white)!
      ..strokeWidth = 0.8;
    double firstVisibleKey = (yPos / 20).floorToDouble();
    int visibleKeys = ((size.height / yScale) / 20).floor();
    for (int i = 0; i <= visibleKeys; i++) {
      if ((firstVisibleKey + i) % 12 == 0) {
        canvas.drawLine(
            Offset(xPos - pianoKeysWidth * xScale, (firstVisibleKey + i) * 20),
            Offset(xPos + size.width / xScale, (firstVisibleKey + i) * 20),
            pitchGridOctaveDiv);
      } else {
        canvas.drawLine(
            Offset(xPos - pianoKeysWidth * xScale, (firstVisibleKey + i) * 20),
            Offset(xPos + size.width / xScale, (firstVisibleKey + i) * 20),
            pitchGridDiv);
      }
    }

    // draw time grid
    Paint subBeatDiv = Paint()
      ..color = (themeData.brightness == Brightness.light ? Colors.grey[200] : Colors.grey[800])!
      ..strokeWidth = 0.5;
    Paint beatDiv = Paint()
      ..color = (themeData.brightness == Brightness.light ? Colors.grey : Colors.grey[600])!
      ..strokeWidth = 0.7;
    Paint measureDiv = Paint()
      ..color = themeData.brightness == Brightness.light ? Colors.black : Colors.white
      ..strokeWidth = 1.0;
    int beats = project.beatsPerMeasure;

    double beatDuration = pixelsPerBeat;
    double leftMostBeat = getCurrentLeftmostBeat().floorToDouble();
    double leftMostBeatPos = leftMostBeat * pixelsPerBeat;
    int beatsInView = ((size.width / xScale) / beatDuration).ceil();

    for (int rawI = 0; rawI <= ((beatsInView + 1) * project.currentSubdivision); rawI++) {
      double i = rawI / project.currentSubdivision;
      var curBeatIdx = leftMostBeat + i;
      if (curBeatIdx % beats == 0) {
        canvas.drawLine(Offset(leftMostBeatPos + i * beatDuration, 0),
            Offset(leftMostBeatPos + i * beatDuration, 1920), measureDiv);
      } else if (i % 1 == 0) {
        canvas.drawLine(Offset(leftMostBeatPos + i * beatDuration, 0),
            Offset(leftMostBeatPos + i * beatDuration, 1920), beatDiv);
      } else {
        canvas.drawLine(Offset(leftMostBeatPos + i * beatDuration, 0),
            Offset(leftMostBeatPos + i * beatDuration, 1920), subBeatDiv);
      }
    }

    // draw playhead
    final playhead = Paint();
    playhead.color = themeData.indicatorColor.withValues(alpha: 0.75);
    playhead.strokeWidth = 2 / xScale;
    final playheadXVal = project.playheadTime * pixelsPerBeat;
    canvas.drawVertices(
      new Vertices(
        VertexMode.triangles,
        [
          Offset(playheadXVal - 15 / xScale,-yOffset),
          Offset(playheadXVal + 15 / xScale,-yOffset),
          Offset(playheadXVal,-yOffset + 15 / yScale),
        ]
      ), 
      BlendMode.overlay, 
      playhead
    );
    canvas.drawVertices(
      new Vertices(
        VertexMode.triangles,
        [
          Offset(playheadXVal - 15 / xScale,-yOffset + size.height / yScale),
          Offset(playheadXVal + 15 / xScale,-yOffset + size.height / yScale),
          Offset(playheadXVal,-15 / yScale + -yOffset + size.height / yScale),
        ]
      ), 
      BlendMode.overlay, 
      playhead
    );
    canvas.drawLine(Offset(playheadXVal,-yOffset + 14 / yScale),Offset(playheadXVal,-yOffset + size.height / yScale - 14 / yScale),playhead);


    for(final module in modules) {
      module.paint(canvas,size);
    }

    // draw ghost note (note creation preview)
    if (ghostNoteRect != null) {
      final ghost = ghostNoteRect!;
      final ghostRrect = RRect.fromRectAndRadius(ghost, Radius.circular(4));
      final ghostPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;
      final ghostBorder = Paint()
        ..color = Colors.blue.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 / xScale;
      canvas.drawRRect(ghostRrect, ghostPaint);
      canvas.drawRRect(ghostRrect, ghostBorder);
    }

    // set up y axis only offset
    canvas.restore();

    // back up translation
    canvas.save();

    // draw selection rect on untransformed canvas
    if(selectionRect != null) {
      final selRect = selectionRect!;
      final selRrect = RRect.fromRectAndRadius(selRect, Radius.circular(6));
      final selPaintBorder = Paint()
        ..color = Colors.blue.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      final selPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(selRrect, selPaintBorder);
      canvas.drawRRect(selRrect, selPaint);
    }

    // set up piano keys scaling
    canvas.scale(1, yScale);
    canvas.translate(0, yOffset);

    // shadow to separate keys from grid
    var shadowPath = new Path();
    shadowPath.addRect(Rect.fromLTWH(0, 0, pianoKeysWidth, 1920));
    canvas.drawShadow(shadowPath, Colors.black, 10, false);

    // right edge border
    final keyBorder = Paint()
      ..color = themeData.brightness == Brightness.light
        ? Colors.grey.withValues(alpha: 0.4)
        : Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(pianoKeysWidth, 0), Offset(pianoKeysWidth, 1920 * yScale), keyBorder);

    Paint whiteKeys = Paint()..color = themeData.brightness == Brightness.light ? Colors.white : Colors.grey[100]!;
    Paint blackKeys = Paint()..color = Colors.black;
    List<String> toDraw = [
      "B",
      "A#",
      "A",
      "G#",
      "G",
      "F#",
      "F",
      "E",
      "D#",
      "D",
      "C#",
      "C"
    ];

    double keyIdx = 0;
    for (int octave = 8; octave > 0; octave--) {
      for (int noteID = 0; noteID < toDraw.length; noteID++) {
        final note = toDraw[noteID];
        if (note.endsWith("#")) {
          canvas.drawRect(
              Rect.fromLTWH(0, (keyIdx) * 20, pianoKeysWidth, 20), blackKeys);
        } else {
          canvas.drawRect(
              Rect.fromLTWH(0, (keyIdx) * 20, pianoKeysWidth, 20), whiteKeys);
        }

        canvas.drawLine(Offset(0, (keyIdx) * 20),
            Offset(pianoKeysWidth, (keyIdx) * 20), pitchGridDiv);

        keyIdx++;
      }
    }

    // restore up translation
    canvas.restore();

    // paint piano key labels without stretch
    final labelFontSize = (12 * yScale).clamp(9.0, 16.0);
    keyIdx = 0;
    for (int octave = 8; octave > 0; octave--) {
      for (int noteID = 0; noteID < toDraw.length; noteID++) {
        var note = toDraw[noteID];
        if (!note.endsWith("#")) {
          var labelPainter = new TextPainter(
            text: new TextSpan(
                style: new TextStyle(
                    color: themeData.brightness == Brightness.light
                        ? Colors.grey[700]
                        : Colors.grey[400],
                    fontSize: labelFontSize),
                text: note + octave.toString()),
            textAlign: TextAlign.right,
            textDirection: TextDirection.ltr,
          )..layout();
          labelPainter.paint(
              canvas,
              new Offset(6,
                  ((keyIdx) * 20 + yOffset) * yScale + (20 * yScale - labelPainter.height) / 2));
        }
        keyIdx++;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
