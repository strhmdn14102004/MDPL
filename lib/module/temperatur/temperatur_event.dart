import "package:equatable/equatable.dart";

abstract class TemperatureEvent extends Equatable {
  const TemperatureEvent();

  @override
  List<Object?> get props => [];
}

class FetchTemperature extends TemperatureEvent {
  final double latitude;
  final double longitude;

  const FetchTemperature({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}
