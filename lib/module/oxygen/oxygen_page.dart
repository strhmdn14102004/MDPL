// ignore_for_file: deprecated_member_use

import "package:base/base.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:mdpl/module/oxygen/oxygen_bloc.dart";
import "package:mdpl/module/oxygen/oxygen_event.dart";
import "package:mdpl/module/oxygen/oxygen_state.dart";

class OxygenPage extends StatefulWidget {
  final double altitude;

  const OxygenPage({required this.altitude, super.key});

  @override
  State<OxygenPage> createState() => _OxygenPageState();
}

class _OxygenPageState extends State<OxygenPage> {
  @override
  void initState() {
    super.initState();
    context.read<OxygenBloc>().add(CalculateOxygen(widget.altitude));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OxygenBloc, OxygenState>(
      listener: (context, state) {
        if (state is OxygenError) {
          BaseOverlays.error(message: state.message);
        }
      },
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.green,
            statusBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: const Text("Level Oksigen"),
              backgroundColor: Colors.green,
              centerTitle: true,
              elevation: 0,
            ),
            body: Center(
              child: _buildBody(state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(OxygenState state) {
    if (state is OxygenLoading) {
       return BaseWidgets.shimmer();
    }

    if (state is OxygenSuccess) {
      final double percentage = (state.oxygenLevel / 20.9).clamp(0.0, 1.0);

      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.air, color: Colors.white, size: 80),
            ),
            const SizedBox(height: 30),
            Text(
              "${state.oxygenLevel.toStringAsFixed(1)}%",
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Pada ketinggian ${state.altitude.toStringAsFixed(0)} mdpl",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 20,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage > 0.6
                      ? Colors.green
                      : (percentage > 0.3 ? Colors.orange : Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              percentage > 0.6
                  ? "Oksigen Normal"
                  : (percentage > 0.3
                      ? "Oksigen Rendah, hati-hati!"
                      : "Bahaya! Oksigen sangat rendah"),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: percentage > 0.6
                    ? Colors.green
                    : (percentage > 0.3 ? Colors.orange : Colors.red),
              ),
            ),
            const SizedBox(height: 50),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              ),
              onPressed: () {
                context.read<OxygenBloc>().add(CalculateOxygen(state.altitude));
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                "HITUNG ULANG",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (state is OxygenError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 80, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            state.message,
            style: const TextStyle(fontSize: 18, color: Colors.red),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              context.read<OxygenBloc>().add(CalculateOxygen(widget.altitude));
            },
            child: const Text("Coba Lagi"),
          ),
        ],
      );
    }

    return const Text("Belum ada data oksigen");
  }
}
