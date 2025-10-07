// Simple in-memory trial manager for demo
class TrialManager {
  static DateTime? _trialStart;
  static const int _trialDays = 3;

  static Future<void> startTrial() async {
    _trialStart = DateTime.now();
  }

  static Future<bool> isTrialActive() async {
    if (_trialStart == null) {
      await startTrial();
      return true;
    }
    
    final now = DateTime.now();
    final difference = now.difference(_trialStart!).inDays;
    
    return difference <= _trialDays;
  }

  static Future<int> getRemainingTrialDays() async {
    if (_trialStart == null) {
      await startTrial();
      return _trialDays;
    }
    
    final now = DateTime.now();
    final difference = _trialDays - now.difference(_trialStart!).inDays;
    
    return difference > 0 ? difference : 0;
  }
}