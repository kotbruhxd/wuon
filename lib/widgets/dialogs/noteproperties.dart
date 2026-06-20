import 'package:flutter/material.dart';
import 'package:wuon/actions/base.dart';
import 'package:wuon/controllers/muonnote.dart';
import 'package:wuon/controllers/muonproject.dart';
import 'package:wuon/logic/japanese.dart';

class NotePropertiesDialog extends StatefulWidget {
  final MuonNoteController note;
  final MuonProjectController project;

  const NotePropertiesDialog({super.key, required this.note, required this.project});

  @override
  State<NotePropertiesDialog> createState() => _NotePropertiesDialogState();
}

class _NotePropertiesDialogState extends State<NotePropertiesDialog> {
  late TextEditingController _lyricCtrl;
  late int _tune;
  late bool _vibOn;
  late double _vibDepth;
  late double _vibFreq;
  late double _vibAttack;
  bool _changed = false;

  static const _presets = {
    'Off':       [0.0, 5.5, 0.1],
    'Light':     [10.0, 6.5, 0.15],
    'Medium':    [25.0, 5.5, 0.15],
    'Wide':      [45.0, 5.0, 0.2],
    'Fast':      [15.0, 8.5, 0.1],
    'Slow':      [25.0, 3.5, 0.25],
  };

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    _lyricCtrl = TextEditingController(text: n.lyric);
    _tune = n.tune;
    _vibOn = n.vibratoEnabled;
    _vibDepth = n.vibratoDepth;
    _vibFreq = n.vibratoFrequency;
    _vibAttack = n.vibratoAttack;
  }

  @override
  void dispose() {
    _lyricCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    final n = widget.note;
    n.lyric = _lyricCtrl.text;
    if (_tune != n.tune) {
      final old = n.tune;
      n.tune = _tune;
      widget.project.addAction(SetNoteTuneAction(n, _tune, old));
    }
    n.vibratoEnabled = _vibOn;
    n.vibratoDepth = _vibDepth;
    n.vibratoFrequency = _vibFreq;
    n.vibratoAttack = _vibAttack;
  }

  void _applyPreset(String label) {
    final v = _presets[label]!;
    setState(() {
      _vibOn = label != 'Off';
      _vibDepth = v[0];
      _vibFreq = v[1];
      _vibAttack = v[2];
    });
  }

  String _currentPreset() {
    for (final e in _presets.entries) {
      if ((e.value[0] - _vibDepth).abs() < 0.5 &&
          (e.value[1] - _vibFreq).abs() < 0.1 &&
          (e.value[2] - _vibAttack).abs() < 0.05) {
        return e.key;
      }
    }
    return 'Custom';
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final midiNames = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"];
    final noteLabel = "${note.note}${note.octave}";

    return AlertDialog(
      title: Row(
        children: [
          Text("Note Properties"),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(noteLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Lyric --
              TextField(
                controller: _lyricCtrl,
                decoration: InputDecoration(
                  labelText: 'Lyric',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (text) {
                  final converted = JapaneseUTF8.alphabetToHiragana(text).join("");
                  if (converted != text) {
                    _lyricCtrl.value = TextEditingValue(
                      text: converted,
                      selection: TextSelection.collapsed(offset: converted.length),
                    );
                  }
                },
              ),
              SizedBox(height: 16),

              // -- Tune --
              Row(
                children: [
                  Text('Tune', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.remove, size: 18),
                    constraints: BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                    onPressed: () => setState(() => _tune = (_tune - 1).clamp(-12, 12)),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text("${_tune >= 0 ? "+" : ""}$_tune st",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: 18),
                    constraints: BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                    onPressed: () => setState(() => _tune = (_tune + 1).clamp(-12, 12)),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // -- Vibrato enable --
              Row(
                children: [
                  Text('Vibrato', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  SizedBox(width: 8),
                  Switch(
                    value: _vibOn,
                    onChanged: (v) => setState(() => _vibOn = v),
                  ),
                  Spacer(),
                  // Preset dropdown
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade600),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButton<String>(
                      value: _currentPreset(),
                      underline: SizedBox.shrink(),
                      isDense: true,
                      items: _presets.keys.map((l) => DropdownMenuItem(
                        value: l,
                        child: Text(l, style: TextStyle(fontSize: 12)),
                      )).toList(),
                      onChanged: (v) { if (v != null) _applyPreset(v); },
                    ),
                  ),
                ],
              ),
              if (_vibOn) ...[
                SizedBox(height: 12),
                // Depth slider
                Row(
                  children: [
                    SizedBox(width: 80, child: Text('Depth', style: TextStyle(fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _vibDepth,
                        min: 0, max: 100,
                        divisions: 40,
                        label: '${_vibDepth.round()} ct',
                        onChanged: (v) => setState(() => _vibDepth = v),
                      ),
                    ),
                    SizedBox(width: 40, child: Text('${_vibDepth.round()} ct', style: TextStyle(fontSize: 11))),
                  ],
                ),
                // Frequency slider
                Row(
                  children: [
                    SizedBox(width: 80, child: Text('Freq', style: TextStyle(fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _vibFreq,
                        min: 1, max: 12,
                        divisions: 44,
                        label: '${_vibFreq.toStringAsFixed(1)} Hz',
                        onChanged: (v) => setState(() => _vibFreq = v),
                      ),
                    ),
                    SizedBox(width: 40, child: Text('${_vibFreq.toStringAsFixed(1)} Hz', style: TextStyle(fontSize: 11))),
                  ],
                ),
                // Attack slider
                Row(
                  children: [
                    SizedBox(width: 80, child: Text('Attack', style: TextStyle(fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _vibAttack,
                        min: 0, max: 0.5,
                        divisions: 20,
                        label: '${(_vibAttack * 100).round()} %',
                        onChanged: (v) => setState(() => _vibAttack = v),
                      ),
                    ),
                    SizedBox(width: 40, child: Text('${(_vibAttack * 100).round()} %', style: TextStyle(fontSize: 11))),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _apply();
            Navigator.of(context).pop(true);
          },
          child: Text('Apply'),
        ),
      ],
    );
  }
}
