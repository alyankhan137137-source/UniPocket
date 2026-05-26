import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/expense_provider.dart';
import '../models/parent_link_model.dart';
import '../services/parent_link_service.dart';
import '../services/cloud_sync_service.dart';
import '../../../widgets/skeleton.dart';

class ParentLinkScreen extends StatefulWidget {
  const ParentLinkScreen({super.key});

  @override
  State<ParentLinkScreen> createState() => _ParentLinkScreenState();
}

class _ParentLinkScreenState extends State<ParentLinkScreen> {
  ParentLink? _activeLink;
  bool _isLoading = true;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadLink();
  }

  Future<void> _loadLink() async {
    setState(() => _isLoading = true);
    final link = await ParentLinkService.instance.getActiveLink();
    setState(() {
      _activeLink = link;
      _isLoading = false;
    });
  }

  Future<void> _generateCode() async {
    setState(() => _isGenerating = true);
    try {
      final newLink = await ParentLinkService.instance.generateLink();
      
      // Perform initial sync so the parent can see the data immediately
      if (mounted) {
        try {
          final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
          
          final snapshot = await ParentLinkService.instance.buildSnapshot(
            expenseProvider, 
            'Student',
          );
          await CloudSyncService.instance.syncSnapshot(snapshot, newLink.accessCode);
        } catch (e) {
          debugPrint('Initial cloud sync failed: $e');
          if (mounted) {
            String msg = 'Sync failed: Check your connection.';
            final errorStr = e.toString().toLowerCase();
            if (errorStr.contains('permission-denied') || errorStr.contains('permission_denied')) {
              msg = 'Permission Denied: Check Realtime Database Rules.';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

      setState(() {
        _activeLink = newLink;
      });
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _deactivateLink() async {
    if (_activeLink == null) return;
    
    final code = _activeLink!.accessCode;
    await ParentLinkService.instance.deactivateLink();
    await CloudSyncService.instance.deleteSnapshot(code);
    
    setState(() {
      _activeLink = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parent link deactivated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parent Link',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: const [
                  Skeleton(height: 24, width: 250),
                  SizedBox(height: 32),
                  Skeleton(height: 250, width: double.infinity, borderRadius: 16),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share a read-only view of your spending with a parent or guardian',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_activeLink == null)
                    _buildNoActiveLinkState()
                  else
                    _buildActiveLinkState(),
                ],
              ),
            ),
    );
  }

  Widget _buildNoActiveLinkState() {
    return Center(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.link_off, size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No parent link active',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Generate a code and share it with your parent. They enter it to see your spending summary.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Generate Code'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveLinkState() {
    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.green, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Parent Link Active',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  _activeLink!.accessCode,
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Expires: ${DateFormat('dd MMM yyyy').format(_activeLink!.expiresAt)}',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to share',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStepItem(1, 'Tell your parent to open UniPocket on their phone'),
                _buildStepItem(2, 'Go to Settings → Parent View'),
                _buildStepItem(3, 'Enter this code: ${_activeLink!.accessCode}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: _deactivateLink,
          child: Text(
            'Deactivate Link',
            style: GoogleFonts.poppins(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(int step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              step.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
