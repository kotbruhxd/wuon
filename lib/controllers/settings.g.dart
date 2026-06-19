// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// ObservableGenerator
// **************************************************************************

class $MuonSettingsController extends MuonSettingsController
    with SynapsControllerInterface<MuonSettingsController> {
  @override
  final MuonSettingsController boxedValue;
  @override
  bool get darkMode {
    synapsMarkVariableRead(#darkMode);
    return boxedValue.darkMode;
  }

  @override
  set darkMode(bool value) {
    boxedValue.darkMode = value;
    synapsMarkVariableDirty(#darkMode, value);
  }

  $MuonSettingsController(this.boxedValue) : super();
}

extension MuonSettingsControllerExtension on MuonSettingsController {
  $MuonSettingsController asController() {
    if (this is $MuonSettingsController) return this as $MuonSettingsController;
    return $MuonSettingsController(this);
  }

  $MuonSettingsController ctx() => asController();
  MuonSettingsController get boxedValue => this;
}
