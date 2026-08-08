import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed access to the `.env` file (per-environment config: API base URL,
/// etc.). Never commit real secrets here — `.env` is gitignored; ship an
/// `.env.example` with placeholder values instead.
abstract final class Env {
  static Future<void> load() => dotenv.load(fileName: '.env');

  static String get apiBaseUrl =>
      dotenv.get('API_BASE_URL', fallback: 'http://10.0.2.2:8000/api/v1');

  /// OAuth "Web application" client ID from Google Cloud Console — required
  /// by `google_sign_in` on Android to obtain an ID token, and used as
  /// `serverClientId` in `GoogleSignIn.initialize()`. Empty until a real
  /// Google Cloud project is wired up; Google Sign-In will fail gracefully
  /// (caught and mapped to a friendly error) until then.
  static String get googleServerClientId => dotenv.get('GOOGLE_SERVER_CLIENT_ID', fallback: '');

  /// Admin support number for manual-payment proof-of-payment messages, in
  /// international format with no leading `+` (`wa.me`'s expected format).
  /// The backend has no equivalent config — this is a client-side-only
  /// contact point, set per deployment.
  static String get supportWhatsappNumber => dotenv.get('SUPPORT_WHATSAPP_NUMBER', fallback: '2340000000000');
}
