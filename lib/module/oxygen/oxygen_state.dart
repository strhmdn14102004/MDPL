abstract class OxygenState {}

class OxygenInitial extends OxygenState {}

class OxygenLoading extends OxygenState {}

class OxygenSuccess extends OxygenState {
  final double oxygenLevel;
  final double altitude;
  OxygenSuccess({required this.oxygenLevel, required this.altitude});
}

class OxygenError extends OxygenState {
  final String message;
  OxygenError(this.message);
}
