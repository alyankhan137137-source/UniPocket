import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_colors.dart';
import '../models/student_snapshot_model.dart';
import '../services/cloud_sync_service.dart';
import '../../../widgets/skeleton.dart';

class ParentViewScreen extends StatefulWidget {
  const ParentViewScreen({super.key});

  @override
  State<ParentViewScreen> createState() => _ParentViewScreenState();
}

class _ParentViewScreenState extends State<ParentViewScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isVerified = false;
  bool _isLoading = false;
  StudentSnapshot? _snapshot;
  String _dataSource = 'cloud';

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadByCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await CloudSyncService.instance.fetchSnapshot(code);
      if (result == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Code not found. Please verify the code with the student.',
              ),
            ),
          );
        }
      } else {
        setState(() {
          _snapshot = result;
          _isVerified = true;
          _dataSource = 'cloud';
        });
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Error loading summary';
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('permission-denied') || errorStr.contains('permission_denied')) {
          msg = 'Permission Denied: Check Realtime Database Rules.';
        } else {
          msg = 'Error: $e';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parent View',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_isVerified)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadByCode,
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _isVerified && _snapshot != null
              ? _buildDashboardView()
              : _buildCodeEntryView(),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(height: 30, width: 200),
          const SizedBox(height: 8),
          const Skeleton(height: 15, width: 150),
          const SizedBox(height: 32),
          Row(
            children: List.generate(3, (index) => 
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Skeleton(height: 80, borderRadius: 16),
                ),
              )
            ),
          ),
          const SizedBox(height: 32),
          const Skeleton(height: 20, width: 180),
          const SizedBox(height: 12),
          const Skeleton(height: 12, width: double.infinity, borderRadius: 10),
          const SizedBox(height: 32),
          const Skeleton(height: 20, width: 150),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => const Skeleton(height: 60, width: double.infinity, borderRadius: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeEntryView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.family_restroom,
              size: 72,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Parent View',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 6-digit code from your child\'s app',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: const InputDecoration(
                hintText: '000000',
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _loadByCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('View Spending Summary'),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'The student generates this code in their Settings → Parent Link',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildMetrics(),
          const SizedBox(height: 32),
          _buildUsageProgress(),
          const SizedBox(height: 32),
          _buildRecentActivity(),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'This is a read-only view. Contact your child directly for details.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spending Summary',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Chip(
              label: Text(
                _dataSource == 'cloud' ? 'Live' : 'Cached',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: _dataSource == 'cloud' ? Colors.green : Colors.grey,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Last updated: ${DateFormat('dd MMM yyyy, hh:mm a').format(_snapshot!.lastUpdated)}',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMetrics() {
    return LayoutBuilder(builder: (context, constraints) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildMetricCard('Balance', _snapshot!.currentBalance, Colors.blue),
          _buildMetricCard('Spent', _snapshot!.spentThisMonth, Colors.orange),
          _buildMetricCard(
            'Remaining',
            _snapshot!.remainingBudget,
            _snapshot!.remainingBudget < 0 ? Colors.red : Colors.green,
          ),
        ],
      );
    });
  }

  Widget _buildMetricCard(String title, double amount, Color color) {
    return Container(
      width: (MediaQuery.of(context).size.width - 68) / 3,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount.toStringAsFixed(2),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageProgress() {
    if (_snapshot!.monthlyAllowance <= 0) return const SizedBox.shrink();

    final spent = _snapshot!.spentThisMonth;
    final allowance = _snapshot!.monthlyAllowance;
    final progress = (spent / allowance).clamp(0.0, 1.0);

    Color progressColor = Colors.green;
    if (progress >= 1.0) {
      progressColor = Colors.red;
    } else if (progress >= 0.75) {
      progressColor = Colors.orange;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Budget Usage',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).toStringAsFixed(0)}% used',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Limit: ${allowance.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_snapshot!.recentTransactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No recent activity',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _snapshot!.recentTransactions.length,
            itemBuilder: (context, index) {
              final tx = _snapshot!.recentTransactions[index];
              final isIncome = tx['type'] == 'income';
              final amount = tx['amount'] as double;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: (isIncome ? Colors.green : Colors.red).withValues(alpha: 0.1),
                  child: Icon(
                    isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isIncome ? Colors.green : Colors.red,
                    size: 18,
                  ),
                ),
                title: Text(
                  tx['title'] ?? 'Transaction',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  tx['date'] ?? '',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                trailing: Text(
                  '${isIncome ? '+' : '-'}${amount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
