abstract class EmergencyState {}

class EmergencyInitial extends EmergencyState {}

class EmergencyActive extends EmergencyState {}

class EmergencyInactive extends EmergencyState {}

class EmergencyFlashlightOn extends EmergencyState {}

class EmergencyFlashlightOff extends EmergencyState {}

class EmergencyError extends EmergencyState {
  final String message;
  EmergencyError(this.message);
}
