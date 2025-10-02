// ignore_for_file: deprecated_member_use

import "dart:io";

import "package:base/base.dart";
import "package:easy_localization/easy_localization.dart" as el;
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_web_plugins/url_strategy.dart";
import "package:get/get.dart";
import "package:go_router/go_router.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:loader_overlay/loader_overlay.dart";
import "package:lottie/lottie.dart";
import "package:mdpl/helper/preferences.dart";
import "package:mdpl/helper/timers.dart";
import "package:mdpl/main_bloc.dart";
import "package:mdpl/main_state.dart";
import "package:mdpl/module/compass/compass_bloc.dart";
import "package:mdpl/module/emergency/emergency_bloc.dart";
import "package:mdpl/module/home/home_bloc.dart";
import "package:mdpl/module/home/home_page.dart";
import "package:mdpl/module/oxygen/oxygen_bloc.dart";
import "package:mdpl/module/sun/sun_bloc.dart";
import "package:mdpl/module/temperatur/temperatur_bloc.dart";
import "package:provider/provider.dart";
import "package:smooth_corner/smooth_corner.dart";

final goRouter = GoRouter(
  initialLocation: "/",
  navigatorKey: Get.key,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) {
        return const HomePage();
      },
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = BaseHttpOverrides();
  await BasePreferences.getInstance().init();
  await Preferences.init();

  AppColors.lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFFFC1CC),
    onPrimary: Color(0xFF3D1F1F),
    primaryContainer: Color(0xFFFFE4E1),
    onPrimaryContainer: Color(0xFF3D1F1F),
    secondary: Color(0xFFB2F2BB),
    onSecondary: Color(0xFF1F3D2C),
    secondaryContainer: Color(0xFFD3F9D8),
    onSecondaryContainer: Color(0xFF1F3D2C),
    tertiary: Color(0xFFE0BBE4),
    onTertiary: Color(0xFF3D2B5F),
    tertiaryContainer: Color(0xFFF3E5F5),
    onTertiaryContainer: Color(0xFF3D2B5F),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: Color(0xFFFDF6F0),
    onSurface: Color(0xFF3C3C3C),
    onSurfaceVariant: Color(0xFF5D5D5D),
    outline: Color(0xFFBDBDBD),
    outlineVariant: Color(0xFFE0E0E0),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF313131),
    inversePrimary: Color(0xFFF48FB1),
    primaryFixed: Color(0xFFFFE4E1),
    onPrimaryFixed: Color(0xFF3D1F1F),
    primaryFixedDim: Color(0xFFFFC1CC),
    onPrimaryFixedVariant: Color(0xFF3D1F1F),
    secondaryFixed: Color(0xFFD3F9D8),
    onSecondaryFixed: Color(0xFF1F3D2C),
    secondaryFixedDim: Color(0xFFB2F2BB),
    onSecondaryFixedVariant: Color(0xFF1F3D2C),
    tertiaryFixed: Color(0xFFF3E5F5),
    onTertiaryFixed: Color(0xFF3D2B5F),
    tertiaryFixedDim: Color(0xFFE0BBE4),
    onTertiaryFixedVariant: Color(0xFF3D2B5F),
    surfaceDim: Color(0xFFF5F5F5),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF9F9F9),
    surfaceContainer: Color(0xFFF1F1F1),
    surfaceContainerHigh: Color(0xFFEAEAEA),
    surfaceContainerHighest: Color(0xFFE0E0E0),
  );

  AppColors.darkColorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFF48FB1),
    onPrimary: Color(0xFF2C1A1A),
    primaryContainer: Color(0xFF3D1F1F),
    onPrimaryContainer: Color(0xFFFFE4E1),
    secondary: Color(0xFF81C784),
    onSecondary: Color(0xFF0D2F1F),
    secondaryContainer: Color(0xFF1F3D2C),
    onSecondaryContainer: Color(0xFFD3F9D8),
    tertiary: Color(0xFFB39DDB),
    onTertiary: Color(0xFF261B3F),
    tertiaryContainer: Color(0xFF3D2B5F),
    onTertiaryContainer: Color(0xFFF3E5F5),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFECECEC),
    onSurfaceVariant: Color(0xFFBDBDBD),
    outline: Color(0xFF8A8A8A),
    outlineVariant: Color(0xFF444444),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFECECEC),
    inversePrimary: Color(0xFFFFC1CC),
    primaryFixed: Color(0xFFFFE4E1),
    onPrimaryFixed: Color(0xFF3D1F1F),
    primaryFixedDim: Color(0xFFFFC1CC),
    onPrimaryFixedVariant: Color(0xFF3D1F1F),
    secondaryFixed: Color(0xFFD3F9D8),
    onSecondaryFixed: Color(0xFF1F3D2C),
    secondaryFixedDim: Color(0xFFB2F2BB),
    onSecondaryFixedVariant: Color(0xFF1F3D2C),
    tertiaryFixed: Color(0xFFF3E5F5),
    onTertiaryFixed: Color(0xFF3D2B5F),
    tertiaryFixedDim: Color(0xFFE0BBE4),
    onTertiaryFixedVariant: Color(0xFF3D2B5F),
    surfaceDim: Color(0xFF181818),
    surfaceBright: Color(0xFF2A2A2A),
    surfaceContainerLowest: Color(0xFF0F0F0F),
    surfaceContainerLow: Color(0xFF1C1C1C),
    surfaceContainer: Color(0xFF222222),
    surfaceContainerHigh: Color(0xFF2A2A2A),
    surfaceContainerHighest: Color(0xFF333333),
  );

  usePathUrlStrategy();
  initializeDateFormatting();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  await el.EasyLocalization.ensureInitialized();
  await BasePreferences.getInstance().init();

  runApp(
    el.EasyLocalization(
      supportedLocales: const [Locale("en"), Locale("id")],
      path: "assets/i18n",
      useFallbackTranslations: true,
      fallbackLocale: const Locale("id"),
      saveLocale: true,
      startLocale: const Locale("id"),
      child: const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final ValueNotifier<String> valueNotifier = ValueNotifier("");

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      scaffoldFeatureController;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => MainBloc()),
        BlocProvider(create: (BuildContext context) => HomeBloc()),
        BlocProvider(create: (BuildContext context) => EmergencyBloc()),
        BlocProvider(create: (BuildContext context) => CompassBloc()),
        BlocProvider(create: (BuildContext context) => TemperatureBloc()),
        BlocProvider(create: (BuildContext context) => SunBloc()),
        BlocProvider(create: (BuildContext context) => OxygenBloc()),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Timers.getInstance()),
        ],
        child: GlobalLoaderOverlay(
          useDefaultLoading: false,
          overlayWidget: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  "assets/lottie/loading.json",
                  frameRate: const FrameRate(60),
                  width: Dimensions.size100,
                  height: Dimensions.size100,
                  repeat: true,
                ),
                Text(
                  "Loading...",
                  style: TextStyle(
                    fontSize: Dimensions.text20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          overlayColor: Colors.black,
          overlayOpacity: 0.8,
          child: DismissKeyboard(
            child: BlocBuilder<MainBloc, MainState>(
              builder: (context, state) {
                return MaterialApp.router(
                  scrollBehavior: BaseScrollBehavior(),
                  scaffoldMessengerKey: rootScaffoldMessengerKey,
                  title: "Loyalty Portal",
                  routerConfig: goRouter,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                    useMaterial3: true,
                    fontFamily: "Manrope",
                    colorScheme: AppColors.lightColorScheme,
                    filledButtonTheme: FilledButtonThemeData(
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: SmoothRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.size10),
                          smoothness: 1,
                        ),
                        padding: EdgeInsets.all(Dimensions.size20),
                        textStyle: TextStyle(
                          fontSize: Dimensions.text12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    outlinedButtonTheme: OutlinedButtonThemeData(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: SmoothRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.size10),
                          smoothness: 1,
                        ),
                        padding: EdgeInsets.all(Dimensions.size20),
                        textStyle: TextStyle(
                          fontSize: Dimensions.text12,
                          fontWeight: FontWeight.w500,
                        ),
                        foregroundColor: AppColors.onSurface(),
                        iconColor: AppColors.onSurface(),
                      ),
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: SmoothRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.size10),
                          smoothness: 1,
                        ),
                        padding: EdgeInsets.all(Dimensions.size20),
                        textStyle: TextStyle(
                          fontSize: Dimensions.text12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    iconButtonTheme: IconButtonThemeData(
                      style: IconButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.square(
                          Dimensions.size45 + Dimensions.size3,
                        ),
                      ),
                    ),
                  ),
                  darkTheme: ThemeData(
                    useMaterial3: true,
                    fontFamily: "Manrope",
                    colorScheme: AppColors.darkColorScheme,
                    filledButtonTheme: FilledButtonThemeData(
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: SmoothRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.size10),
                          smoothness: 1,
                        ),
                        padding: EdgeInsets.all(Dimensions.size20),
                        textStyle: TextStyle(
                          fontSize: Dimensions.text12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    outlinedButtonTheme: OutlinedButtonThemeData(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: SmoothRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.size10),
                          smoothness: 1,
                        ),
                        padding: EdgeInsets.all(Dimensions.size20),
                        textStyle: TextStyle(
                          fontSize: Dimensions.text12,
                          fontWeight: FontWeight.w500,
                        ),
                        foregroundColor: AppColors.onSurface(),
                        iconColor: AppColors.onSurface(),
                      ),
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: SmoothRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.size10),
                          smoothness: 1,
                        ),
                        padding: EdgeInsets.all(Dimensions.size20),
                        textStyle: TextStyle(
                          fontSize: Dimensions.text12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    iconButtonTheme: IconButtonThemeData(
                      style: IconButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.square(
                          Dimensions.size45 + Dimensions.size3,
                        ),
                      ),
                    ),
                  ),
                  themeMode: state.themeMode,
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(textScaler: const TextScaler.linear(1.0)),
                      child: child ?? Container(),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class DismissKeyboard extends StatelessWidget {
  final Widget child;

  const DismissKeyboard({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: child,
    );
  }
}

class SnackContent extends StatelessWidget {
  final ValueNotifier<String> message;

  const SnackContent(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: message,
      builder: (_, msg, __) => Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.onError(),
        ),
      ),
    );
  }
}
