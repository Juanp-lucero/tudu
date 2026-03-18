import 'package:flutter/material.dart';

import '../task.dart';
import '../task_repository.dart';
import '../ui_theme.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.isOffline,
  });

  final TaskRepository repository;
  final bool isOffline;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
      stream: widget.repository.watchAll(),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? const <Task>[];
        final todayTasks = tasks.where((t) => _isToday(t.dueAt)).toList();
        final todayDone = todayTasks.where((t) => t.completed).length;
        final todayTotal = todayTasks.length;

        final weekTasks = tasks.where((t) => _isThisWeek(t.dueAt)).toList();
        final weekDone = weekTasks.where((t) => t.completed).length;

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: tuduGreenDark,
            foregroundColor: Colors.white,
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => AddTaskScreen(repository: widget.repository),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            color: Colors.white,
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () => setState(() => _navIndex = 0),
                  icon: Icon(
                    Icons.home_rounded,
                    color: _navIndex == 0 ? tuduGreenDark : Colors.grey.shade400,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _navIndex = 1),
                  icon: Icon(
                    Icons.list_rounded,
                    color: _navIndex == 1 ? tuduGreenDark : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 48),
                IconButton(
                  onPressed: () => setState(() => _navIndex = 2),
                  icon: Icon(
                    Icons.pie_chart_rounded,
                    color: _navIndex == 2 ? tuduGreenDark : Colors.grey.shade400,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _navIndex = 3),
                  icon: Icon(
                    Icons.person_rounded,
                    color: _navIndex == 3 ? tuduGreenDark : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Tudu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (widget.isOffline)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                          ),
                          child: const Text(
                            'Offline',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _WeeklyCard(
                    percent: _safePercent(weekDone, weekTasks.length),
                    total: weekTasks.length,
                    done: weekDone,
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Today Tasks',
                    trailing: todayTotal == 0 ? '0 of 0' : '$todayDone of $todayTotal',
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: todayTasks.isEmpty
                          ? const Center(
                              child: Text(
                                'No tasks for today',
                                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: todayTasks.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final task = todayTasks[index];
                                return Dismissible(
                                  key: ValueKey(task.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade400,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                                  ),
                                  onDismissed: (_) => widget.repository.deleteById(task.id),
                                  child: _TaskTile(
                                    task: task,
                                    onToggle: (value) => widget.repository.setCompleted(
                                      id: task.id,
                                      completed: value,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({
    required this.percent,
    required this.total,
    required this.done,
  });

  final double percent;
  final int total;
  final int done;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 64,
            width: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 7,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(tuduGreenDark),
                ),
                Text(
                  '${(percent * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Weekly Tasks',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Pill(value: total.toString(), color: const Color(0xFFEAF7F2)),
                    const SizedBox(width: 8),
                    _Pill(value: done.toString(), color: const Color(0xFFFFEFF0), textColor: Colors.red.shade400),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.value,
    required this.color,
    this.textColor = tuduGreenDark,
  });

  final String value;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: textColor)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Text(
          trailing,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.onToggle});

  final Task task;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(task.dueAt);
    final chipColor = _chipColor(task.category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => onToggle(!task.completed),
            customBorder: const CircleBorder(),
            child: Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                color: task.completed ? tuduGreenDark : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: task.completed ? tuduGreenDark : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: task.completed
                  ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                decoration: task.completed ? TextDecoration.lineThrough : null,
                color: task.completed ? Colors.black45 : Colors.black87,
              ),
            ),
          ),
          if (time != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                time,
                style: TextStyle(fontWeight: FontWeight.w900, color: chipColor),
              ),
            ),
        ],
      ),
    );
  }
}

bool _isToday(DateTime? dateTime) {
  if (dateTime == null) return false;
  final now = DateTime.now();
  return dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day;
}

bool _isThisWeek(DateTime? dateTime) {
  if (dateTime == null) return false;
  final now = DateTime.now();
  final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 7));
  return dateTime.isAfter(startOfWeek.subtract(const Duration(milliseconds: 1))) && dateTime.isBefore(endOfWeek);
}

double _safePercent(int done, int total) {
  if (total <= 0) return 0;
  final p = done / total;
  if (p < 0) return 0;
  if (p > 1) return 1;
  return p;
}

String? _formatTime(DateTime? dateTime) {
  if (dateTime == null) return null;
  var hour = dateTime.hour;
  final am = hour < 12;
  if (hour == 0) hour = 12;
  if (hour > 12) hour -= 12;
  final suffix = am ? 'A.M' : 'P.M';
  return '$hour $suffix';
}

Color _chipColor(String? category) {
  switch ((category ?? '').toLowerCase()) {
    case 'healthy':
      return tuduGreenDark;
    case 'job':
      return const Color(0xFF3C87FF);
    case 'design':
      return const Color(0xFFFF9D2E);
    case 'education':
      return const Color(0xFF7B61FF);
    case 'sport':
      return const Color(0xFFFF4D67);
    default:
      return tuduGreenDark;
  }
}
