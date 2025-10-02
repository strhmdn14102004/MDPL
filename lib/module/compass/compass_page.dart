// ignore_for_file: deprecated_member_use

import "dart:math" as math;

import "package:base/base.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:mdpl/module/compass/compass_bloc.dart";
import "package:mdpl/module/compass/compass_event.dart";
import "package:mdpl/module/compass/compass_state.dart";

class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();

  static String _directionLabel(double heading) {
    if (heading >= 337.5 || heading < 22.5) {
      return "Utara";
    }
    if (heading >= 22.5 && heading < 67.5) {
      return "Timur Laut";
    }
    if (heading >= 67.5 && heading < 112.5) {
      return "Timur";
    }
    if (heading >= 112.5 && heading < 157.5) {
      return "Tenggara";
    }
    if (heading >= 157.5 && heading < 202.5) {
      return "Selatan";
    }
    if (heading >= 202.5 && heading < 247.5) {
      return "Barat Daya";
    }
    if (heading >= 247.5 && heading < 292.5) {
      return "Barat";
    }
    if (heading >= 292.5 && heading < 337.5) {
      return "Barat Laut";
    }
    return "";
  }

  static String _directionShort(double heading) {
    if (heading >= 337.5 || heading < 22.5) {
      return "N";
    }
    if (heading >= 22.5 && heading < 67.5) {
      return "NE";
    }
    if (heading >= 67.5 && heading < 112.5) {
      return "E";
    }
    if (heading >= 112.5 && heading < 157.5) {
      return "SE";
    }
    if (heading >= 157.5 && heading < 202.5) {
      return "S";
    }
    if (heading >= 202.5 && heading < 247.5) {
      return "SW";
    }
    if (heading >= 247.5 && heading < 292.5) {
      return "W";
    }
    if (heading >= 292.5 && heading < 337.5) {
      return "NW";
    }
    return "";
  }
}

class _CompassPageState extends State<CompassPage> {
  @override
  void initState() {
    super.initState();
    context.read<CompassBloc>().add(StartCompass());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CompassBloc, CompassState>(
      listener: (context, state) {
        if (state is CompassError) {
          BaseOverlays.error(message: state.message);
        }
      },
      builder: (context, state) {
        double heading = 0;
        if (state is CompassActive) {
          heading = state.heading;
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: const Text("Kompas"),
              centerTitle: true,
              backgroundColor: Colors.black,
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.blue.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(320, 320),
                          painter: _CompassPainter(),
                        ),
                        Transform.rotate(
                          angle: heading * math.pi / 180,
                          child: Container(
                            width: 8,
                            height: 130,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.red, Colors.redAccent],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.6),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white,
                                Colors.grey.shade400,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: heading),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Text(
                        "${value.toStringAsFixed(1)}° ${CompassPage._directionShort(value)}",
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.blueAccent,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CompassPage._directionLabel(heading),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
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

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintCircle = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius - 10, paintCircle);

    TextPainter textPainter(String text, Color color, double fontSize) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      return tp;
    }

    const dirs = ["N", "E", "S", "W"];
    for (int i = 0; i < 4; i++) {
      final angle = ((i * 90) - 90) * math.pi / 180;
      final tp =
          textPainter(dirs[i], i == 0 ? Colors.redAccent : Colors.white, 24);
      tp.paint(
        canvas,
        Offset(
          center.dx + (radius - 35) * math.cos(angle) - tp.width / 2,
          center.dy + (radius - 35) * math.sin(angle) - tp.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
