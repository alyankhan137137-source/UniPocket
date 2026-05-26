class StudentSnapshot {
  final String studentName;
  final double currentBalance;
  final double monthlyAllowance;
  final double spentThisMonth;
  final double remainingBudget;
  final List<Map<String, dynamic>> recentTransactions;
  final DateTime lastUpdated;

  StudentSnapshot({
    required this.studentName,
    required this.currentBalance,
    required this.monthlyAllowance,
    required this.spentThisMonth,
    required this.remainingBudget,
    required this.recentTransactions,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentName': studentName,
      'currentBalance': currentBalance,
      'monthlyAllowance': monthlyAllowance,
      'spentThisMonth': spentThisMonth,
      'remainingBudget': remainingBudget,
      'recentTransactions': recentTransactions,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory StudentSnapshot.fromMap(Map<String, dynamic> map) {
    return StudentSnapshot(
      studentName: map['studentName'] as String,
      currentBalance: (map['currentBalance'] as num).toDouble(),
      monthlyAllowance: (map['monthlyAllowance'] as num).toDouble(),
      spentThisMonth: (map['spentThisMonth'] as num).toDouble(),
      remainingBudget: (map['remainingBudget'] as num).toDouble(),
      recentTransactions: List<Map<String, dynamic>>.from(map['recentTransactions'] as List),
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }
}
