class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  
  // Shell Routes (Bottom Nav)
  static const String dashboard = '/home/dashboard';
  static const String transactions = '/home/transactions';
  static const String budget = '/home/budget';
  static const String analytics = '/home/analytics';
  
  // Nested / Secondary Routes
  static const String transactionDetail = '/home/transactions/:id';
  static const String addTransaction = '/home/transactions/add';
  static const String editTransaction = '/home/transactions/edit/:id';
  static const String goals = '/home/goals';
  
  static const String settings = '/settings';
  static const String categories = '/settings/categories';
  static const String backup = '/settings/backup';
  static const String privacyPolicy = '/settings/privacy-policy';

  static const String trash = '/trash';
}
