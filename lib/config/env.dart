import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central place to read Supabase configuration from the already-loaded
/// `.env` file. `dotenv.load()` is called once in `main.dart` before
/// `runApp`, so this class only ever *reads* already-loaded values.
///
/// This app is a no-auth mock/demo: nothing here may throw on startup,
/// whether or not real credentials have been filled in yet.
class Env {
  const Env._();

  static const String _urlPlaceholder = 'PASTE_PROJECT_URL_HERE';
  static const String _anonKeyPlaceholder = 'PASTE_ANON_KEY_HERE';

  static String get supabaseUrl {
    try {
      return dotenv.env['SUPABASE_URL'] ?? '';
    } catch (_) {
      // dotenv not loaded yet (or failed to load) - treat as unset.
      return '';
    }
  }

  static String get supabaseAnonKey {
    try {
      return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    } catch (_) {
      return '';
    }
  }

  /// True only when both values are present and neither is still the
  /// literal placeholder shipped in `.env.example`.
  static bool get isConfigured {
    final url = supabaseUrl;
    final key = supabaseAnonKey;
    if (url.isEmpty || key.isEmpty) return false;
    if (url == _urlPlaceholder || key == _anonKeyPlaceholder) return false;
    return true;
  }
}
