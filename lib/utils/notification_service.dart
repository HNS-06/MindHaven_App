// Mock notification service for demo - no dependencies needed
class NotificationService {
  
  static Future<void> initialize() async {
    print('Notification service initialized (mock)');
    // Mock initialization - no actual notifications for demo
  }

  static Future<void> scheduleDailyNotifications() async {
    print('Daily notifications scheduled (mock)');
    // Mock scheduling - in a real app, this would set up actual notifications
    // For demo purposes, we'll just print to console
    
    print('📱 Mock: Scheduled morning mood check');
    print('📱 Mock: Scheduled daily motivation quote');
  }

  static Future<void> cancelAll() async {
    print('All notifications cancelled (mock)');
    // Mock cancellation
  }

  // Mock method to show how notifications would work
  static void showMockNotification(String title, String body) {
    print('🔔 MOCK NOTIFICATION:');
    print('Title: $title');
    print('Body: $body');
    print('---');
  }

  // Method to simulate receiving a notification
  static void simulateMorningNotification() {
    showMockNotification(
      'MindHaven',
      'How are you feeling today? Take a moment to check in.',
    );
  }

  // Method to simulate motivational quote
  static void simulateMotivationNotification() {
    showMockNotification(
      'Daily Inspiration',
      'Your struggles do not define you. Keep going!',
    );
  }
}