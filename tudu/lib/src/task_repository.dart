import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'task.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchAll();
  Future<void> add(TaskDraft draft);
  Future<void> setCompleted({required String id, required bool completed});
  Future<void> deleteById(String id);

  static TaskRepository create() {
    try {
      return SupabaseTaskRepository(Supabase.instance.client);
    } catch (_) {}
    return InMemoryTaskRepository.seeded();
  }
}

class SupabaseTaskRepository implements TaskRepository {
  SupabaseTaskRepository(this._client);

  final SupabaseClient _client;

  @override
  Stream<List<Task>> watchAll() {
    return _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .order('due_at', ascending: true)
        .map((rows) => rows.map(Task.fromMap).toList());
  }

  @override
  Future<void> add(TaskDraft draft) async {
    await _client.from('tasks').insert(draft.toInsertMap());
  }

  @override
  Future<void> setCompleted({required String id, required bool completed}) async {
    await _client.from('tasks').update({'completed': completed}).eq('id', id);
  }

  @override
  Future<void> deleteById(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }
}

class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository({
    required List<Task> initial,
  }) : _tasks = List.of(initial) {
    _emit();
  }

  factory InMemoryTaskRepository.seeded() {
    final now = DateTime.now();
    final todayMorning = DateTime(now.year, now.month, now.day, 8);
    final todayMid = DateTime(now.year, now.month, now.day, 10);
    final todayLate = DateTime(now.year, now.month, now.day, 11);

    return InMemoryTaskRepository(
      initial: [
        Task(
          id: '1',
          title: 'Morning Workout',
          description: null,
          dueAt: todayMorning,
          completed: false,
          category: 'Healthy',
        ),
        Task(
          id: '2',
          title: 'Reading Book',
          description: null,
          dueAt: todayMid,
          completed: false,
          category: 'Education',
        ),
        Task(
          id: '3',
          title: 'Job Tasks',
          description: null,
          dueAt: todayLate,
          completed: false,
          category: 'Job',
        ),
        Task(
          id: '4',
          title: 'Eating Breakfast',
          description: null,
          dueAt: DateTime(now.year, now.month, now.day, 6),
          completed: true,
          category: 'Healthy',
        ),
      ],
    );
  }

  final StreamController<List<Task>> _controller = StreamController.broadcast();
  final List<Task> _tasks;

  void _emit() {
    _tasks.sort((a, b) {
      final ad = a.dueAt;
      final bd = b.dueAt;
      if (ad == null && bd == null) return a.title.compareTo(b.title);
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });
    _controller.add(List.unmodifiable(_tasks));
  }

  @override
  Stream<List<Task>> watchAll() => _controller.stream;

  @override
  Future<void> add(TaskDraft draft) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    _tasks.add(
      Task(
        id: id,
        title: draft.title,
        description: draft.description,
        dueAt: draft.dueAt,
        completed: false,
        category: draft.category,
      ),
    );
    _emit();
  }

  @override
  Future<void> setCompleted({required String id, required bool completed}) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx < 0) return;
    final t = _tasks[idx];
    _tasks[idx] = Task(
      id: t.id,
      title: t.title,
      description: t.description,
      dueAt: t.dueAt,
      completed: completed,
      category: t.category,
    );
    _emit();
  }

  @override
  Future<void> deleteById(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    _emit();
  }
}
