abstract class SunState {}

class SunInitial extends SunState {}

class SunLoading extends SunState {}

class SunSuccess extends SunState {
  final String sunrise;
  final String sunset;

  SunSuccess({required this.sunrise, required this.sunset});
}

class SunError extends SunState {
  final String message;
  SunError(this.message);
}
