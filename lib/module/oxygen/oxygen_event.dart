abstract class OxygenEvent {}

class CalculateOxygen extends OxygenEvent {
  final double altitude;
  CalculateOxygen(this.altitude);
}
