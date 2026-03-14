import 'package:uuid/uuid.dart';
import '../models/models.dart';

// ─── AUTH SERVICE (Demo - no Firebase) ──────────────────────
class AuthService {
  AppUser? _currentUser;
  final _uuid = const Uuid();

  AppUser? get currentUser => _currentUser;

  Stream<AppUser?> get authStateChanges async* {
    yield _currentUser;
  }

  Future<AppUser?> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = AppUser(
      id: _uuid.v4(),
      email: email,
      displayName: email.split('@')[0],
      createdAt: DateTime.now(),
    );
    return _currentUser;
  }

  Future<AppUser?> signUpWithEmail(String email, String password, String displayName) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = AppUser(
      id: _uuid.v4(),
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );
    return _currentUser;
  }

  Future<void> signOut() async {
    _currentUser = null;
  }

  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

// ─── TASK SERVICE (Local) ────────────────────────────────────
class TaskService {
  final _uuid = const Uuid();
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  Future<Task> createTask(Task task) async {
    final newTask = task.copyWith(id: _uuid.v4(), createdAt: DateTime.now());
    _tasks.insert(0, newTask);
    return newTask;
  }

  Future<void> updateTask(Task task) async {
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i != -1) _tasks[i] = task;
  }

  Future<void> completeTask(String taskId) async {
    final i = _tasks.indexWhere((t) => t.id == taskId);
    if (i != -1) {
      _tasks[i] = _tasks[i].copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
      );
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
  }
}

// ─── HABIT SERVICE (Local) ───────────────────────────────────
class HabitService {
  final _uuid = const Uuid();
  final List<Habit> _habits = [];

  List<Habit> get habits => List.unmodifiable(_habits);

  Future<Habit> createHabit(Habit habit) async {
    final newHabit = habit.copyWith(id: _uuid.v4(), createdAt: DateTime.now());
    _habits.add(newHabit);
    return newHabit;
  }

  Future<void> updateHabit(Habit habit) async {
    final i = _habits.indexWhere((h) => h.id == habit.id);
    if (i != -1) _habits[i] = habit;
  }

  Future<void> toggleHabit(String habitId, DateTime date) async {
    final i = _habits.indexWhere((h) => h.id == habitId);
    if (i == -1) return;
    final habit = _habits[i];
    final normalized = DateTime(date.year, date.month, date.day);
    final isCompleted = habit.isCompletedOnDate(normalized);
    List<DateTime> updated = List.from(habit.completedDates);
    if (isCompleted) {
      updated.removeWhere((d) => d.year == normalized.year && d.month == normalized.month && d.day == normalized.day);
    } else {
      updated.add(normalized);
    }
    _habits[i] = habit.copyWith(completedDates: updated);
  }

  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((h) => h.id == habitId);
  }

  Map<DateTime, int> getHeatmapData() {
    final Map<DateTime, int> data = {};
    for (final habit in _habits) {
      for (final date in habit.completedDates) {
        final key = DateTime(date.year, date.month, date.day);
        data[key] = (data[key] ?? 0) + 1;
      }
    }
    return data;
  }
}
