import "dart:async";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_compass/flutter_compass.dart" as fc;
import "package:mdpl/module/compass/compass_event.dart";
import "package:mdpl/module/compass/compass_state.dart";

class CompassBloc extends Bloc<CompassEvent, CompassState> {
  StreamSubscription<fc.CompassEvent>? _compassSub;

  CompassBloc() : super(CompassInitial()) {
    on<StartCompass>(_onStart);
    on<StopCompass>(_onStop);
    on<UpdateCompass>(_onUpdate);
  }

  Future<void> _onStart(StartCompass event, Emitter<CompassState> emit) async {
    _compassSub = fc.FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        double heading = event.heading!;
        if (heading < 0) {
          heading += 360;
        }
        add(UpdateCompass(heading));
      }
    });
  }

  Future<void> _onStop(StopCompass event, Emitter<CompassState> emit) async {
    await _compassSub?.cancel();
    emit(CompassInactive());
  }

  void _onUpdate(UpdateCompass event, Emitter<CompassState> emit) {
    emit(CompassActive(event.heading));
  }

  @override
  Future<void> close() {
    _compassSub?.cancel();
    return super.close();
  }
}
