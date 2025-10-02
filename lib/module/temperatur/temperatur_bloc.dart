import "dart:convert";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:http/http.dart" as http;
import "package:mdpl/module/temperatur/temperatur_event.dart";
import "package:mdpl/module/temperatur/temperatur_state.dart";

class TemperatureBloc extends Bloc<TemperatureEvent, TemperatureState> {
  TemperatureBloc() : super(TemperatureInitial()) {
    on<FetchTemperature>(_onFetchTemperature);
  }

  Future<void> _onFetchTemperature(
    FetchTemperature event,
    Emitter<TemperatureState> emit,
  ) async {
    try {
      emit(TemperatureLoading());

      final url =
          "https://api.open-meteo.com/v1/forecast?latitude=${event.latitude}&longitude=${event.longitude}&current_weather=true";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final temp = data["current_weather"]["temperature"] as num;

        emit(
          TemperatureSuccess(
            temperature: temp.toDouble(),
            locationName:
                "Lat: ${event.latitude.toStringAsFixed(2)}, Lon: ${event.longitude.toStringAsFixed(2)}",
          ),
        );
      } else {
        emit(
          TemperatureError("Gagal ambil data suhu (${response.statusCode})"),
        );
      }
    } catch (e) {
      emit(TemperatureError("Terjadi kesalahan: $e"));
    }
  }
}
