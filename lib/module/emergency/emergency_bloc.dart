import "package:flutter_bloc/flutter_bloc.dart";
import "package:mdpl/module/emergency/emergency_event.dart";
import "package:mdpl/module/emergency/emergency_state.dart";
import "package:torch_light/torch_light.dart";
import "package:url_launcher/url_launcher.dart";

class EmergencyBloc extends Bloc<EmergencyEvent, EmergencyState> {
  bool _flashlightOn = false;

  EmergencyBloc() : super(EmergencyInitial()) {
    on<StartEmergency>((event, emit) => emit(EmergencyActive()));
    on<StopEmergency>((event, emit) => emit(EmergencyInactive()));
    on<CallSOS>(_onCallSOS);
    on<ToggleFlashlight>(_onToggleFlashlight);
  }

  Future<void> _onCallSOS(CallSOS event, Emitter<EmergencyState> emit) async {
    final Uri telUri = Uri(scheme: "tel", path: "112");
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      emit(EmergencyError("Gagal memanggil 112"));
    }
  }

  Future<void> _onToggleFlashlight(
    ToggleFlashlight event,
    Emitter<EmergencyState> emit,
  ) async {
    try {
      if (_flashlightOn) {
        await TorchLight.disableTorch();
        _flashlightOn = false;
        emit(EmergencyFlashlightOff());
      } else {
        await TorchLight.enableTorch();
        _flashlightOn = true;
        emit(EmergencyFlashlightOn());
      }
    } catch (e) {
      emit(EmergencyError("Flashlight error: $e"));
    }
  }
}
