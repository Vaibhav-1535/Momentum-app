import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';

// ─── STAT CARD ───────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String title, value, subtitle;
  final IconData icon;
  final Color color;
  const StatCard({super.key, required this.title, required this.value, required this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 16)),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(color: AppTheme.darkText, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: AppTheme.darkTextSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
        Text(subtitle, style: const TextStyle(color: AppTheme.darkTextMuted, fontSize: 10)),
      ]),
    );
  }
}

// ─── TASK CARD ───────────────────────────────────────────────
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete, onDelete;
  final VoidCallback? onTap;
  final bool isCompleted;
  const TaskCard({super.key, required this.task, required this.onComplete, required this.onDelete, this.onTap, this.isCompleted = false});

  Color get priorityColor {
    switch (task.priority) {
      case TaskPriority.low: return AppTheme.priorityLow;
      case TaskPriority.medium: return AppTheme.priorityMedium;
      case TaskPriority.high: return AppTheme.priorityHigh;
      case TaskPriority.urgent: return AppTheme.priorityUrgent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      background: Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: AppTheme.accentGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(14)), alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20), child: const Icon(Icons.check, color: AppTheme.accentGreen)),
      secondaryBackground: Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: AppTheme.accentRed.withOpacity(0.2), borderRadius: BorderRadius.circular(14)), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: AppTheme.accentRed)),
      onDismissed: (dir) => dir == DismissDirection.startToEnd ? onComplete() : onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: priorityColor, width: 3), top: const BorderSide(color: AppTheme.darkBorder), right: const BorderSide(color: AppTheme.darkBorder), bottom: const BorderSide(color: AppTheme.darkBorder)),
          ),
          child: Row(children: [
            GestureDetector(onTap: onComplete, child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 22, height: 22, decoration: BoxDecoration(color: task.isCompleted ? AppTheme.accentGreen : Colors.transparent, border: Border.all(color: task.isCompleted ? AppTheme.accentGreen : AppTheme.darkBorder, width: 2), borderRadius: BorderRadius.circular(6)), child: task.isCompleted ? const Icon(Icons.check, color: Colors.white, size: 14) : null)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(task.title, style: TextStyle(color: task.isCompleted ? AppTheme.darkTextMuted : AppTheme.darkText, fontSize: 14, fontWeight: FontWeight.w500, decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
              const SizedBox(height: 6),
              Row(children: [
                _tag(task.frequency.name, AppTheme.accentPrimary),
                const SizedBox(width: 6),
                _tag(task.priority.name, priorityColor),
                if (task.dueDate != null) ...[const SizedBox(width: 6), _tag(DateFormat('MMM d').format(task.dueDate!), task.isOverdue ? AppTheme.accentRed : AppTheme.darkTextMuted)],
              ]),
            ])),
            PopupMenuButton(icon: const Icon(Icons.more_vert, color: AppTheme.darkTextMuted, size: 18), color: AppTheme.darkSurface, itemBuilder: (_) => [
              const PopupMenuItem(value: 'complete', child: Row(children: [Icon(Icons.check, size: 16, color: AppTheme.accentGreen), SizedBox(width: 8), Text('Complete')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: AppTheme.accentRed), SizedBox(width: 8), Text('Delete')])),
            ], onSelected: (v) { if (v == 'complete') onComplete(); if (v == 'delete') onDelete(); }),
          ]),
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)), child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)));
}

// ─── HABIT CARD ──────────────────────────────────────────────
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;
  final bool isCompleted;
  const HabitCard({super.key, required this.habit, required this.onToggle, this.onDelete, this.isCompleted = false});

  Color _parseColor(String c) {
    try { return Color(int.parse(c.replaceAll('#', '0xFF'))); } catch (_) { return AppTheme.accentPrimary; }
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(habit.color);
    final completed = habit.isCompletedToday();
    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      background: Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: AppTheme.accentRed.withOpacity(0.2), borderRadius: BorderRadius.circular(16)), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: AppTheme.accentRed)),
      onDismissed: (_) => onDelete?.call(),
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: completed ? color.withOpacity(0.1) : AppTheme.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: completed ? color.withOpacity(0.4) : AppTheme.darkBorder, width: completed ? 1.5 : 1)),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)), child: Center(child: Text(habit.emoji, style: const TextStyle(fontSize: 22)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(habit.title, style: TextStyle(color: completed ? AppTheme.darkTextSecondary : AppTheme.darkText, fontSize: 15, fontWeight: FontWeight.w600, decoration: completed ? TextDecoration.lineThrough : null)),
              const SizedBox(height: 4),
              Row(children: [
                if (habit.currentStreak > 0) ...[const Icon(Icons.local_fire_department, size: 13, color: AppTheme.accentOrange), const SizedBox(width: 3), Text('${habit.currentStreak} day streak', style: const TextStyle(color: AppTheme.accentOrange, fontSize: 11, fontWeight: FontWeight.w500)), const SizedBox(width: 10)],
                Text('${(habit.completionRate * 100).round()}% rate', style: const TextStyle(color: AppTheme.darkTextMuted, fontSize: 11)),
              ]),
            ])),
            AnimatedContainer(duration: const Duration(milliseconds: 300), width: 32, height: 32, decoration: BoxDecoration(color: completed ? color : Colors.transparent, border: Border.all(color: completed ? color : AppTheme.darkBorder, width: 2), borderRadius: BorderRadius.circular(10)), child: completed ? const Icon(Icons.check, color: Colors.white, size: 18) : null),
          ]),
        ),
      ),
    );
  }
}

// ─── ADD TASK SHEET ──────────────────────────────────────────
class AddTaskSheet extends StatefulWidget {
  final Function(Task) onAdd;
  final Task? existingTask;
  const AddTaskSheet({super.key, required this.onAdd, this.existingTask});
  @override State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TaskFrequency _frequency = TaskFrequency.daily;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _titleCtrl.text = widget.existingTask!.title;
      _descCtrl.text = widget.existingTask!.description ?? '';
      _frequency = widget.existingTask!.frequency;
      _priority = widget.existingTask!.priority;
      _dueDate = widget.existingTask!.dueDate;
    }
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final task = Task(
      id: widget.existingTask?.id ?? const Uuid().v4(),
      userId: widget.existingTask?.userId ?? '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      frequency: _frequency, priority: _priority,
      status: widget.existingTask?.status ?? TaskStatus.pending,
      createdAt: widget.existingTask?.createdAt ?? DateTime.now(),
      dueDate: _dueDate,
    );
    widget.onAdd(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(key: _formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.darkBorder, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        Text(widget.existingTask != null ? 'Edit Task' : 'New Task', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Task title'), autofocus: true, validator: (v) => v?.isEmpty == true ? 'Required' : null),
        const SizedBox(height: 16),
        TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description (optional)'), maxLines: 2),
        const SizedBox(height: 20),
        Text('Frequency', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 10),
        Row(children: TaskFrequency.values.map((f) {
          final isSelected = _frequency == f;
          final labels = {TaskFrequency.daily: 'Daily', TaskFrequency.weekly: 'Weekly', TaskFrequency.monthly: 'Monthly', TaskFrequency.oneTime: 'Once'};
          return Expanded(child: GestureDetector(onTap: () => setState(() => _frequency = f), child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: isSelected ? AppTheme.accentPrimary : AppTheme.darkCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: isSelected ? AppTheme.accentPrimary : AppTheme.darkBorder)), child: Text(labels[f]!, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : AppTheme.darkTextMuted, fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)))));
        }).toList()),
        const SizedBox(height: 20),
        Text('Priority', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 10),
        Row(children: TaskPriority.values.map((p) {
          final colors = {TaskPriority.low: AppTheme.priorityLow, TaskPriority.medium: AppTheme.priorityMedium, TaskPriority.high: AppTheme.priorityHigh, TaskPriority.urgent: AppTheme.priorityUrgent};
          final color = colors[p]!;
          final isSelected = _priority == p;
          return Expanded(child: GestureDetector(onTap: () => setState(() => _priority = p), child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: isSelected ? color.withOpacity(0.2) : Colors.transparent, border: Border.all(color: isSelected ? color : AppTheme.darkBorder), borderRadius: BorderRadius.circular(10)), child: Column(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(height: 4), Text(p.name[0].toUpperCase() + p.name.substring(1), style: TextStyle(color: isSelected ? color : AppTheme.darkTextMuted, fontSize: 9, fontWeight: FontWeight.w500))]))));
        }).toList()),
        const SizedBox(height: 20),
        GestureDetector(onTap: () async {
          final date = await showDatePicker(context: context, initialDate: _dueDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
          if (date != null) setState(() => _dueDate = date);
        }, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.darkCard, border: Border.all(color: AppTheme.darkBorder), borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.calendar_today, size: 16, color: AppTheme.darkTextSecondary), const SizedBox(width: 8), Text(_dueDate != null ? DateFormat('MMM d, yyyy').format(_dueDate!) : 'Set due date (optional)', style: const TextStyle(color: AppTheme.darkTextSecondary, fontSize: 13))]))),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: Text(widget.existingTask != null ? 'Update Task' : 'Add Task', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))),
      ]))),
    );
  }
}

// ─── ADD HABIT SHEET ─────────────────────────────────────────
class AddHabitSheet extends StatefulWidget {
  final Function(Habit) onAdd;
  const AddHabitSheet({super.key, required this.onAdd});
  @override State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  HabitFrequency _frequency = HabitFrequency.daily;
  HabitCategory _category = HabitCategory.health;
  String _emoji = '💪';
  String _color = '#6366F1';

  final _emojis = ['💪', '🏃', '🧘', '📚', '💧', '🥗', '😴', '🎯', '✨', '🎨', '🎵', '💰', '🧠', '❤️', '🌿', '⚡', '🔥', '🌟', '🏆', '🦋'];
  final _colors = ['#6366F1', '#8B5CF6', '#EC4899', '#EF4444', '#F59E0B', '#10B981', '#06B6D4', '#3B82F6'];

  @override void dispose() { _titleCtrl.dispose(); super.dispose(); }

  Color _parseColor(String c) { try { return Color(int.parse(c.replaceAll('#', '0xFF'))); } catch (_) { return AppTheme.accentPrimary; } }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onAdd(Habit(id: const Uuid().v4(), userId: '', title: _titleCtrl.text.trim(), frequency: _frequency, category: _category, emoji: _emoji, color: _color, createdAt: DateTime.now()));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(key: _formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.darkBorder, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        Text('New Habit', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        Row(children: [
          GestureDetector(onTap: () => showModalBottomSheet(context: context, backgroundColor: AppTheme.darkSurface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (ctx) => Padding(padding: const EdgeInsets.all(24), child: GridView.count(shrinkWrap: true, crossAxisCount: 8, children: _emojis.map((e) => GestureDetector(onTap: () { setState(() => _emoji = e); Navigator.pop(ctx); }, child: Center(child: Text(e, style: const TextStyle(fontSize: 24))))).toList()))),
            child: Container(width: 56, height: 56, decoration: BoxDecoration(color: _parseColor(_color).withOpacity(0.15), borderRadius: BorderRadius.circular(14), border: Border.all(color: _parseColor(_color).withOpacity(0.4))), child: Center(child: Text(_emoji, style: const TextStyle(fontSize: 26))))),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Habit name'), autofocus: true, validator: (v) => v?.isEmpty == true ? 'Required' : null)),
        ]),
        const SizedBox(height: 20),
        Text('Color', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 10),
        Wrap(spacing: 10, children: _colors.map((c) { final color = _parseColor(c); final isSelected = _color == c; return GestureDetector(onTap: () => setState(() => _color = c), child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 36, height: 36, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: isSelected ? Border.all(color: Colors.white, width: 2) : null), child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null)); }).toList()),
        const SizedBox(height: 20),
        Text('Frequency', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 10),
        Row(children: HabitFrequency.values.map((f) { final isSelected = _frequency == f; final labels = {HabitFrequency.daily: 'Daily', HabitFrequency.weekly: 'Weekly', HabitFrequency.monthly: 'Monthly'}; return Expanded(child: GestureDetector(onTap: () => setState(() => _frequency = f), child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: isSelected ? AppTheme.accentPrimary : AppTheme.darkCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: isSelected ? AppTheme.accentPrimary : AppTheme.darkBorder)), child: Text(labels[f]!, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : AppTheme.darkTextMuted, fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400))))); }).toList()),
        const SizedBox(height: 20),
        Text('Category', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: HabitCategory.values.map((c) { final isSelected = _category == c; final color = AppTheme.getHabitCategoryColor(c.name); final label = c.name[0].toUpperCase() + c.name.substring(1); return GestureDetector(onTap: () => setState(() => _category = c), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: isSelected ? color.withOpacity(0.2) : AppTheme.darkCard, borderRadius: BorderRadius.circular(8), border: Border.all(color: isSelected ? color : AppTheme.darkBorder)), child: Text(label, style: TextStyle(color: isSelected ? color : AppTheme.darkTextMuted, fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)))); }).toList()),
        const SizedBox(height: 28),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Add Habit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))),
      ]))),
    );
  }
}
