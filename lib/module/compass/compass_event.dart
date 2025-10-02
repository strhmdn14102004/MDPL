abstract class CompassEvent {}

class StartCompass extends CompassEvent {}

class StopCompass extends CompassEvent {}

class UpdateCompass extends CompassEvent {
  final double heading;
  UpdateCompass(this.heading);
}
