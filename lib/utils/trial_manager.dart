import 'package:shared_preferences/shared_preferences.dart';

class TrialManager {
  static const int _trialDays = 3;

  static Future<void> startTrial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trialStartDate', DateTime.now().toIso8601String());
    await prefs.setBool('hasCompletedOnboarding', true); // Also mark onboarding as complete
  }

  static Future<bool> isTrialActive() async {
    final prefs = await SharedPreferences.getInstance();
    final startDate = prefs.getString('trialStartDate');
    
    if (startDate == null) {
      // First time - start trial automatically
      await startTrial();
      return true;
    }
    
    final start = DateTime.parse(startDate);
    final now = DateTime.now();
    final difference = now.difference(start).inDays;
    
    return difference <= _trialDays;
  }

  static Future<int> getRemainingTrialDays() async {
    final prefs = await SharedPreferences.getInstance();
    final startDate = prefs.getString('trialStartDate');
    
    if (startDate == null) {
      await startTrial();
      return _trialDays;
    }
    
    final start = DateTime.parse(startDate);
    final now = DateTime.now();
    final difference = _trialDays - now.difference(start).inDays;
    
    return difference > 0 ? difference : 0;
  }

  // Helper method to manually mark onboarding as complete
  static Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
  }

  // Check if onboarding is completed
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasCompletedOnboarding') ?? false;
  }
}