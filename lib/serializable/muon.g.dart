// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MuonNote _$MuonNoteFromJson(Map<String, dynamic> json) => MuonNote()
  ..note = json['note'] as String
  ..octave = (json['octave'] as num).toInt()
  ..lyric = json['lyric'] as String
  ..startAtTime = (json['startAtTime'] as num).toInt()
  ..duration = (json['duration'] as num).toInt()
  ..tune = (json['tune'] as num).toInt()
  ..pitchPoints = (json['pitchPoints'] as List<dynamic>)
      .map((e) => PitchPoint.fromJson(e as Map<String, dynamic>))
      .toList()
  ..vibratoEnabled = json['vibratoEnabled'] as bool
  ..vibratoDepth = (json['vibratoDepth'] as num).toDouble()
  ..vibratoFrequency = (json['vibratoFrequency'] as num).toDouble()
  ..vibratoAttack = (json['vibratoAttack'] as num).toDouble();

Map<String, dynamic> _$MuonNoteToJson(MuonNote instance) => <String, dynamic>{
      'note': instance.note,
      'octave': instance.octave,
      'lyric': instance.lyric,
      'startAtTime': instance.startAtTime,
      'duration': instance.duration,
      'tune': instance.tune,
      'pitchPoints': instance.pitchPoints,
      'vibratoEnabled': instance.vibratoEnabled,
      'vibratoDepth': instance.vibratoDepth,
      'vibratoFrequency': instance.vibratoFrequency,
      'vibratoAttack': instance.vibratoAttack,
    };

PitchPoint _$PitchPointFromJson(Map<String, dynamic> json) => PitchPoint(
      (json['offset'] as num).toInt(),
      (json['cents'] as num).toDouble(),
    );

Map<String, dynamic> _$PitchPointToJson(PitchPoint instance) =>
    <String, dynamic>{
      'offset': instance.offset,
      'cents': instance.cents,
    };

MuonVoice _$MuonVoiceFromJson(Map<String, dynamic> json) => MuonVoice()
  ..modelName = json['modelName'] as String
  ..randomiseTiming = json['randomiseTiming'] as bool
  ..tune = (json['tune'] as num).toInt()
  ..transpose = (json['transpose'] as num).toInt()
  ..notes = (json['notes'] as List<dynamic>)
      .map((e) => MuonNote.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$MuonVoiceToJson(MuonVoice instance) => <String, dynamic>{
      'modelName': instance.modelName,
      'randomiseTiming': instance.randomiseTiming,
      'tune': instance.tune,
      'transpose': instance.transpose,
      'notes': instance.notes,
    };

MuonProject _$MuonProjectFromJson(Map<String, dynamic> json) => MuonProject()
  ..bpm = (json['bpm'] as num).toDouble()
  ..timeUnitsPerBeat = (json['timeUnitsPerBeat'] as num).toInt()
  ..beatsPerMeasure = (json['beatsPerMeasure'] as num).toInt()
  ..beatValue = (json['beatValue'] as num).toInt()
  ..voices = (json['voices'] as List<dynamic>)
      .map((e) => MuonVoice.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$MuonProjectToJson(MuonProject instance) =>
    <String, dynamic>{
      'bpm': instance.bpm,
      'timeUnitsPerBeat': instance.timeUnitsPerBeat,
      'beatsPerMeasure': instance.beatsPerMeasure,
      'beatValue': instance.beatValue,
      'voices': instance.voices,
    };
