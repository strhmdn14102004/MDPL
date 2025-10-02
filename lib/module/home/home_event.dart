import "package:geolocator/geolocator.dart";

abstract class HomeEvent {}

class StartHomeTracking extends HomeEvent {}

class StopHomeTracking extends HomeEvent {}

class PositionUpdated extends HomeEvent {
  final Position position;
  final bool hasInternet;
  PositionUpdated(this.position, this.hasInternet);
}

class BarometerUpdated extends HomeEvent {
  final double altitude;
  BarometerUpdated(this.altitude);
}

class LocationNameResolved extends HomeEvent {
  final String locationName;
  LocationNameResolved(this.locationName);
}

class BarometerError extends HomeEvent {
  final String message;
  BarometerError(this.message);
}

class WeatherUpdated extends HomeEvent {
  final String condition;
  WeatherUpdated(this.condition);
}

class SaveMdpl extends HomeEvent {
  final double altitude;
  SaveMdpl(this.altitude);
}

class SaveLocation extends HomeEvent {
  final String name;
  final double latitude;
  final double longitude;
  final double altitude;
  SaveLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.altitude,
  });
}

class LoadHistories extends HomeEvent {}

class ClearMdplHistory extends HomeEvent {}

class ClearLocationHistory extends HomeEvent {}
