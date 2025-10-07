import 'dart:async';

class MockFirebaseService {
  static final List<Map<String, dynamic>> _mockMoods = [];
  static final List<Map<String, dynamic>> _mockJournal = [];
  static final List<Map<String, dynamic>> _mockTasks = [];

  // Mock mood methods
  static Future<void> saveMoodEntry(String mood, String notes) async {
    _mockMoods.add({
      'mood': mood,
      'notes': notes,
      'timestamp': DateTime.now(),
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  static Stream<List<Map<String, dynamic>>> getMoodHistory() {
    return Stream.fromIterable([_mockMoods]);
  }

  // Mock journal methods
  static Future<void> saveJournalEntry(String title, String content) async {
    _mockJournal.add({
      'title': title,
      'content': content,
      'timestamp': DateTime.now(),
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  static Stream<List<Map<String, dynamic>>> getJournalEntries() {
    return Stream.fromIterable([_mockJournal]);
  }

  // Mock task methods
  static Future<void> saveTask(String task, bool isCompleted) async {
    _mockTasks.add({
      'task': task,
      'isCompleted': isCompleted,
      'timestamp': DateTime.now(),
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  static Stream<List<Map<String, dynamic>>> getTasks() {
    return Stream.fromIterable([_mockTasks]);
  }

  static Future<void> saveTestResult(int score, Map<String, dynamic> answers) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Test result saved: $score');
  }
}