import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/screens/home_screen.dart';
import 'src/task_repository.dart';
import 'src/ui_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const url1 = String.fromEnvironment('SUPABASE_URL');
  const url2 = String.fromEnvironment('SUPERBASE_URL');
  const key1 = String.fromEnvironment('SUPABASE_ANON_KEY');
  const key2 = String.fromEnvironment('SUPERBASE_ANON_KEY');

  final url = url1.isNotEmpty ? url1 : (url2.isNotEmpty ? url2 : null);
  final anonKey = key1.isNotEmpty ? key1 : (key2.isNotEmpty ? key2 : null);
  final initUrl = url;
  final initAnonKey = anonKey;
  final hasSupabase = initUrl != null && initAnonKey != null;

  if (initUrl != null && initAnonKey != null) {
    await Supabase.initialize(url: initUrl, anonKey: initAnonKey);
  }

  final repository = TaskRepository.create();
  final isOffline = repository is InMemoryTaskRepository;

  runApp(
    TuduApp(
      repository: repository,
      isOffline: isOffline || !hasSupabase,
    ),
  );
}

class TuduApp extends StatelessWidget {
  const TuduApp({
    super.key,
    required this.repository,
    required this.isOffline,
  });

  final TaskRepository repository;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tudu',
      theme: buildTuduTheme(),
      home: HomeScreen(repository: repository, isOffline: isOffline),
    );
  }
}
