abstract class CompassState {}

class CompassInitial extends CompassState {}

class CompassActive extends CompassState {
  final double heading;
  CompassActive(this.heading);
}

class CompassInactive extends CompassState {}

class CompassError extends CompassState {
  final String message;
  CompassError(this.message);
}
