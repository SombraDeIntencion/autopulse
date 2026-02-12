import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/pages/login_page.dart';
import 'features/workshop/providers/vehicle_provider.dart';
import 'features/workshop/providers/order_provider.dart';
import 'shared/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set preferred orientations (landscape for tablets)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AutoPulseApp());
}

class AutoPulseApp extends StatelessWidget {
  const AutoPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Settings Provider (idioma, tema)
        ChangeNotifierProvider(create: (_) => SettingsProvider()),

        // Auth Provider (autenticación y usuario)
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Vehicle Provider (gestión de vehículos y workflow)
        ChangeNotifierProvider(
          create: (_) => VehicleProvider()..initializeListeners(),
        ),

        // Order Provider (órdenes de servicio)
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            locale: settings.locale,
            supportedLocales: const [
              Locale('es'), // Español
              Locale('en'), // English
              Locale('pt'), // Português
              Locale('fr'), // Français
              Locale('de'), // Deutsch
              Locale('it'), // Italiano
              Locale('zh'), // 中文
              Locale('ja'), // 日本語
              Locale('ru'), // Русский
            ],
            home: const LoginPage(),
            // TODO: Add routes when created
            // routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
