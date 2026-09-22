import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  const Env._();

  static const String _urlPlaceholder = 'PASTE_PROJECT_URL_HERE';
  static const String _anonKeyPlaceholder = 'PASTE_ANON_KEY_HERE';

  static String get supabaseUrl {
    try {
      return dotenv.env['SUPABASE_URL'] ?? '';
    } catch (_) {
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

  static bool get isConfigured {
    final url = supabaseUrl;
    final key = supabaseAnonKey;
    if (url.isEmpty || key.isEmpty) return false;
    if (url == _urlPlaceholder || key == _anonKeyPlaceholder) return false;
    return true;
  }
}
