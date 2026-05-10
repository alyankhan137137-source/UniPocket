import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/security_helper.dart';
import '../auth/pin_lock_screen.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../features/profile/models/user_profile.dart';
import '../../database/database_helper.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/smart_features.dart';
import '../../router/app_routes.dart';

/// A screen that provides various configuration options for the application.
///
/// This screen allows users to manage their profile (name, email),
/// preferences (currency, theme, language), security (PIN, biometrics),
/// and data (exporting, clearing). It integrates with multiple providers
/// to ensure settings are persisted and reflected immediately in the UI.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _hasPin = false;
  bool _isEditingProfile = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController();
    _emailCtrl = TextEditingController();
    _checkPinStatus();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  /// Checks if a security PIN is currently set on the device.
  Future<void> _checkPinStatus() async {
    final hasPin = await SecurityHelper.hasPin();
    if (!mounted) return;
    setState(() => _hasPin = hasPin);
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final themeProvider    = context.watch<ThemeProvider>();
    final settings = settingsProvider.settings;
    final profileAsync = ref.watch(profileNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardBackgroundDark : Colors.white;

    if (settingsProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: AppStyles.heading3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            profileAsync.when(
              data: (profile) => _buildProfileHeader(profile, cardColor),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 30),
            _buildSection("Preferences", cardColor, [
              _buildListTile("Currency", settings.currency, Icons.attach_money_rounded,
                () => _showCurrencyPicker(context, settingsProvider), cardColor),
              _buildListTile("Theme",
                themeProvider.themeMode == ThemeMode.dark ? "DARK"
                : themeProvider.themeMode == ThemeMode.light ? "LIGHT" : "SYSTEM",
                Icons.palette_outlined,
                () => _showThemePicker(context, themeProvider), cardColor),
              _buildListTile("Language", "English", Icons.language_rounded, () {}, cardColor),
            ]),
            const SizedBox(height: 20),
            _buildSection("Budget & Alerts", cardColor, [
              _buildSwitchTile("Push Notifications", settings.enableNotifications,
                Icons.notifications_active_outlined,
                (val) => settingsProvider.updateSettings(settings.copyWith(enableNotifications: val))),
              _buildSliderTile("Budget Alert Threshold", settings.budgetAlertPercentage,
                (val) => settingsProvider.updateSettings(settings.copyWith(budgetAlertPercentage: val))),
            ]),
            const SizedBox(height: 20),
            _buildSection("Security", cardColor, [
              _buildListTile(_hasPin ? "Change PIN" : "Set PIN",
                _hasPin ? "Enabled" : "Disabled",
                Icons.lock_outline_rounded,
                () => _handlePinSetup(context), cardColor),
              if (_hasPin)
                _buildListTile("Remove PIN", "", Icons.lock_open_rounded,
                  () => _removePin(context), cardColor, color: Colors.orange),
              _buildSwitchTile("Biometric Lock", settings.enableBiometric,
                Icons.fingerprint_rounded, (val) async {
                  if (!_hasPin && val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please set a PIN first")));
                    return;
                  }
                  await SecurityHelper.setBiometricEnabled(val);
                  if (!mounted) return;
                  settingsProvider.updateSettings(settings.copyWith(enableBiometric: val));
                }),
            ]),
            const SizedBox(height: 20),
            _buildSection("Data Management", cardColor, [
              _buildListTile("Export Data", "PDF, Excel", Icons.file_download_outlined, () {}, cardColor),
              _buildListTile("Clear All Data", "Permanent", Icons.delete_outline_rounded,
                () => _confirmClearData(context), cardColor, color: Colors.red),
            ]),
            const SizedBox(height: 20),
            _buildSection("Demo & Testing", cardColor, [
              _buildListTile("Generate Demo Data", "Try the app with sample data",
                Icons.auto_awesome_outlined,
                () => _generateDemoData(context), cardColor),
            ]),
            const SizedBox(height: 20),
            _buildSection("About", cardColor, [
              _buildListTile("App Version", "1.0.0", Icons.info_outline_rounded, () {}, cardColor),
              _buildListTile("Privacy Policy", "", Icons.privacy_tip_outlined,
                () => context.push(AppRoutes.privacyPolicy), cardColor),
              _buildListTile("Contact Support", "", Icons.support_agent_rounded,
                () => _showContactSupport(context), cardColor),
            ]),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  /// Builds the header containing user profile summary and edit controls.
  Widget _buildProfileHeader(UserProfile profile, Color cardColor) {
    final initials = profile.name.isNotEmpty
        ? profile.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'U';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppStyles.cardShadow,
      ),
      child: _isEditingProfile
          ? _buildProfileEditForm(profile)
          : Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.primary,
                  child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name.isNotEmpty ? profile.name : 'Set your name',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (profile.email != null && profile.email!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(profile.email!, style: AppStyles.body2),
                      ],
                      const SizedBox(height: 4),
                      Text("Member since ${profile.createdAt.year}", style: AppStyles.caption),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _nameCtrl.text  = profile.name;
                    _emailCtrl.text = profile.email ?? '';
                    setState(() => _isEditingProfile = true);
                  },
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                ),
              ],
            ),
    );
  }

  /// Builds the inline form for updating profile information.
  Widget _buildProfileEditForm(UserProfile profile) {
    return Column(
      children: [
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: AppStyles.inputDecoration(
            labelText: "Full Name",
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: AppStyles.inputDecoration(
            labelText: "Email (optional)",
            prefixIcon: const Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _isEditingProfile = false),
                child: const Text("Cancel"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  if (_nameCtrl.text.trim().isEmpty) return;
                  final updated = profile.copyWith(
                    name: _nameCtrl.text.trim(),
                    email: _emailCtrl.text.trim(),
                    updatedAt: DateTime.now(),
                  );
                  await ref.read(profileNotifierProvider.notifier).updateProfile(updated);
                  if (mounted) setState(() => _isEditingProfile = false);
                },
                style: AppStyles.primaryButton,
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a titled container for grouping settings tiles.
  Widget _buildSection(String title, Color cardColor, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: AppStyles.heading3.copyWith(fontSize: 18)),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppStyles.cardShadow,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  /// Builds a standard list tile for settings with an icon and trailing arrow.
  Widget _buildListTile(String title, String trailing, IconData icon, VoidCallback onTap, Color cardColor, {Color? color}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (color ?? AppColors.primary).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color ?? AppColors.primary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: color)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing.isNotEmpty) Text(trailing, style: AppStyles.body2),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
        ],
      ),
      onTap: onTap,
    );
  }

  /// Builds a switch tile for toggling boolean settings.
  Widget _buildSwitchTile(String title, bool value, IconData icon, Function(bool) onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      trailing: Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
    );
  }

  /// Builds a tile containing a slider for numeric ranges.
  Widget _buildSliderTile(String title, double value, Function(double) onChanged) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 20),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          trailing: Text("${value.toInt()}%", style: AppStyles.body2),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Slider(value: value, min: 0, max: 100, divisions: 20,
              activeColor: AppColors.primary, onChanged: onChanged),
        ),
      ],
    );
  }

  /// Displays a modal to choose the application's theme mode.
  void _showThemePicker(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text("Select Theme", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(leading: const Icon(Icons.light_mode), title: const Text("Light"),
            onTap: () { themeProvider.setThemeMode(ThemeMode.light); Navigator.pop(ctx); }),
          ListTile(leading: const Icon(Icons.dark_mode), title: const Text("Dark"),
            onTap: () { themeProvider.setThemeMode(ThemeMode.dark); Navigator.pop(ctx); }),
          ListTile(leading: const Icon(Icons.brightness_auto), title: const Text("System Default"),
            onTap: () { themeProvider.setThemeMode(ThemeMode.system); Navigator.pop(ctx); }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Displays a currency selector.
  void _showCurrencyPicker(BuildContext context, SettingsProvider provider) {
    showCurrencyPicker(
      context: context,
      onSelect: (Currency c) => provider.setCurrency(c.code),
    );
  }

  /// Navigates to the PIN setup screen.
  void _handlePinSetup(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => PinLockScreen(
        onComplete: (pin) {
          _checkPinStatus();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("PIN saved successfully!")));
        },
      ),
    ));
  }

  /// Prompts for confirmation and clears the security PIN.
  Future<void> _removePin(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove PIN?"),
        content: const Text("This will disable app security."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await SecurityHelper.clearSecurityData();
              _checkPinStatus();
              if (!mounted) return;
              Navigator.pop(ctx);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  /// Triggers generation of sample data for testing purposes.
  Future<void> _generateDemoData(BuildContext context) async {
    final provider = context.read<ExpenseProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final already = await SmartFeatures.isDemoDataGenerated();
    if (!mounted) return;
    if (already) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Demo data already generated!')));
      return;
    }
    await provider.generateDemoData();
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('✅ Demo data added successfully!')));
  }

  /// Prompts for confirmation and clears all application data.
  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear All Data?"),
        content: const Text("This is permanent and cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await DatabaseHelper.instance.clearAllData();
              final p = await SharedPreferences.getInstance();
              await p.setBool('demo_data_generated', false);

              if (!mounted) return;
              final expenseProvider = context.read<ExpenseProvider>();
              await expenseProvider.fetchExpenses();
              if (!mounted) return;
              await context.read<BudgetProvider>().loadBudgets(expenseProvider.expenses);
              if (!mounted) return;
              await context.read<CategoryProvider>().loadCategories();

              if (!mounted) return;
              Navigator.pop(ctx);
              messenger.showSnackBar(
                const SnackBar(content: Text("All data cleared.")));
            },
            child: const Text("Delete Everything", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Displays contact information for developer support.
  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Contact Support"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Developer: Alyan Khan Banochi", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Email: muhammedalyankhanbu@gmail.com"),
            SizedBox(height: 16),
            Text("Feel free to reach out for support or feedback!"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
        ],
      ),
    );
  }
}
