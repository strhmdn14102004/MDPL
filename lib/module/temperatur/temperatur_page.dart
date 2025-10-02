import "package:base/base.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:mdpl/module/temperatur/temperatur_bloc.dart";
import "package:mdpl/module/temperatur/temperatur_event.dart";
import "package:mdpl/module/temperatur/temperatur_state.dart";

class TemperaturePage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const TemperaturePage({
    required this.latitude,
    required this.longitude,
    super.key,
  });

  @override
  State<TemperaturePage> createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  @override
  void initState() {
    super.initState();
    context.read<TemperatureBloc>().add(
          FetchTemperature(
            latitude: widget.latitude,
            longitude: widget.longitude,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TemperatureBloc, TemperatureState>(
      listener: (context, state) {
        if (state is TemperatureError) {
          BaseOverlays.error(message: state.message);
        }
      },
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text("Suhu Sekitar"),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              foregroundColor: Colors.black87,
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: () {
                context.read<TemperatureBloc>().add(
                      FetchTemperature(
                        latitude: widget.latitude,
                        longitude: widget.longitude,
                      ),
                    );
              },
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
            body: _buildBody(state),
          ),
        );
      },
    );
  }

  Widget _buildBody(TemperatureState state) {
    if (state is TemperatureLoading) {
      return BaseWidgets.shimmer();
    }

    if (state is TemperatureSuccess) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.thermostat, size: 100, color: Colors.orange.shade400),
            const SizedBox(height: 20),
            Text(
              "${state.temperature.toStringAsFixed(1)}°C",
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              state.locationName,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    if (state is TemperatureError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 80, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return const Center(
      child: Text(
        "Belum ada data suhu",
        style: TextStyle(color: Colors.grey, fontSize: 18),
      ),
    );
  }
}
