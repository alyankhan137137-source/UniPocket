import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:provider/provider.dart' as legacy;
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../providers/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController  = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _syncControllers(UserProfile p) {
    _nameController.text  = p.name;
    _emailController.text = p.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile", style: AppStyles.heading3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
            onPressed: () {
              if (!_isEditing) profileAsync.whenData(_syncControllers);
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: profileAsync.when(
        data:    (p) => _buildContent(p),
        loading: ()  => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildContent(UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader(profile),
          const SizedBox(height: 30),
          if (_isEditing) _buildEditForm(profile) else _buildPreferences(profile),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildHeader(UserProfile profile) {
    return Column(
      children: [
        GestureDetector(
          onTap: _isEditing && !kIsWeb ? _pickImage : null,
          child: Hero(
            tag: 'avatar',
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: profile.avatarPath != null && !kIsWeb
                  ? FileImage(File(profile.avatarPath!))
                  : null,
              child: profile.avatarPath == null
                  ? Text(
                      profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(profile.name, style: AppStyles.heading2),
        if (profile.email != null && profile.email!.isNotEmpty)
          Text(profile.email!, style: AppStyles.body2),
        Text(
          'Member since ${profile.createdAt.year}',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildEditForm(UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: AppStyles.inputDecoration(
            labelText: "Full Name",
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: AppStyles.inputDecoration(
            labelText: "Email Address",
            prefixIcon: const Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _isEditing = false),
                child: const Text("Cancel"),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _saveProfile(profile),
                style: AppStyles.primaryButton,
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferences(UserProfile profile) {
    // ✅ Get current theme from ThemeProvider
    final themeProvider = legacy.Provider.of<ThemeProvider>(context);
    final themeName = themeProvider.themeMode == ThemeMode.dark
        ? 'Dark'
        : themeProvider.themeMode == ThemeMode.light
            ? 'Light'
            : 'System';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("General Preferences"),
        _buildPreferenceCard([
          // ✅ Theme tile — reads from ThemeProvider directly
          ListTile(
            leading: const Icon(Icons.palette_outlined, color: AppColors.primary),
            title: const Text('Theme'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(themeName, style: const TextStyle(color: AppColors.textSecondary)),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
            onTap: _showThemePicker,
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on_outlined, color: AppColors.primary),
            title: const Text('Currency'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(profile.currency, style: const TextStyle(color: AppColors.textSecondary)),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
            onTap: _showCurrencyPicker,
          ),
          ListTile(
            leading: const Icon(Icons.visibility_off_outlined, color: AppColors.primary),
            title: const Text('Privacy Mode'),
            trailing: Switch(
              value: profile.privacyModeEnabled,
              onChanged: (_) => ref.read(profileNotifierProvider.notifier).togglePrivacyMode(),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10, top: 20),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildPreferenceCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(children: children),
    );
  }

  Future<void> _saveProfile(UserProfile current) async {
    if (_nameController.text.trim().isEmpty) return;
    final updated = current.copyWith(
      name:      _nameController.text.trim(),
      email:     _emailController.text.trim(),
      updatedAt: DateTime.now(),
    );
    await ref.read(profileNotifierProvider.notifier).updateProfile(updated);
    if (mounted) setState(() => _isEditing = false);
  }

  void _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final profile = ref.read(profileNotifierProvider).value;
      if (profile != null) {
        await ref.read(profileNotifierProvider.notifier)
            .updateProfile(profile.copyWith(avatarPath: image.path, updatedAt: DateTime.now()));
      }
    }
  }

  // ✅ Theme picker now updates ThemeProvider directly so dark mode works
  void _showThemePicker() {
    final themeProvider = legacy.Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const Text('Choose Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.light_mode),
            title: const Text("Light"),
            onTap: () { themeProvider.setThemeMode(ThemeMode.light); Navigator.pop(ctx); },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("Dark"),
            onTap: () { themeProvider.setThemeMode(ThemeMode.dark); Navigator.pop(ctx); },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_auto),
            title: const Text("System"),
            onTap: () { themeProvider.setThemeMode(ThemeMode.system); Navigator.pop(ctx); },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showCurrencyPicker() {
    showCurrencyPicker(
      context: context,
      onSelect: (c) => ref.read(profileNotifierProvider.notifier).updateCurrency(c.code),
    );
  }
}
