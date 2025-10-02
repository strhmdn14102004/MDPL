// ignore_for_file: prefer_collection_literals, cascade_invocations, depend_on_referenced_packages

import "package:flutter/material.dart";
import "package:intl/intl.dart";

extension TimeOfDayExtension on TimeOfDay {
  int compareTo(TimeOfDay other) {
    if (hour < other.hour) {
      return -1;
    }

    if (hour > other.hour) {
      return 1;
    }

    if (minute < other.minute) {
      return -1;
    }

    if (minute > other.minute) {
      return 1;
    }

    return 0;
  }
}

extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = Set();
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

extension MoveElement<T> on List<T> {
  void move(int from, int to) {
    RangeError.checkValidIndex(from, this, "from", length);
    RangeError.checkValidIndex(to, this, "to", length);
    var element = this[from];
    if (from < to) {
      setRange(from, to, this, from + 1);
    } else {
      setRange(to + 1, from + 1, this, to);
    }
    this[to] = element;
  }
}


extension NumberExtension on num {
  String currency() {
    NumberFormat numberFormat = NumberFormat("#,###.##", "id");

    return numberFormat.format(this);
  }

  String shortHand() {
    if (this >= 1000000000) {
      return '${(this / 1000000000).toStringAsFixed(1).replaceAll(RegExp(r"\.0$"), '')}B';
    } else if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1).replaceAll(RegExp(r"\.0$"), '')}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1).replaceAll(RegExp(r"\.0$"), '')}K';
    } else {
      return toString();
    }
  }
}

extension BoolParsing on String {
  bool parseBool() {
    return toLowerCase() == "true";
  }
}

extension MapExtension<K, V> on Map<K, V> {
  Map<K, V> append(Map<K, V> map) {
    addAll(map);

    return this;
  }
}
