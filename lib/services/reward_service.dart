// Simple in-memory reward service for demo - no dependencies needed
class RewardService {
  static int _points = 0;
  static int _streak = 0;
  static String _lastActivityDate = '';

  static Future<int> getPoints() async {
    return _points;
  }

  static Future<void> addPoints(int points) async {
    _points += points;
    await _updateStreak();
    print('Added $points points. Total: $_points'); // For debugging
  }

  static Future<int> getStreak() async {
    return _streak;
  }

  static Future<void> _updateStreak() async {
    final today = _getTodayString();
    
    if (_lastActivityDate == today) return;
    
    final yesterday = _getYesterdayString();
    
    if (_lastActivityDate == yesterday) {
      _streak += 1;
    } else if (_lastActivityDate != today) {
      _streak = 1;
    }
    
    _lastActivityDate = today;
    print('Streak updated: $_streak days'); // For debugging
  }

  static String _getTodayString() {
    return DateTime.now().toString().split(' ')[0];
  }

  static String _getYesterdayString() {
    return DateTime.now().subtract(const Duration(days: 1)).toString().split(' ')[0];
  }

  static Future<Map<String, dynamic>> getUserStats() async {
    final points = await getPoints();
    final streak = await getStreak();
    
    return {
      'points': points,
      'streak': streak,
      'level': (points ~/ 100) + 1,
    };
  }

  // Reset for testing (optional)
  static void reset() {
    _points = 0;
    _streak = 0;
    _lastActivityDate = '';
  }
}