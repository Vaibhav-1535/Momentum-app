import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../widgets/widgets.dart';

// ─── AUTH SCREEN ─────────────────────────────────────────────
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignIn = true, _obscure = true;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); _nameCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = _isSignIn
        ? await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text)
        : await auth.signUp(_emailCtrl.text.trim(), _passCtrl.text, _nameCtrl.text.trim());
    if (!success && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Error'), backgroundColor: AppTheme.accentRed, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0A0A0F), Color(0xFF0F0A1A), Color(0xFF0A0A0F)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 40),
          Container(width: 56, height: 56, decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppTheme.accentPrimary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]), child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 32)),
          const SizedBox(height: 24),
          Text(_isSignIn ? 'Welcome\nback.' : 'Create your\naccount.', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 8),
          Text(_isSignIn ? 'Track your habits and tasks' : 'Start your productivity journey', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 48),
          Form(key: _formKey, child: Column(children: [
            if (!_isSignIn) ...[TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v?.isEmpty == true ? 'Required' : null), const SizedBox(height: 16)],
            TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), keyboardType: TextInputType.emailAddress, validator: (v) { if (v?.isEmpty == true) return 'Required'; if (!v!.contains('@')) return 'Invalid email'; return null; }),
            const SizedBox(height: 16),
            TextFormField(controller: _passCtrl, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: () => setState(() => _obscure = !_obscure))), obscureText: _obscure, validator: (v) => v?.isEmpty == true ? 'Required' : null),
          ])),
          const SizedBox(height: 24),
          Consumer<AuthProvider>(builder: (context, auth, _) => SizedBox(width: double.infinity, child: ElevatedButton(onPressed: auth.isLoading ? null : _submit, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: auth.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_isSignIn ? 'Sign In' : 'Create Account', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(_isSignIn ? "Don't have an account? " : 'Already have an account? ', style: Theme.of(context).textTheme.bodyMedium),
            GestureDetector(onTap: () => setState(() { _isSignIn = !_isSignIn; context.read<AuthProvider>().clearError(); }), child: Text(_isSignIn ? 'Sign Up' : 'Sign In', style: const TextStyle(color: AppTheme.accentPrimary, fontWeight: FontWeight.w600))),
          ]),
        ]))),
      ),
    );
  }
}

// ─── MAIN SCREEN (Bottom Nav) ────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  final _screens = [const DashboardScreen(), const TasksScreen(), const HabitsScreen(), const CalendarScreen(), const AnalyticsScreen()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<TaskProvider>().loadTasks(auth.user!.id);
        context.read<HabitProvider>().loadHabits(auth.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: AppTheme.darkSurface, border: Border(top: BorderSide(color: AppTheme.darkBorder))),
        child: SafeArea(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _navItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Home'),
          _navItem(1, Icons.check_circle_outline, Icons.check_circle, 'Tasks'),
          _navItem(2, Icons.loop_outlined, Icons.loop, 'Habits'),
          _navItem(3, Icons.calendar_today_outlined, Icons.calendar_today, 'Calendar'),
          _navItem(4, Icons.bar_chart_outlined, Icons.bar_chart, 'Stats'),
        ]))),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, IconData activeIcon, String label) {
    final isSelected = _index == idx;
    return GestureDetector(onTap: () => setState(() => _index = idx), behavior: HitTestBehavior.opaque, child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: isSelected ? AppTheme.accentPrimary.withOpacity(0.15) : Colors.transparent, borderRadius: BorderRadius.circular(12)), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(isSelected ? activeIcon : icon, color: isSelected ? AppTheme.accentPrimary : AppTheme.darkTextMuted, size: 22), const SizedBox(height: 4), Text(label, style: TextStyle(color: isSelected ? AppTheme.accentPrimary : AppTheme.darkTextMuted, fontSize: 10, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400))])));
  }
}

// ─── DASHBOARD SCREEN ────────────────────────────────────────
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tasks = context.watch<TaskProvider>();
    final habits = context.watch<HabitProvider>();
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Container(width: 32, height: 32, decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20)), const SizedBox(width: 10), const Text('Momentum')]),
        actions: [Container(margin: const EdgeInsets.only(right: 16), width: 36, height: 36, decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(10)), child: Center(child: Text(auth.user?.initials ?? '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))))],
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$greeting,', style: Theme.of(context).textTheme.bodyMedium),
        Text(auth.user?.displayName.split(' ').first ?? 'Friend', style: Theme.of(context).textTheme.displayMedium),
        Text(DateFormat('EEEE, MMMM d').format(now), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.accentPrimary)),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: StatCard(title: 'Tasks Today', value: '${tasks.pendingTasks.length}', icon: Icons.check_circle_outline, color: AppTheme.accentPrimary, subtitle: '${tasks.completedTasks.length} done')),
          const SizedBox(width: 12),
          Expanded(child: StatCard(title: 'Habits', value: '${habits.completedTodayHabits.length}/${habits.habits.length}', icon: Icons.local_fire_department_outlined, color: AppTheme.accentOrange, subtitle: 'today')),
          const SizedBox(width: 12),
          Expanded(child: StatCard(title: 'Streak', value: '${habits.totalStreak}', icon: Icons.bolt_rounded, color: AppTheme.accentSecondary, subtitle: 'days')),
        ]),
        const SizedBox(height: 24),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.darkBorder)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Today's Progress", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _circle(context, 'Tasks', (tasks.completionPercentage / 100.0).clamp(0.0, 1.0), AppTheme.accentPrimary),
            _circle(context, 'Habits', habits.habits.isEmpty ? 0.0 : (habits.completedTodayHabits.length / habits.habits.length).clamp(0.0, 1.0), AppTheme.accentOrange),
            _circle(context, 'Overall', habits.habits.isEmpty && tasks.tasks.isEmpty ? 0.0 : ((tasks.completionPercentage / 100.0 + (habits.habits.isEmpty ? 0.0 : habits.completedTodayHabits.length / habits.habits.length)) / 2).clamp(0.0, 1.0), AppTheme.accentGreen),
          ]),
        ])),
        const SizedBox(height: 24),
        if (habits.todayHabits.isNotEmpty) ...[
          Row(children: [Text("Today's Habits", style: Theme.of(context).textTheme.headlineSmall), const Spacer(), TextButton(onPressed: () {}, child: const Text('See all'))]),
          const SizedBox(height: 12),
          ...habits.todayHabits.take(3).map((h) => HabitCard(habit: h, onToggle: () => context.read<HabitProvider>().toggleHabit(h))),
        ],
        if (tasks.pendingTasks.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(children: [Text('Upcoming Tasks', style: Theme.of(context).textTheme.headlineSmall), const Spacer(), TextButton(onPressed: () {}, child: const Text('See all'))]),
          const SizedBox(height: 12),
          ...tasks.pendingTasks.take(3).map((t) => TaskCard(task: t, onComplete: () => context.read<TaskProvider>().completeTask(t.id), onDelete: () => context.read<TaskProvider>().deleteTask(t.id))),
        ],
        const SizedBox(height: 100),
      ])),
    );
  }

  Widget _circle(BuildContext context, String label, double percent, Color color) {
    return Column(children: [
      CircularPercentIndicator(radius: 42, lineWidth: 6, percent: percent, center: Text('${(percent * 100).round()}%', style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w700, fontSize: 13)), progressColor: color, backgroundColor: color.withOpacity(0.15), circularStrokeCap: CircularStrokeCap.round, animation: true, animationDuration: 1200),
      const SizedBox(height: 8),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

// ─── TASKS SCREEN ────────────────────────────────────────────
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override void initState() { super.initState(); _tab = TabController(length: 4, vsync: this); }
  @override void dispose() { _tab.dispose(); super.dispose(); }

  List<Task> _tasks(TaskProvider p, int i) {
    switch (i) {
      case 0: return p.pendingTasks;
      case 1: return p.dailyTasks;
      case 2: return p.weeklyTasks;
      case 3: return p.monthlyTasks;
      default: return p.tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks'), bottom: TabBar(controller: _tab, tabs: const [Tab(text: 'All'), Tab(text: 'Daily'), Tab(text: 'Weekly'), Tab(text: 'Monthly')], indicatorColor: AppTheme.accentPrimary, labelColor: AppTheme.accentPrimary, unselectedLabelColor: AppTheme.darkTextMuted, dividerColor: AppTheme.darkBorder)),
      floatingActionButton: FloatingActionButton(onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => AddTaskSheet(onAdd: (t) => context.read<TaskProvider>().addTask(t.copyWith(userId: context.read<AuthProvider>().user?.id ?? '')))), child: const Icon(Icons.add)),
      body: Consumer<TaskProvider>(builder: (context, p, _) => TabBarView(controller: _tab, children: List.generate(4, (i) {
        final tasks = _tasks(p, i);
        if (tasks.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check_circle_outline, size: 64, color: AppTheme.darkTextMuted), const SizedBox(height: 16), Text('No tasks here', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.darkTextSecondary)), const SizedBox(height: 8), Text('Tap + to add a task', style: Theme.of(context).textTheme.bodyMedium)]));
        return ListView.builder(padding: const EdgeInsets.all(16), itemCount: tasks.length, itemBuilder: (_, j) { final t = tasks[j]; return TaskCard(task: t, onComplete: () => p.completeTask(t.id), onDelete: () => p.deleteTask(t.id)); });
      }))),
    );
  }
}

// ─── HABITS SCREEN ───────────────────────────────────────────
class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      floatingActionButton: FloatingActionButton(onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => AddHabitSheet(onAdd: (h) => context.read<HabitProvider>().addHabit(h.copyWith(userId: context.read<AuthProvider>().user?.id ?? '')))), child: const Icon(Icons.add)),
      body: Consumer<HabitProvider>(builder: (context, p, _) {
        return CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppTheme.accentPrimary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]), child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${p.completedTodayHabits.length} of ${p.habits.length}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)), const SizedBox(height: 4), const Text('Habits completed today', style: TextStyle(color: Colors.white70, fontSize: 13))])),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)), child: Column(children: [const Icon(Icons.local_fire_department, color: Colors.white, size: 28), const SizedBox(height: 4), Text('${p.totalStreak}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)), const Text('streak', style: TextStyle(color: Colors.white70, fontSize: 10))])),
            ])),
            const SizedBox(height: 24),
            if (p.todayHabits.isNotEmpty) ...[Row(children: [Text("Today's Habits", style: Theme.of(context).textTheme.headlineSmall), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.accentPrimary.withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: Text('${p.todayHabits.length}', style: const TextStyle(color: AppTheme.accentPrimary, fontSize: 12, fontWeight: FontWeight.w600)))]), const SizedBox(height: 12)],
          ]))),
          if (p.habits.isEmpty) SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(48), child: Center(child: Column(children: [const Text('🌱', style: TextStyle(fontSize: 56)), const SizedBox(height: 16), Text('No habits yet', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.darkTextSecondary)), const SizedBox(height: 8), Text('Tap + to start building habits', style: Theme.of(context).textTheme.bodyMedium)]))))
          else SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16), sliver: SliverList(delegate: SliverChildBuilderDelegate((_, i) { final h = p.todayHabits[i]; return HabitCard(habit: h, onToggle: () => p.toggleHabit(h), onDelete: () => p.deleteHabit(h.id)); }, childCount: p.todayHabits.length))),
          if (p.completedTodayHabits.isNotEmpty) ...[
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text('Completed', style: Theme.of(context).textTheme.headlineSmall))),
            SliverPadding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), sliver: SliverList(delegate: SliverChildBuilderDelegate((_, i) { final h = p.completedTodayHabits[i]; return HabitCard(habit: h, onToggle: () => p.toggleHabit(h), onDelete: () => p.deleteHabit(h.id), isCompleted: true); }, childCount: p.completedTodayHabits.length))),
          ],
        ]);
      }),
    );
  }
}

// ─── CALENDAR SCREEN ─────────────────────────────────────────
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selected = DateTime.now(), _focused = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Consumer<TaskProvider>(builder: (context, p, _) {
        final dayTasks = p.tasks.where((t) => t.dueDate != null && isSameDay(t.dueDate!, _selected)).toList();
        final events = <DateTime, List<Task>>{};
        for (final t in p.tasks) { if (t.dueDate != null) { final k = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day); events[k] = [...(events[k] ?? []), t]; } }
        return Column(children: [
          Container(color: AppTheme.darkSurface, child: TableCalendar<Task>(firstDay: DateTime.utc(2020, 1, 1), lastDay: DateTime.utc(2030, 12, 31), focusedDay: _focused, calendarFormat: _format, selectedDayPredicate: (d) => isSameDay(_selected, d), eventLoader: (d) => events[DateTime(d.year, d.month, d.day)] ?? [], onDaySelected: (s, f) => setState(() { _selected = s; _focused = f; }), onFormatChanged: (f) => setState(() => _format = f), onPageChanged: (f) => _focused = f, calendarStyle: CalendarStyle(defaultTextStyle: const TextStyle(color: AppTheme.darkText), weekendTextStyle: const TextStyle(color: AppTheme.darkTextSecondary), outsideTextStyle: const TextStyle(color: AppTheme.darkTextMuted), todayDecoration: BoxDecoration(color: AppTheme.accentPrimary.withOpacity(0.3), shape: BoxShape.circle), selectedDecoration: const BoxDecoration(color: AppTheme.accentPrimary, shape: BoxShape.circle), markerDecoration: const BoxDecoration(color: AppTheme.accentOrange, shape: BoxShape.circle)), headerStyle: HeaderStyle(titleTextStyle: Theme.of(context).textTheme.headlineSmall!, formatButtonTextStyle: const TextStyle(color: AppTheme.accentPrimary, fontSize: 12), formatButtonDecoration: BoxDecoration(border: Border.all(color: AppTheme.accentPrimary), borderRadius: BorderRadius.circular(8)), leftChevronIcon: const Icon(Icons.chevron_left, color: AppTheme.darkTextSecondary), rightChevronIcon: const Icon(Icons.chevron_right, color: AppTheme.darkTextSecondary)), daysOfWeekStyle: const DaysOfWeekStyle(weekdayStyle: TextStyle(color: AppTheme.darkTextSecondary, fontSize: 12), weekendStyle: TextStyle(color: AppTheme.darkTextMuted, fontSize: 12)))),
          const Divider(height: 1),
          Expanded(child: dayTasks.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('📅', style: TextStyle(fontSize: 48)), const SizedBox(height: 16), Text(DateFormat('MMMM d').format(_selected), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.darkTextSecondary)), const SizedBox(height: 8), Text('No tasks for this day', style: Theme.of(context).textTheme.bodyMedium)]))
            : ListView.builder(padding: const EdgeInsets.all(16), itemCount: dayTasks.length, itemBuilder: (_, i) { final t = dayTasks[i]; return TaskCard(task: t, onComplete: () => p.completeTask(t.id), onDelete: () => p.deleteTask(t.id)); })),
        ]);
      }),
    );
  }
}

// ─── ANALYTICS SCREEN ────────────────────────────────────────
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Consumer2<TaskProvider, HabitProvider>(builder: (context, tasks, habits, _) {
        return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Overview', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5, children: [
            StatCard(title: 'Total Tasks', value: '${tasks.tasks.length}', icon: Icons.task_alt, color: AppTheme.accentPrimary, subtitle: 'all time'),
            StatCard(title: 'Completed', value: '${tasks.completedTasks.length}', icon: Icons.check_circle, color: AppTheme.accentGreen, subtitle: 'done'),
            StatCard(title: 'Total Habits', value: '${habits.habits.length}', icon: Icons.repeat, color: AppTheme.accentSecondary, subtitle: 'tracked'),
            StatCard(title: 'Best Streak', value: '${habits.habits.isEmpty ? 0 : habits.habits.map((h) => h.bestStreak).reduce((a, b) => a > b ? a : b)}', icon: Icons.emoji_events, color: AppTheme.accentOrange, subtitle: 'days'),
          ]),
          const SizedBox(height: 24),
          if (tasks.tasks.isNotEmpty) _taskStatusChart(context, tasks),
          const SizedBox(height: 24),
          if (habits.habits.isNotEmpty) _habitPerformance(context, habits),
          const SizedBox(height: 100),
        ]));
      }),
    );
  }

  Widget _taskStatusChart(BuildContext context, TaskProvider tasks) {
    final completed = tasks.completedTasks.length;
    final pending = tasks.pendingTasks.length;
    final total = completed + pending;
    if (total == 0) return const SizedBox.shrink();
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.darkBorder)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Task Status', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 20),
      Row(children: [
        SizedBox(width: 150, height: 150, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 40, sections: [
          PieChartSectionData(color: AppTheme.accentGreen, value: completed.toDouble(), title: '${(completed / total * 100).round()}%', radius: 30, titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
          PieChartSectionData(color: AppTheme.accentPrimary, value: pending.toDouble(), title: '${(pending / total * 100).round()}%', radius: 30, titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
        ]))),
        const SizedBox(width: 24),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _legend(context, 'Completed', completed, AppTheme.accentGreen),
          const SizedBox(height: 12),
          _legend(context, 'Pending', pending, AppTheme.accentPrimary),
        ])),
      ]),
    ]));
  }

  Widget _legend(BuildContext context, String label, int count, Color color) {
    return Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))), const SizedBox(width: 8), Text(label, style: Theme.of(context).textTheme.bodyMedium), const Spacer(), Text('$count', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppTheme.darkText))]);
  }

  Widget _habitPerformance(BuildContext context, HabitProvider habits) {
    final sorted = List<Habit>.from(habits.habits)..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.darkBorder)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Top Habits by Streak', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 16),
      ...sorted.take(5).map((h) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(children: [
        Text(h.emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text(h.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.darkText, fontWeight: FontWeight.w500)), const Spacer(), Text('${h.currentStreak} days', style: const TextStyle(color: AppTheme.accentPrimary, fontSize: 11, fontWeight: FontWeight.w600))]),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: sorted.first.currentStreak > 0 ? h.currentStreak / sorted.first.currentStreak : 0.0, backgroundColor: AppTheme.darkBorder, valueColor: AlwaysStoppedAnimation(AppTheme.getHabitCategoryColor(h.category.name)), minHeight: 6)),
        ])),
      ]))),
    ]));
  }
}
