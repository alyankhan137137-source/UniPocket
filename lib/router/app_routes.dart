/// A centralized repository of all route paths used in the application.
/// 
/// This class provides constant string definitions for navigation paths,
/// ensuring consistency and reducing the risk of typos when using [GoRouter].
class AppRoutes {
  /// The initial loading or splash screen.
  static const String splash = '/splash';
  
  /// The first-time user walkthrough and setup screen.
  static const String onboarding = '/onboarding';
  
  /// The user login screen.
  static const String login = '/auth/login';
  
  /// The user registration screen.
  static const String register = '/auth/register';
  
  // Shell Routes (Bottom Nav)
  /// The primary dashboard showing balance and recent activity.
  static const String dashboard = '/home/dashboard';
  
  /// The full list of transactions.
  static const String transactions = '/home/transactions';
  
  /// The category-based budget management screen.
  static const String budget = '/home/budget';
  
  /// The financial analytics and charts screen.
  static const String analytics = '/home/analytics';
  
  // Nested / Secondary Routes
  /// Detailed view of a specific transaction.
  static const String transactionDetail = '/home/transactions/:id';
  
  /// Screen for creating a new transaction.
  static const String addTransaction = '/home/transactions/add';
  
  /// Screen for editing an existing transaction.
  static const String editTransaction = '/home/transactions/edit/:id';
  
  /// Screen for tracking financial goals.
  static const String goals = '/home/goals';
  
  /// Main settings and configuration screen.
  static const String settings = '/settings';
  
  /// Screen for managing custom transaction categories.
  static const String categories = '/settings/categories';
  
  /// Data backup and restore settings.
  static const String backup = '/settings/backup';
  
  /// The application's privacy policy screen.
  static const String privacyPolicy = '/settings/privacy-policy';
  
  /// The legal terms of service screen.
  static const String termsOfService = '/settings/terms-of-service';

  /// Consolidated application information, support, and legal.
  static const String appInfo = '/settings/about';

  /// Access to soft-deleted items that can be restored.
  static const String trash = '/trash';

  static const String parentLink = '/settings/parent-link';
  static const String parentView = '/settings/parent-view';
  static const String upgrade = '/upgrade';
}
