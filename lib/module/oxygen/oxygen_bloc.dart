import "dart:async";
import "dart:math" as math;

import "package:flutter_bloc/flutter_bloc.dart";
import "package:mdpl/module/oxygen/oxygen_event.dart";
import "package:mdpl/module/oxygen/oxygen_state.dart";

class OxygenBloc extends Bloc<OxygenEvent, OxygenState> {
  OxygenBloc() : super(OxygenInitial()) {
    on<CalculateOxygen>(_onCalculate);
  }

  Future<void> _onCalculate(
    CalculateOxygen event,
    Emitter<OxygenState> emit,
  ) async {
    try {
      emit(OxygenLoading());

      final oxygen = 20.9 * math.exp(-event.altitude / 7000);

      await Future.delayed(const Duration(milliseconds: 600));

      emit(
        OxygenSuccess(
          oxygenLevel: oxygen,
          altitude: event.altitude,
        ),
      );
    } catch (e) {
      emit(OxygenError("Gagal menghitung level oksigen: $e"));
    }
  }
}
