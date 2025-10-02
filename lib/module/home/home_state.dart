abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeTracking extends HomeState {
  final double? altitude;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String? weatherCondition;

  final List<Map<String, dynamic>> mdplHistory;
  final List<Map<String, dynamic>> locationHistory;

  HomeTracking({
    this.altitude,
    this.latitude,
    this.longitude,
    this.locationName,
    this.weatherCondition,
    this.mdplHistory = const [],
    this.locationHistory = const [],
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
