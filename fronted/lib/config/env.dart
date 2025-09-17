class Environment {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://oiaicqgbzjmgvlsmlaep.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9pYWljcWdiemptZ3Zsc21sYWVwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc0MDc5MzEsImV4cCI6MjA3Mjk4MzkzMX0.4b2304HQVsVwjvHsg7lwhnqTs6fi3jlqrfGGvLP-TH0',
  );

  static const String volcengineApiKey = String.fromEnvironment(
    'VOLCENGINE_API_KEY',
    defaultValue: 'YOUR_VOLCENGINE_API_KEY',
  );

  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:8080',
  );
}