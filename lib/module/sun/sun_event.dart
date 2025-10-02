abstract class SunEvent {}

class FetchSunData extends SunEvent {
  final double latitude;
  final double longitude;

  FetchSunData({required this.latitude, required this.longitude});
}
