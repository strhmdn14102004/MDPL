abstract class EmergencyEvent {}

class StartEmergency extends EmergencyEvent {}

class StopEmergency extends EmergencyEvent {}

class CallSOS extends EmergencyEvent {}

class ToggleFlashlight extends EmergencyEvent {}
