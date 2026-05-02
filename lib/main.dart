import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/expense_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/category_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/theme_provider.dart';
import 'core/soft_delete/undo_service.dart';
import 'features/recurring/providers/recurring_provider.dart';
import 'features/transactions/providers/filter_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/notifications/services/notification_service.dart';
import 'router/app_router.dart';
import 'core/errors/handlers/global_error_handler.dart';
import 'database/database_helper.dart';
import 'constants/app_colors.dart';

void main() async {
  GlobalErrorHandler.init();
  await GlobalErrorHandler.handle(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // ✅ On web: seed SharedPreferences defaults. On mobile: nothing extra needed.
    await DatabaseHelper.instance.initWeb();
    await DatabaseHelper.instance.ensureCategoriesExist();

    try { await NotificationService.init(); } catch (e) {
      debugPrint('Notification init skipped: $e');
    }

    runApp(
      ProviderScope(
        child: legacy_provider.MultiProvider(
          providers: [
            legacy_provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
            legacy_provider.ChangeNotifierProvider(create: (_) => ExpenseProvider()),
            legacy_provider.ChangeNotifierProvider(create: (_) => BudgetProvider()),
            legacy_provider.ChangeNotifierProvider(create: (_) => CategoryProvider()),
            legacy_provider.ChangeNotifierProvider(create: (_) => SettingsProvider()),
            legacy_provider.ChangeNotifierProvider(create: (_) => NavigationProvider()),
            legacy_provider.ChangeNotifierProvider(create: (_) => UndoService()),
            legacy_provider.ChangeNotifierProvider(create: (_) => RecurringProvider()),
            legacy_provider.ChangeNotifierProvider(create: (_) => FilterProvider()),
            legacy_provider.ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ],
          child: const MyApp(),
        ),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = legacy_provider.Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      title: 'PocketTrack Lite',
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary, primary: AppColors.primary,
          secondary: AppColors.secondary, surface: AppColors.surface,
          error: AppColors.error, brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent,
            elevation: 0, iconTheme: IconThemeData(color: AppColors.textPrimary)),
        cardTheme: const CardThemeData(color: AppColors.cardBackground, elevation: 0),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary, primary: AppColors.primary,
          secondary: AppColors.secondary, surface: AppColors.surfaceDark,
          error: AppColors.error, brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent,
            elevation: 0, iconTheme: IconThemeData(color: AppColors.textPrimaryDark)),
        cardTheme: const CardThemeData(color: AppColors.cardBackgroundDark, elevation: 0),
      ),
    );
  }
}
