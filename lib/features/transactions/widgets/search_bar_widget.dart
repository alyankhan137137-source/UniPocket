import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/filter_provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<FilterProvider>().setSearchQuery(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppStyles.cardShadow,
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: "Search transactions...",
          hintStyle: const TextStyle(color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune, color: AppColors.primary),
            onPressed: () {
              // Open Filter Bottom Sheet logic will go here
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
