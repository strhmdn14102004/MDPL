abstract class TemperatureState {}

class TemperatureInitial extends TemperatureState {}

class TemperatureLoading extends TemperatureState {}

class TemperatureSuccess extends TemperatureState {
  final double temperature;
  final String locationName;

  TemperatureSuccess({
    required this.temperature,
    required this.locationName,
  });
}

class TemperatureError extends TemperatureState {
  final String message;
  TemperatureError(this.message);
}
