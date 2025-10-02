import "package:base/base.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:mdpl/module/emergency/emergency_bloc.dart";
import "package:mdpl/module/emergency/emergency_event.dart";
import "package:mdpl/module/emergency/emergency_state.dart";

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmergencyBloc, EmergencyState>(
      listener: (context, state) async {
        if (state is EmergencyError) {
          await BaseOverlays.error(message: state.message);
        }
      },
      builder: (context, state) {
        final flashlightOn = state is EmergencyFlashlightOn;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.red,
            statusBarIconBrightness: Brightness.light,
          ),
          child: SafeArea(
            child: Scaffold(
              body: Column(
                children: [
                  ClipPath(
                    clipper: _EmergencyClipper(),
                    child: Container(
                      width: double.infinity,
                      height: 220,
                      color: Colors.red,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "EMERGENCY",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Gunakan fitur SOS atau nyalakan lampu darurat",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(60),
                            ),
                            onPressed: () {
                              context.read<EmergencyBloc>().add(CallSOS());
                            },
                            child: const Text(
                              "SOS",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: flashlightOn
                                  ? Colors.yellow.shade700
                                  : Colors.grey.shade800,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                            onPressed: () {
                              context
                                  .read<EmergencyBloc>()
                                  .add(ToggleFlashlight());
                            },
                            icon: Icon(
                              flashlightOn
                                  ? Icons.flashlight_on
                                  : Icons.flashlight_off,
                              color: Colors.white,
                            ),
                            label: Text(
                              flashlightOn ? "Matikan Lampu" : "Nyalakan Lampu",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmergencyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..lineTo(0, size.height - 50)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
