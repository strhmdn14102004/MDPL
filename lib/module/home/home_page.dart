// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import "dart:async";
import "dart:ui";

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
          _buildLocationInfo(
            state,
          ),
          const SizedBox(height: 20),
          _buildSaveButtons(state),
        ],
      ),
    );
  }

  Widget _buildSaveButtons(HomeTracking state) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _glassButton(
            label: "Simpan MDPL",
            onTap: () {
              if (state.altitude != null) {
                context.read<HomeBloc>().add(SaveMdpl(state.altitude!));
                BaseOverlays.success(message: "MDPL disimpan!");
              }
            },
          ),
          const SizedBox(width: 20),
          _glassButton(
            label: "Simpan Lokasi",
            onTap: () async {
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
          ),
        ],
      );

  /// Helper untuk membuat tombol liquid glass
  Widget _glassButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.size20),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: Dimensions.size20,
          sigmaY: Dimensions.size20,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimensions.size20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.size25,
              vertical: Dimensions.size15,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.size20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: Dimensions.size1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildLocationInfo(
    HomeTracking state,
  ) =>
      Column(
        children: [
          if (state.locationName != null)
            Text(
              state.locationName!,
              style: TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            )
          else
            Text(
              "",
            ),
          if (state.latitude != null && state.longitude != null)
            Text(
              "Lat: ${state.latitude!.toStringAsFixed(6)} | Lng: ${state.longitude!.toStringAsFixed(6)}",
              style: TextStyle(
                fontSize: 14,
              ),
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
        buttonSize: Size(40, 40),
        overlayOpacity: 0.3,
        spacing: 15,
        elevation: 0,
        animationCurve: Curves.elasticIn,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        children: [
          _glassAction(
            icon: const Icon(FontAwesomeIcons.compass, color: Colors.white),
            label: "Kompas",
            color: Colors.deepPurple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompassPage()),
            ),
          ),
          _glassAction(
            icon: const Icon(Icons.sos, color: Colors.white),
            label: "Emergency",
            color: Colors.redAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmergencyPage()),
            ),
          ),
          _glassAction(
            icon: const Icon(FontAwesomeIcons.lungs, color: Colors.white),
            label: "Level Oksigen",
            color: Colors.green,
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
          _glassAction(
            icon: const Icon(Icons.thermostat, color: Colors.white),
            label: "Suhu Sekitar",
            color: Colors.orange,
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
          _glassAction(
            icon: const Icon(Icons.wb_sunny, color: Colors.white),
            label: "Sunrise/Sunset",
            color: Colors.amber,
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

  /// Helper widget untuk liquid glass effect tiap menu
  SpeedDialChild _glassAction({
    required Widget icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SpeedDialChild(
      backgroundColor: Colors.transparent,
      elevation: 0,
      labelWidget: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.2,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.35),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.0,
              ),
            ),
            child: icon,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
