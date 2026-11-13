import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/datasets_screen.dart';
import 'screens/dataset_detail_screen.dart';
import 'screens/ocr_screen.dart';
import 'screens/news_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/indicators_screen.dart';
import 'screens/data_request_screen.dart';
import 'screens/disease_map_screen.dart';
import 'screens/publications_screen.dart';
import 'screens/about_screen.dart';
import 'screens/hospitals_screen.dart';
import 'screens/vaccines_screen.dart';
import 'screens/health_calendar_screen.dart';
import 'screens/support_screen.dart';
import 'screens/create_dataset_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/dataset_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/theme_provider.dart';
import 'config/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.charcoal,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const NHODPApp());
}

class NHODPApp extends StatelessWidget {
  const NHODPApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DatasetProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        title: 'NHODP — Egypt National Health Portal',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        initialRoute: '/splash',
        onGenerateRoute: _route,
      ),
    );
  }

  Route<dynamic>? _route(RouteSettings s) {
    final pages = <String, Widget Function()>{
      '/splash':          () => const SplashScreen(),
      '/':                () => const HomeScreen(),
      '/login':           () => const LoginScreen(),
      '/register':        () => const RegisterScreen(),
      '/datasets':        () => const DatasetsScreen(),
      '/dataset-detail':  () => const DatasetDetailScreen(),
      '/ocr':             () => const OCRScreen(),
      '/news':            () => const NewsScreen(),
      '/dashboard':       () => const DashboardScreen(),
      '/analytics':       () => const AnalyticsScreen(),
      '/profile':         () => const ProfileScreen(),
      '/search':          () => const SearchScreen(),
      '/indicators':      () => const IndicatorsScreen(),
      '/data-request':    () => const DataRequestScreen(),
      '/disease-map':     () => const DiseaseMapScreen(),
      '/publications':    () => const PublicationsScreen(),
      '/about':           () => const AboutScreen(),
      '/hospitals':       () => const HospitalsScreen(),
      '/vaccines':        () => const VaccinesScreen(),
      '/health-calendar': () => const HealthCalendarScreen(),
      '/support':         () => const SupportScreen(),
      '/create-dataset':  () => const CreateDatasetScreen(),
    };
    final builder = pages[s.name] ?? pages['/']!;
    return PageRouteBuilder(
      settings: s,
      pageBuilder: (_, __, ___) => builder(),
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.dark();
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.obsidian,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        onPrimary: AppColors.obsidian,
        secondary: AppColors.goldLight,
        surface: AppColors.inkBlack,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.dmSerifDisplayTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.dmSerifDisplay(color: AppColors.textPrimary),
        displayMedium: GoogleFonts.dmSerifDisplay(color: AppColors.textPrimary),
        titleLarge: GoogleFonts.dmSerifDisplay(color: AppColors.textPrimary, fontSize: 22),
        titleMedium: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15),
        bodyMedium: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
        bodySmall: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
        labelLarge: GoogleFonts.inter(color: AppColors.obsidian, fontWeight: FontWeight.w700, fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.charcoal,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
        actionsIconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.inkBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.charcoal,
        indicatorColor: AppColors.gold.withOpacity(0.15),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
            ? GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 11)
            : GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
        iconTheme: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
            ? const IconThemeData(color: AppColors.gold, size: 22)
            : const IconThemeData(color: AppColors.textMuted, size: 22)),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.charcoal,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.obsidian,
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700))),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: const BorderSide(color: AppColors.gold, width: 1.5),
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.elevated,
        labelStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.elevated,
        contentTextStyle: GoogleFonts.inter(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border))),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)))),
    );
  }
}
