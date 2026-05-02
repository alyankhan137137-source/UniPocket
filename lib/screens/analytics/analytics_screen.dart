import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriodIndex = 2; // Default to 'Month'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: _selectedPeriodIndex);
    _tabController.addListener(() {
      setState(() {
        _selectedPeriodIndex = _tabController.index;
      });
      _updateFilters();
    });
  }

  void _updateFilters() {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (_selectedPeriodIndex) {
      case 0: // Day
        start = DateTime(now.year, now.month, now.day);
        break;
      case 1: // Week
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 2: // Month
        start = DateTime(now.year, now.month, 1);
        break;
      case 3: // Year
        start = DateTime(now.year, 1, 1);
        break;
      default:
        start = DateTime(now.year, now.month, 1);
    }
    context.read<ExpenseProvider>().filterByDateRange(start, end);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final budgetProvider = context.watch<BudgetProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics', style: AppStyles.heading3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 25),
            _buildSummaryCards(expenseProvider),
            const SizedBox(height: 30),
            _buildChartSection("Spending Trend", _buildLineChart(expenseProvider)),
            const SizedBox(height: 30),
            _buildChartSection("Category Breakdown", _buildPieChart(expenseProvider)),
            const SizedBox(height: 30),
            _buildChartSection("Income vs Expense", _buildBarChart(expenseProvider)),
            const SizedBox(height: 30),
            _buildTopCategories(expenseProvider),
            const SizedBox(height: 30),
            _buildInsights(expenseProvider, budgetProvider),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: _buildExportFAB(),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppStyles.cardShadow,
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.primary,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(text: 'Day'),
          Tab(text: 'Week'),
          Tab(text: 'Month'),
          Tab(text: 'Year'),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ExpenseProvider provider) {
    return Row(
      children: [
        _summaryCard("Income", provider.totalIncome, Icons.arrow_downward, Colors.green),
        const SizedBox(width: 12),
        _summaryCard("Expense", provider.totalExpense, Icons.arrow_upward, Colors.red),
        const SizedBox(width: 12),
        _summaryCard("Savings", provider.currentBalance, Icons.account_balance_wallet, Colors.blue),
      ],
    );
  }

  Widget _summaryCard(String label, double amount, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppStyles.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            Text(label, style: AppStyles.caption),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "\$${NumberFormat("#,##0").format(amount)}",
                style: AppStyles.heading3.copyWith(fontSize: 16, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(String title, Widget chart) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppStyles.heading3.copyWith(fontSize: 18)),
          const SizedBox(height: 25),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildLineChart(ExpenseProvider provider) {
    final expenses = provider.filteredExpenses.where((e) => e.isExpense).toList();
    if (expenses.isEmpty) return const Center(child: Text("No data for this period"));

    // Simple grouping for the line chart (e.g., by day)
    Map<int, double> dayTotals = {};
    for (var e in expenses) {
      dayTotals[e.date.day] = (dayTotals[e.date.day] ?? 0) + (e.amount / 100.0);
    }
    var sortedDays = dayTotals.keys.toList()..sort();
    
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: sortedDays.map((day) => FlSpot(day.toDouble(), dayTotals[day]!)).toList(),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(ExpenseProvider provider) {
    final catData = provider.categoryWiseExpenses;
    if (catData.isEmpty) return const Center(child: Text("No data available"));

    int colorIndex = 0;
    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: catData.entries.map((entry) {
          final color = AppColors.categoryColors[colorIndex % AppColors.categoryColors.length];
          colorIndex++;
          return PieChartSectionData(
            color: color,
            value: entry.value,
            title: '${((entry.value / provider.totalExpense) * 100).toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarChart(ExpenseProvider provider) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (provider.totalIncome > provider.totalExpense ? provider.totalIncome : provider.totalExpense) * 1.2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(toY: provider.totalIncome, color: Colors.green, width: 20, borderRadius: BorderRadius.circular(4)),
              BarChartRodData(toY: provider.totalExpense, color: Colors.red, width: 20, borderRadius: BorderRadius.circular(4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategories(ExpenseProvider provider) {
    final catData = provider.categoryWiseExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCats = catData.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Top Categories", style: AppStyles.heading3),
        const SizedBox(height: 15),
        ...topCats.map((cat) {
          final progress = cat.value / provider.totalExpense;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cat.key, style: AppStyles.body2),
                    Text("\$${cat.value.toStringAsFixed(0)}", style: AppStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInsights(ExpenseProvider expenseProvider, BudgetProvider budgetProvider) {
    return Column(
      children: [
        _insightCard(
          "Spending Pattern",
          "Your average daily spending is \$${(expenseProvider.totalExpense / 30).toStringAsFixed(2)}.",
          Icons.insights,
          AppColors.primary,
        ),
        const SizedBox(height: 15),
        _insightCard(
          "Budget Health",
          "You are at ${budgetProvider.budgetHealthScore.toStringAsFixed(0)}% of your financial health score.",
          Icons.health_and_safety,
          Colors.green,
        ),
      ],
    );
  }

  Widget _insightCard(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: AppStyles.body2, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportFAB() {
    return FloatingActionButton.extended(
      heroTag: 'fab_analytics',
      onPressed: () {},
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.download_rounded),
      label: const Text("Export Report"),
    );
  }
}
