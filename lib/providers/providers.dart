import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

// ─── AUTH PROVIDER ───────────────────────────────────────────
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      _user = await _authService.signInWithEmail(email, password);
      _isLoading = false; notifyListeners(); return true;
    } catch (e) {
      _error = e.toString(); _isLoading = false; notifyListeners(); return false;
    }
  }

  Future<bool> signUp(String email, String password, String displayName) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      _user = await _authService.signUpWithEmail(email, password, displayName);
      _isLoading = false; notifyListeners(); return true;
    } catch (e) {
      _error = e.toString(); _isLoading = false; notifyListeners(); return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null; notifyListeners();
  }

  void clearError() { _error = null; notifyListeners(); }
}

// ─── TASK PROVIDER ───────────────────────────────────────────
class TaskProvider extends ChangeNotifier {
  final TaskService _service = TaskService();

  List<Task> get tasks => _service.tasks;
  List<Task> get completedTasks => tasks.where((t) => t.isCompleted).toList();
  List<Task> get pendingTasks => tasks.where((t) => !t.isCompleted && !t.isArchived).toList();
  List<Task> get dailyTasks => tasks.where((t) => t.frequency == TaskFrequency.daily && !t.isCompleted).toList();
  List<Task> get weeklyTasks => tasks.where((t) => t.frequency == TaskFrequency.weekly && !t.isCompleted).toList();
  List<Task> get monthlyTasks => tasks.where((t) => t.frequency == TaskFrequency.monthly && !t.isCompleted).toList();
  List<Task> get overdueTasks => tasks.where((t) => t.isOverdue).toList();
  int get completionPercentage => tasks.isEmpty ? 0 : ((completedTasks.length / tasks.length) * 100).round();

  void loadTasks(String userId) { notifyListeners(); }

  Future<void> addTask(Task task) async {
    await _service.createTask(task); notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _service.updateTask(task); notifyListeners();
  }

  Future<void> completeTask(String id) async {
    await _service.completeTask(id); notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _service.deleteTask(id); notifyListeners();
  }
}

// ─── HABIT PROVIDER ──────────────────────────────────────────
class HabitProvider extends ChangeNotifier {
  final HabitService _service = HabitService();

  List<Habit> get habits => _service.habits;
  List<Habit> get todayHabits => habits.where((h) => !h.isCompletedToday() && !h.isArchived).toList();
  List<Habit> get completedTodayHabits => habits.where((h) => h.isCompletedToday()).toList();
  int get totalStreak => habits.fold(0, (sum, h) => sum + h.currentStreak);

  void loadHabits(String userId) { notifyListeners(); }

  Future<void> addHabit(Habit habit) async {
    await _service.createHabit(habit); notifyListeners();
  }

  Future<void> toggleHabit(Habit habit, {DateTime? date}) async {
    await _service.toggleHabit(habit.id, date ?? DateTime.now()); notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    await _service.updateHabit(habit); notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await _service.deleteHabit(id); notifyListeners();
  }

  Map<DateTime, int> getHeatmapData() => _service.getHeatmapData();
}

// ─── THEME PROVIDER ──────────────────────────────────────────
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;
  void toggleTheme() { _isDarkMode = !_isDarkMode; notifyListeners(); }
}
