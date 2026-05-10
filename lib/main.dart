import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'constants/app_themes.dart';

/// The entry point of the PocketTrack Lite application.
///
/// This function orchestrates the bootstrap process, including:
/// 1. Global error handling initialization.
/// 2. Ensuring Flutter services are ready.
/// 3. Initializing local database services (SQLite/Web storage).
/// 4. Initializing background/push notification services.
/// 5. Setting up the dependency injection tree using a hybrid approach
///    of Riverpod ([ProviderScope]) and legacy Provider ([MultiProvider]).
void main() async {
  // Initialize the global error handler to catch and report app-wide exceptions.
  GlobalErrorHandler.init();

  // Wrap the execution in a handler to safely manage asynchronous errors during startup.
  await GlobalErrorHandler.handle(() async {
    // Required to interact with the Flutter engine before runApp() is called.
    WidgetsFlutterBinding.ensureInitialized();

    // Database Initialization:
    // ✅ On web: seeds SharedPreferences defaults for persistent storage simulation.
    // On mobile: ensures the SQLite database is ready.
    await DatabaseHelper.instance.initWeb();

    // Ensures default categories are populated in the database for new users.
    await DatabaseHelper.instance.ensureCategoriesExist();

    // Initialize Local/Push Notifications.
    // Wrapped in a try-catch to ensure app startup succeeds even if notification permissions fail.
    try {
      await NotificationService.init();
    } catch (e) {
      debugPrint('Notification init skipped: $e');
    }

    // Launch the application.
    runApp(
      // Riverpod scope for modern state management.
      ProviderScope(
        child: legacy_provider.MultiProvider(
          // Legacy Provider list for backward compatibility with existing features.
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

/// The root widget of the PocketTrack Lite application.
///
/// Responsible for:
/// - Configuring the [MaterialApp.router] with [GoRouter] logic.
/// - Synchronizing the application's visual theme with [ThemeProvider].
/// - Applying centralized theme definitions from [AppThemes].
class MyApp extends StatelessWidget {
  /// Creates the root application widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider to reactively update the UI when the user toggles light/dark mode.
    final themeProvider = legacy_provider.Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      title: 'PocketTrack Lite',
      debugShowCheckedModeBanner: false,

      // Routing configuration using the centralized goRouter.
      routerConfig: goRouter,

      // Theme configuration based on user settings.
      themeMode: themeProvider.themeMode,

      // Apply centralized Light Theme
      theme: AppThemes.lightTheme,

      // Apply centralized Dark Theme
      darkTheme: AppThemes.darkTheme,
    );
  }
}
