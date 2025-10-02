// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import "dart:async";

import "package:base/base.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_speed_dial/flutter_speed_dial.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:intl/intl.dart";
import "package:lottie/lottie.dart";
import "package:mdpl/module/compass/compass_page.dart";
import "package:mdpl/module/emergency/emergency_page.dart";
import "package:mdpl/module/home/home_bloc.dart";
import "package:mdpl/module/home/home_event.dart";
import "package:mdpl/module/home/home_state.dart";
import "package:mdpl/module/oxygen/oxygen_page.dart";
import "package:mdpl/module/sun/sun_page.dart";
import "package:mdpl/module/temperatur/temperatur_page.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool is24h = true;
  bool isDark = false;
  final PageController _pageController = PageController(initialPage: 1);

  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now());
    });
    context.read<HomeBloc>().add(StartHomeTracking());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeError) {
          BaseOverlays.error(message: state.message);
        }
      },
      builder: (context, state) {
        final bgColor = isDark ? Colors.black : Colors.grey[100];
        final textColor = isDark ? Colors.white : Colors.black;
        final timeFormat = is24h ? "HH:mm" : "hh:mm a";
        final formattedTime = DateFormat(timeFormat).format(_now);
        final formattedDate = DateFormat("d MMMM y", "id_ID").format(_now);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: bgColor,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
          child: SafeArea(
            child: Scaffold(
              backgroundColor: bgColor,
              body: state is HomeTracking
                  ? Stack(
                      children: [
                        if (state.weatherCondition != null)
                          Positioned.fill(
                            child: _buildWeatherBackground(
                              state.weatherCondition!,
                            ),
                          ),
                        Column(
                          children: [
                            Expanded(
                              child: PageView(
                                controller: _pageController,
                                children: [
                                  _buildMdplHistory(state),
                                  _buildMainContent(
                                    state,
                                    textColor,
                                    formattedTime,
                                    formattedDate,
                                  ),
                                  _buildLocationHistory(state),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SmoothPageIndicator(
                                controller: _pageController,
                                count: 3,
                                effect: WormEffect(
                                  dotHeight: 10,
                                  dotWidth: 10,
                                  spacing: 12,
                                  dotColor: Colors.grey.shade400,
                                  activeDotColor: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        _buildInfoButton(textColor),
                      ],
                    )
                  : BaseWidgets.shimmer(),
              floatingActionButton:
                  state is HomeTracking ? _buildFab(context, state) : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMdplHistory(HomeTracking state) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Riwayat MDPL",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[300] : Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<HomeBloc>().add(ClearMdplHistory());
                  BaseOverlays.success(message: "Riwayat MDPL dihapus!");
                },
                icon: const Icon(Icons.delete_forever, color: Colors.red),
              ),
            ],
          ),
          if (state.mdplHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("Belum ada data MDPL"),
            ),
          for (final mdpl in state.mdplHistory.reversed)
            ListTile(
              leading: const Icon(Icons.height),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ketinggian : ${(mdpl["altitude"] as num).round()} Mdpl",
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Disimpan : ${DateFormat("dd MMMM yyyy HH:mm", "id_ID").format(DateTime.parse(mdpl["time"]))}",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );

  Widget _buildLocationHistory(HomeTracking state) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Riwayat Lokasi",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[300] : Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<HomeBloc>().add(ClearLocationHistory());
                  BaseOverlays.success(message: "Riwayat Lokasi dihapus!");
                },
                icon: const Icon(Icons.delete_forever, color: Colors.red),
              ),
            ],
          ),
          if (state.locationHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("Belum ada data lokasi"),
            ),
          for (final loc in state.locationHistory.reversed)
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nama lokasi : ${loc["name"]}"),
                  Text("Lat : ${loc["latitude"]} | Lng : ${loc["longitude"]}"),
                  Text("Ketinggian : ${(loc["altitude"] as num).round()} Mdpl"),
                  Text(
                    "Disimpan : ${DateFormat("dd MMMM yyyy HH:mm", "id_ID").format(DateTime.parse(loc["time"]))}",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );

  Widget _buildMainContent(
    HomeTracking state,
    Color textColor,
    String time,
    String date,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildTopBar(textColor, time, date),
          const Spacer(),
          Text(
            "${state.altitude?.round() ?? "-"} Mdpl",
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _buildLocationInfo(state, textColor),
          const SizedBox(height: 20),
          _buildSaveButtons(state),
        ],
      ),
    );
  }

  Widget _buildSaveButtons(HomeTracking state) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton(
            onPressed: () {
              if (state.altitude != null) {
                context.read<HomeBloc>().add(SaveMdpl(state.altitude!));
                BaseOverlays.success(message: "MDPL disimpan!");
              }
            },
            child: const Text("Simpan MDPL"),
          ),
          const SizedBox(width: 20),
          FilledButton(
            onPressed: () async {
              if (state.latitude != null &&
                  state.longitude != null &&
                  state.altitude != null) {
                final name = await _inputNameDialog(context);
                if (name != null && name.isNotEmpty) {
                  context.read<HomeBloc>().add(
                        SaveLocation(
                          name: name,
                          latitude: state.latitude!,
                          longitude: state.longitude!,
                          altitude: state.altitude!,
                        ),
                      );
                  BaseOverlays.success(message: "Lokasi disimpan!");
                }
              }
            },
            child: const Text("Simpan Lokasi"),
          ),
        ],
      );

  Widget _buildTopBar(Color textColor, String time, String date) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: TextStyle(color: textColor.withOpacity(0.7))),
              Text(
                time,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              ToggleButtons(
                borderRadius: BorderRadius.circular(12),
                isSelected: [!is24h, is24h],
                onPressed: (i) => setState(() => is24h = i == 1),
                children: const [
                  Padding(padding: EdgeInsets.all(8), child: Text("12h")),
                  Padding(padding: EdgeInsets.all(8), child: Text("24h")),
                ],
              ),
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: textColor,
                ),
                onPressed: () => setState(() => isDark = !isDark),
              ),
            ],
          ),
        ],
      );

  Widget _buildLocationInfo(HomeTracking state, Color textColor) => Column(
        children: [
          if (state.locationName != null)
            Text(
              state.locationName!,
              style: TextStyle(fontSize: 16, color: textColor),
              textAlign: TextAlign.center,
            )
          else
            Text(
              "",
              style: TextStyle(color: textColor.withOpacity(0.6)),
            ),
          if (state.latitude != null && state.longitude != null)
            Text(
              "Lat: ${state.latitude!.toStringAsFixed(6)} | Lng: ${state.longitude!.toStringAsFixed(6)}",
              style: TextStyle(fontSize: 14, color: textColor),
            ),
        ],
      );

  Future<String?> _inputNameDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nama Lokasi"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Masukkan nama lokasi"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherBackground(String condition) {
    switch (condition) {
      case "Rain":
        return Lottie.asset("assets/lottie/rain.json", fit: BoxFit.cover);
      case "Clear":
      case "Clouds":
        return Lottie.asset("assets/lottie/cloudly.json", fit: BoxFit.cover);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInfoButton(Color textColor) => Positioned(
        bottom: 20,
        left: 20,
        child: IconButton(
          icon: const Icon(Icons.info_outline, size: 28),
          color: textColor,
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const AlertDialog(
                title: Text("👨‍💻 Info Developer"),
                content: Text("Nama: Satria Ramadan\nInstagram: @strhmdn_"),
              ),
            );
          },
        ),
      );

  Widget _buildFab(BuildContext context, HomeTracking state) => SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        overlayOpacity: 0.3,
        spacing: 12,
        children: [
          SpeedDialChild(
            child: const Icon(FontAwesomeIcons.compass, color: Colors.white),
            backgroundColor: Colors.deepPurple,
            label: "Kompas",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompassPage()),
            ),
          ),
          SpeedDialChild(
            child: const Icon(Icons.sos, color: Colors.white),
            backgroundColor: Colors.redAccent,
            label: "Emergency",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmergencyPage()),
            ),
          ),
          SpeedDialChild(
            child: const Icon(FontAwesomeIcons.lungs, color: Colors.white),
            backgroundColor: Colors.green,
            label: "Level Oksigen",
            onTap: () {
              if (state.altitude != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OxygenPage(
                      altitude: state.altitude!,
                    ),
                  ),
                );
              } else {
                BaseOverlays.error(message: "Ketinggian belum tersedia");
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.thermostat, color: Colors.white),
            backgroundColor: Colors.orange,
            label: "Suhu Sekitar",
            onTap: () {
              if (state.latitude != null && state.longitude != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TemperaturePage(
                      latitude: state.latitude!,
                      longitude: state.longitude!,
                    ),
                  ),
                );
              } else {
                BaseOverlays.error(message: "Lokasi belum tersedia");
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.wb_sunny, color: Colors.white),
            backgroundColor: Colors.amber,
            label: "Sunrise/Sunset",
            onTap: () {
              if (state.latitude != null && state.longitude != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SunPage(
                      latitude: state.latitude!,
                      longitude: state.longitude!,
                    ),
                  ),
                );
              } else {
                BaseOverlays.error(message: "Lokasi belum tersedia");
              }
            },
          ),
        ],
      );
}
