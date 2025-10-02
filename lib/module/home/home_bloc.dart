import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:math" show cos, sqrt, asin, sin, pi, pow;

import "package:flutter/services.dart" show rootBundle;
import "package:flutter_bloc/flutter_bloc.dart";
import "package:geocoding/geocoding.dart";
import "package:geolocator/geolocator.dart";
import "package:http/http.dart" as http;
import "package:mdpl/module/home/home_event.dart";
import "package:mdpl/module/home/home_state.dart";
import "package:sensors_plus/sensors_plus.dart";
import "package:shared_preferences/shared_preferences.dart";

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  StreamSubscription<Position>? _gpsSub;
  StreamSubscription<BarometerEvent>? _baroSub;

  double? _latestBaroAltitude;
  List<Map<String, dynamic>> _peaks = [];

  HomeBloc() : super(HomeInitial()) {
    on<StartHomeTracking>(_onStartTracking);
    on<StopHomeTracking>(_onStopTracking);
    on<PositionUpdated>(_onPositionUpdated);
    on<BarometerUpdated>(_onBarometerUpdated);
    on<LocationNameResolved>(_onLocationNameResolved);
    on<BarometerError>(_onBarometerError);
    on<WeatherUpdated>(_onWeatherUpdated);

    on<SaveMdpl>(_onSaveMdpl);
    on<SaveLocation>(_onSaveLocation);
    on<LoadHistories>(_onLoadHistories);

    on<ClearMdplHistory>(_onClearMdplHistory);
    on<ClearLocationHistory>(_onClearLocationHistory);

    _loadPeaks();
  }

  Future<void> _loadPeaks() async {
    try {
      final jsonStr = await rootBundle.loadString("assets/peaks.json");
      final List data = jsonDecode(jsonStr);
      _peaks = data.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      _peaks = [];
    }
  }

  Future<void> _onStartTracking(
    StartHomeTracking event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        emit(HomeError("GPS tidak aktif"));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(HomeError("Izin lokasi ditolak"));
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        emit(HomeError("Izin lokasi ditolak permanen"));
        return;
      }

      _gpsSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 1,
        ),
      ).listen((pos) async {
        bool hasInternet = false;
        try {
          final result = await InternetAddress.lookup("example.com");
          hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        } catch (_) {
          hasInternet = false;
        }
        add(PositionUpdated(pos, hasInternet));
      });

      try {
        _baroSub = barometerEventStream().listen(
          (event) {
            const double p0 = 1013.25;
            double pressure = event.pressure / 100.0;
            double altitude = 44330.0 * (1.0 - pow(pressure / p0, 0.1903));
            add(BarometerUpdated(altitude));
          },
          onError: (_) {
            add(BarometerError("Device tidak memiliki sensor barometer."));
          },
          cancelOnError: true,
        );
      } catch (_) {
        add(BarometerError("Sensor barometer tidak tersedia"));
      }

      emit(HomeTracking());
      add(LoadHistories());
    } catch (e) {
      emit(HomeError("Gagal tracking: $e"));
    }
  }

  Future<void> _onStopTracking(
    StopHomeTracking event,
    Emitter<HomeState> emit,
  ) async {
    await _gpsSub?.cancel();
    await _baroSub?.cancel();
    emit(HomeInitial());
  }

  Future<void> _onPositionUpdated(
    PositionUpdated event,
    Emitter<HomeState> emit,
  ) async {
    final currentState =
        state is HomeTracking ? state as HomeTracking : HomeTracking();

    String? name = currentState.locationName;

    if (event.hasInternet) {
      _resolveLocationName(event.position.latitude, event.position.longitude);
      await _fetchWeather(event.position.latitude, event.position.longitude);
    } else {
      name =
          _findNearestPeak(event.position.latitude, event.position.longitude) ??
              name ??
              "Lokasi tidak dikenal (offline)";
    }

    emit(
      HomeTracking(
        altitude: _latestBaroAltitude ?? event.position.altitude,
        latitude: event.position.latitude,
        longitude: event.position.longitude,
        locationName: name,
        weatherCondition: currentState.weatherCondition,
        mdplHistory: currentState.mdplHistory,
        locationHistory: currentState.locationHistory,
      ),
    );
  }

  void _onBarometerUpdated(BarometerUpdated event, Emitter<HomeState> emit) {
    _latestBaroAltitude = event.altitude;
    final currentState =
        state is HomeTracking ? state as HomeTracking : HomeTracking();
    emit(
      HomeTracking(
        altitude: event.altitude,
        latitude: currentState.latitude,
        longitude: currentState.longitude,
        locationName: currentState.locationName,
        weatherCondition: currentState.weatherCondition,
        mdplHistory: currentState.mdplHistory,
        locationHistory: currentState.locationHistory,
      ),
    );
  }

  void _onLocationNameResolved(
    LocationNameResolved event,
    Emitter<HomeState> emit,
  ) {
    final currentState =
        state is HomeTracking ? state as HomeTracking : HomeTracking();
    emit(
      HomeTracking(
        altitude: currentState.altitude,
        latitude: currentState.latitude,
        longitude: currentState.longitude,
        locationName: event.locationName,
        weatherCondition: currentState.weatherCondition,
        mdplHistory: currentState.mdplHistory,
        locationHistory: currentState.locationHistory,
      ),
    );
  }

  void _onBarometerError(BarometerError event, Emitter<HomeState> emit) {
    final last = state is HomeTracking ? state as HomeTracking : HomeTracking();
    emit(HomeError(event.message));
    emit(last);
  }

  void _onWeatherUpdated(WeatherUpdated event, Emitter<HomeState> emit) {
    final currentState =
        state is HomeTracking ? state as HomeTracking : HomeTracking();
    emit(
      HomeTracking(
        altitude: currentState.altitude,
        latitude: currentState.latitude,
        longitude: currentState.longitude,
        locationName: currentState.locationName,
        weatherCondition: event.condition,
        mdplHistory: currentState.mdplHistory,
        locationHistory: currentState.locationHistory,
      ),
    );
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    try {
      final url = Uri.parse(
        "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["current_weather"] != null) {
          int code = data["current_weather"]["weathercode"];
          String condition = _mapWeatherCodeToCondition(code);
          add(WeatherUpdated(condition));
        } else {
          add(WeatherUpdated("Unknown"));
        }
      } else {
        add(WeatherUpdated("Unknown"));
      }
    } catch (_) {
      add(WeatherUpdated("Unknown"));
    }
  }

  String _mapWeatherCodeToCondition(int code) {
    if (code == 0) {
      return "Clear";
    }
    if (code == 1 || code == 2 || code == 3) {
      return "Clouds";
    }
    if (code >= 80 && code < 100) {
      return "Rain";
    }
    return "Unknown";
  }

  Future<void> _resolveLocationName(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String?>[
          place.name,
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ];
        final name = parts.where((e) => e != null && e.isNotEmpty).join(", ");
        add(LocationNameResolved(name));
      }
    } catch (_) {}
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = (lat2 - lat1) * (pi / 180);
    final dLon = (lon2 - lon1) * (pi / 180);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * asin(sqrt(a));
    return R * c;
  }

  String? _findNearestPeak(double lat, double lon) {
    if (_peaks.isEmpty) {
      return null;
    }
    double minDist = double.infinity;
    String? nearest;
    for (final p in _peaks) {
      final dist = _haversine(
        lat,
        lon,
        (p["latitude"] as num).toDouble(),
        (p["longitude"] as num).toDouble(),
      );
      if (dist < minDist) {
        minDist = dist;
        nearest = p["name"];
      }
    }
    return minDist < 20 ? nearest : null;
  }

  Future<void> _onSaveMdpl(SaveMdpl event, Emitter<HomeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final currentState =
        state is HomeTracking ? state as HomeTracking : HomeTracking();

    final list = currentState.mdplHistory.toList()
      ..add({
        "altitude": event.altitude,
        "time": DateTime.now().toIso8601String(),
      });

    await prefs.setString("mdplHistory", jsonEncode(list));
    emit(
      HomeTracking(
        altitude: currentState.altitude,
        latitude: currentState.latitude,
        longitude: currentState.longitude,
        locationName: currentState.locationName,
        weatherCondition: currentState.weatherCondition,
        mdplHistory: list,
        locationHistory: currentState.locationHistory,
      ),
    );
  }

  Future<void> _onSaveLocation(
    SaveLocation event,
    Emitter<HomeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final currentState =
        state is HomeTracking ? state as HomeTracking : HomeTracking();

    final list = currentState.locationHistory.toList()
      ..add({
        "name": event.name,
        "latitude": event.latitude,
        "longitude": event.longitude,
        "altitude": event.altitude,
        "time": DateTime.now().toIso8601String(),
      });

    await prefs.setString("locationHistory", jsonEncode(list));
    emit(
      HomeTracking(
        altitude: currentState.altitude,
        latitude: currentState.latitude,
        longitude: currentState.longitude,
        locationName: currentState.locationName,
        weatherCondition: currentState.weatherCondition,
        mdplHistory: currentState.mdplHistory,
        locationHistory: list,
      ),
    );
  }

  Future<void> _onLoadHistories(
    LoadHistories event,
    Emitter<HomeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final mdplData = prefs.getString("mdplHistory");
    final locData = prefs.getString("locationHistory");

    final mdplList = mdplData != null
        ? List<Map<String, dynamic>>.from(jsonDecode(mdplData))
        : <Map<String, dynamic>>[];

    final locList = locData != null
        ? List<Map<String, dynamic>>.from(jsonDecode(locData))
        : <Map<String, dynamic>>[];

    final currentState =
        state is HomeTracking ? state as HomeTracking : HomeTracking();

    emit(
      HomeTracking(
        altitude: currentState.altitude,
        latitude: currentState.latitude,
        longitude: currentState.longitude,
        locationName: currentState.locationName,
        weatherCondition: currentState.weatherCondition,
        mdplHistory: mdplList,
        locationHistory: locList,
      ),
    );
  }

  Future<void> _onClearMdplHistory(
    ClearMdplHistory event,
    Emitter<HomeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("mdplHistory");

    final currentState =
        state is HomeTracking ? state as HomeTracking : HomeTracking();

    emit(
      HomeTracking(
        altitude: currentState.altitude,
        latitude: currentState.latitude,
        longitude: currentState.longitude,
        locationName: currentState.locationName,
        weatherCondition: currentState.weatherCondition,
        mdplHistory: const [],
        locationHistory: currentState.locationHistory,
      ),
    );
  }

  Future<void> _onClearLocationHistory(
    ClearLocationHistory event,
    Emitter<HomeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("locationHistory");

    final currentState =
        state is HomeTracking ? state as HomeTracking : HomeTracking();

    emit(
      HomeTracking(
        altitude: currentState.altitude,
        latitude: currentState.latitude,
        longitude: currentState.longitude,
        locationName: currentState.locationName,
        weatherCondition: currentState.weatherCondition,
        mdplHistory: currentState.mdplHistory,
        locationHistory: const [],
      ),
    );
  }

  @override
  Future<void> close() {
    _gpsSub?.cancel();
    _baroSub?.cancel();
    return super.close();
  }
}
