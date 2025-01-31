import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// Initialize in main.dart
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://xdplrdnwjkkfhbhykopo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhkcGxyZG53amtrZmhiaHlrb3BvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc1MzAxNDcsImV4cCI6MjA1MzEwNjE0N30.lSaiKtnJQaRPeyj1WXqMtU8bMqnKMGICrMvj044kEzM',
  );
} 