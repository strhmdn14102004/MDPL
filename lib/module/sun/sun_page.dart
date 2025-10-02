// ignore_for_file: deprecated_member_use

import "package:base/base.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:intl/intl.dart";
import "package:mdpl/module/sun/sun_bloc.dart";
import "package:mdpl/module/sun/sun_event.dart";
import "package:mdpl/module/sun/sun_state.dart";

class SunPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const SunPage({
    required this.latitude,
    required this.longitude,
    super.key,
  });

  @override
  State<SunPage> createState() => _SunPageState();
}

class _SunPageState extends State<SunPage> {
  @override
  void initState() {
    super.initState();
    context.read<SunBloc>().add(
          FetchSunData(
            latitude: widget.latitude,
            longitude: widget.longitude,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SunBloc, SunState>(
      listener: (context, state) {
        if (state is SunError) {
          BaseOverlays.error(message: state.message);
        }
      },
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text("Sunrise & Sunset"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              centerTitle: true,
            ),
            body: Center(
              child: _buildBody(state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(SunState state) {
    if (state is SunLoading) {
      return BaseWidgets.shimmer();
    }

    if (state is SunSuccess) {
      final sunriseDt = DateTime.parse(state.sunrise).toLocal();
      final sunsetDt = DateTime.parse(state.sunset).toLocal();

      final sunrise =
          DateFormat("dd MMMM yyyy 'Pukul' HH.mm", "id_ID").format(sunriseDt);
      final sunset =
          DateFormat("dd MMMM yyyy 'Pukul' HH.mm", "id_ID").format(sunsetDt);

      final duration = sunsetDt.difference(sunriseDt);
      final durationStr =
          "${duration.inHours} jam ${duration.inMinutes.remainder(60)} menit";

      return SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.size25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: Dimensions.size50),
              alignment: Alignment.center,
              child: Icon(
                Icons.wb_sunny_rounded,
                color: Colors.orange.shade600,
                size: Dimensions.size100 * 2,
              ),
            ),
            _buildInfoCard(
              title: "Matahari Terbit",
              value: sunrise,
              icon: Icons.wb_twighlight,
              color: Colors.orange,
            ),
            SizedBox(height: Dimensions.size15),
            _buildInfoCard(
              title: "Matahari Terbenam",
              value: sunset,
              icon: Icons.nightlight_round,
              color: Colors.deepPurple,
            ),
            SizedBox(height: Dimensions.size15),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 1,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.timer, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Durasi Siang: $durationStr",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state is SunError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            state.message,
            style: const TextStyle(fontSize: 18, color: Colors.red),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () {
              context.read<SunBloc>().add(
                    FetchSunData(
                      latitude: widget.latitude,
                      longitude: widget.longitude,
                    ),
                  );
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label:
                const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    }

    return const Text("Belum ada data");
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
