import 'package:equatable/equatable.dart';

// ─── APP USER ───────────────────────────────────────────────
class AppUser extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  String get initials {
    final parts = displayName.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  AppUser copyWith({String? id, String? email, String? displayName, DateTime? createdAt}) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, createdAt];
}

// ─── TASK ────────────────────────────────────────────────────
enum TaskFrequency { daily, weekly, monthly, oneTime }
enum TaskPriority { low, medium, high, urgent }
enum TaskStatus { pending, inProgress, completed, overdue }

class Task extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final TaskFrequency frequency;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final bool isArchived;
  final int estimatedMinutes;

  const Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.frequency,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.dueDate,
    this.completedAt,
    this.isArchived = false,
    this.estimatedMinutes = 30,
  });

  bool get isCompleted => status == TaskStatus.completed;
  bool get isOverdue =>
      dueDate != null && DateTime.now().isAfter(dueDate!) && status != TaskStatus.completed;

  Task copyWith({
    String? id, String? userId, String? title, String? description,
    TaskFrequency? frequency, TaskPriority? priority, TaskStatus? status,
    DateTime? createdAt, DateTime? dueDate, DateTime? completedAt,
    bool? isArchived, int? estimatedMinutes,
  }) {
    return Task(
      id: id ?? this.id, userId: userId ?? this.userId,
      title: title ?? this.title, description: description ?? this.description,
      frequency: frequency ?? this.frequency, priority: priority ?? this.priority,
      status: status ?? this.status, createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate, completedAt: completedAt ?? this.completedAt,
      isArchived: isArchived ?? this.isArchived,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, frequency, priority, status, createdAt];
}

// ─── HABIT ───────────────────────────────────────────────────
enum HabitFrequency { daily, weekly, monthly }
enum HabitCategory { health, fitness, mindfulness, learning, social, productivity, finance, creativity, other }

class Habit extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final HabitFrequency frequency;
  final HabitCategory category;
  final String emoji;
  final String color;
  final DateTime createdAt;
  final List<DateTime> completedDates;
  final bool isArchived;

  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.frequency,
    required this.category,
    required this.emoji,
    required this.color,
    required this.createdAt,
    this.completedDates = const [],
    this.isArchived = false,
  });

  int get currentStreak {
    if (completedDates.isEmpty) return 0;
    final sorted = completedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet().toList()..sort((a, b) => b.compareTo(a));
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (sorted.first != today && sorted.first != yesterday) return 0;
    int streak = 0;
    DateTime expected = sorted.first;
    for (final date in sorted) {
      if (date == expected) { streak++; expected = expected.subtract(const Duration(days: 1)); }
      else break;
    }
    return streak;
  }

  int get bestStreak {
    if (completedDates.isEmpty) return 0;
    final sorted = completedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet().toList()..sort();
    int best = 1, current = 1;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
        current++;
        if (current > best) best = current;
      } else { current = 1; }
    }
    return best;
  }

  double get completionRate {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recent = completedDates
        .where((d) => d.isAfter(thirtyDaysAgo))
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet().length;
    return recent / 30.0;
  }

  bool isCompletedToday() {
    final today = DateTime.now();
    return completedDates.any((d) => d.year == today.year && d.month == today.month && d.day == today.day);
  }

  bool isCompletedOnDate(DateTime date) {
    return completedDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
  }

  Habit copyWith({
    String? id, String? userId, String? title, String? description,
    HabitFrequency? frequency, HabitCategory? category,
    String? emoji, String? color, DateTime? createdAt,
    List<DateTime>? completedDates, bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id, userId: userId ?? this.userId,
      title: title ?? this.title, description: description ?? this.description,
      frequency: frequency ?? this.frequency, category: category ?? this.category,
      emoji: emoji ?? this.emoji, color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? this.completedDates,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, frequency, category, createdAt];
}
