/// Defines the interval at which a recurring transaction repeats.
enum RecurrenceFrequency {
  /// Repeats every day.
  daily,
  
  /// Repeats once a week.
  weekly,
  
  /// Repeats every two weeks.
  biweekly,
  
  /// Repeats once a month.
  monthly,
  
  /// Repeats every three months.
  quarterly,
  
  /// Repeats once a year.
  yearly,
  
  /// Repeats based on a custom interval defined by the user.
  custom,
}
