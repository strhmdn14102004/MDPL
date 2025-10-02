import "dart:async";

import "package:flutter/foundation.dart";

class Timers with ChangeNotifier {
  static Timers? _instance;

  Timers._internal();

  static Timers getInstance() {
    _instance ??= Timers._internal();

    return _instance!;
  }

  Timer? timer;

  int countDown = 0;

  void start() {
    timer?.cancel();

    countDown = 120;

    timer = Timer.periodic(const Duration(seconds: 1), (event) {
      if (countDown < 1) {
        timer?.cancel();
        timer = null;
      } else {
        countDown = countDown - 1;
      }

      notifyListeners();
    });

    notifyListeners();
  }


  bool isRunning() {
    return timer != null;
  }
}
