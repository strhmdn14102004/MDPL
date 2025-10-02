import "dart:convert";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:http/http.dart" as http;
import "package:mdpl/module/sun/sun_event.dart";
import "package:mdpl/module/sun/sun_state.dart";

class SunBloc extends Bloc<SunEvent, SunState> {
  SunBloc() : super(SunInitial()) {
    on<FetchSunData>(_onFetch);
  }

  Future<void> _onFetch(FetchSunData event, Emitter<SunState> emit) async {
    emit(SunLoading());
    try {
      final url = Uri.parse(
        "https://api.sunrise-sunset.org/json?lat=${event.latitude}&lng=${event.longitude}&formatted=0",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final sunrise = data["results"]["sunrise"];
        final sunset = data["results"]["sunset"];

        emit(SunSuccess(sunrise: sunrise, sunset: sunset));
      } else {
        emit(SunError("Gagal memuat data (${response.statusCode})"));
      }
    } catch (e) {
      emit(SunError("Error: $e"));
    }
  }
}
