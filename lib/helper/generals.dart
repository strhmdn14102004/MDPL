import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

class Generals {
  static BuildContext? context() {
    return Get.context;
  }

  static GlobalKey<NavigatorState> navigatorState() {
    return Get.key;
  }

  static void changeLanguage({
    required String locale,
  }) async {
    if (context() != null) {
      context()!.setLocale(Locale.fromSubtags(languageCode: locale));

      Locale newLocale = Locale(locale);

      await context()!.setLocale(newLocale);

      Get.updateLocale(newLocale);
    }
  }
}
