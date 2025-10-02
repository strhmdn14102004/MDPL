// ignore_for_file: depend_on_referenced_packages

import "package:basic_utils/basic_utils.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:mdpl/helper/extensions.dart";

class Formats {
  static String spell(dynamic value) {
    if (value != null) {
      if (value is String) {
        return value;
      } else if (value is num) {
        return value.currency();
      } else if (value is bool) {
        return value ? "yes".tr() : "no".tr();
      } else if (value is DateTime) {
        return dateTimeAlternative(dateTime: value);
      } else {
        return value.toString();
      }
    } else {
      return "";
    }
  }

  static final _currencyFormat = NumberFormat.currency(
    locale: "id_ID",
    symbol: "Rp ",
    decimalDigits: 0,
  );

  static String currency(int amount) {
    return _currencyFormat.format(amount);
  }

  static DateTime? tryParseDate(dynamic value) {
    if (value != null) {
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {}
      } else if (value is int) {
        try {
          return DateTime.fromMillisecondsSinceEpoch(value);
        } catch (_) {}
      }
    }
    return null;
  }

  static TimeOfDay? parseTime(String? string) {
    if (StringUtils.isNotNullOrEmpty(string)) {
      return TimeOfDay(
        hour: int.parse(string!.split(":")[0]),
        minute: int.parse(string.split(":")[1]),
      );
    }
    return null;
  }

  static num tryParseNumber(dynamic value) {
    if (value != null) {
      if (value is String) {
        try {
          return NumberFormat("", "id").parse(value);
        } catch (_) {
          return num.tryParse(value) ?? 0;
        }
      } else if (value is int || value is double) {
        return value;
      }
    }
    return 0;
  }

  static bool tryParseBool(dynamic value) {
    if (value != null) {
      if (value is String) {
        return bool.tryParse(value) ?? false;
      } else if (value is int) {
        return value == 1;
      } else if (value is bool) {
        return value;
      }
    }
    return false;
  }

  static String date({
    DateTime? dateTime,
    String defaultString = "",
  }) {
    if (dateTime != null) {
      return DateFormat("d MMM ''yy", "id").format(dateTime.toLocal());
    } else {
      return defaultString;
    }
  }

  static String dateTime({
    DateTime? dateTime,
    String defaultString = "",
  }) {
    if (dateTime != null) {
      return DateFormat("d MMM ''yy HH:mm", "id").format(dateTime.toLocal());
    } else {
      return defaultString;
    }
  }

  static String time({
    DateTime? dateTime,
    String defaultString = "",
  }) {
    if (dateTime != null) {
      return DateFormat("HH:mm", "id").format(dateTime.toLocal());
    } else {
      return defaultString;
    }
  }

  static String dateAlternative({
    DateTime? dateTime,
    String defaultString = "",
  }) {
    return date(dateTime: dateTime, defaultString: defaultString);
  }

  static String dateTimeAlternative({
    DateTime? dateTime,
    String defaultString = "",
  }) {
    return dateTime != null
        ? DateFormat("d MMM ''yy HH:mm", "id").format(dateTime.toLocal())
        : defaultString;
  }

  static String timeAlternative({
    TimeOfDay? timeOfDay,
    String defaultString = "",
  }) {
    if (timeOfDay != null) {
      return const DefaultMaterialLocalizations()
          .formatTimeOfDay(timeOfDay, alwaysUse24HourFormat: true);
    } else {
      return defaultString;
    }
  }

  static Map<String, dynamic> convert(Map<String, dynamic> map) {
    map.forEach((key, value) {
      if (value != null) {
        if (value is DateTime) {
          map[key] = DateFormat("yyyy-MM-ddTHH:mm:ss").format(value.toUtc());
        } else if (value is List) {
          for (var i = 0; i < value.length; i++) {
            var item = value[i];
            if (item is DateTime) {
              value[i] = DateFormat("yyyy-MM-ddTHH:mm:ss").format(item.toUtc());
            } else if (item is Map<String, dynamic>) {
              convert(item);
            }
          }
        }
      }
    });
    return map;
  }

  static String initials(String string) {
    int length = 2;
    List<String> strings = string.trim().split(" ");
    length = strings.length < length ? strings.length : length;

    String result = "";
    for (var i = 0; i < length; i++) {
      result += strings[i][0];
    }

    return result.toUpperCase();
  }

  static String coalesce(String? value, {String? defaultString}) {
    return StringUtils.isNotNullOrEmpty(value)
        ? value!
        : defaultString ?? "n/a".tr();
  }
}
