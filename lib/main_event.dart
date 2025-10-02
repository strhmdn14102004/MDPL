abstract class MainEvent {}

class MainThemeChanged extends MainEvent {
  final int value;

  MainThemeChanged({
    required this.value,
  });
}
