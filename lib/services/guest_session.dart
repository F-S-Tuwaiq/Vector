import '../data/mock_hackathons.dart';

class GuestSession {
  static bool _isActive = false;

  static bool get isActive => _isActive;

  static void start() {
    resetGuestMockData();
    _isActive = true;
  }

  static void end() {
    resetGuestMockData();
    _isActive = false;
  }
}
