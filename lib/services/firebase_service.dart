// lib/services/firebase_service.dart
import 'storage_service.dart';

class FirebaseService {
  // Mock storage for all data types
  static List<Map<String, dynamic>> tasks = [];
  static List<Map<String, dynamic>> testResults = [];
  static List<Map<String, dynamic>> moodEntries = [];
  static List<Map<String, dynamic>> journalEntries = [];
  
  // ID counters
  static int _nextTaskId = 1;
  static int _nextTestId = 1;
  static int _nextMoodId = 1;
  static int _nextJournalId = 1;

  // App usage tracking - ADD THESE FIELDS
  static DateTime? _lastAppOpen;
  static int _userStreak = 0;
  static DateTime? _lastStreakUpdate;

  // Initialize with persisted data
  static Future<void> init() async {
    await StorageService.init();
    
    // Load persisted data
    tasks = StorageService.loadTasks();
    testResults = StorageService.loadTestResults();
    moodEntries = StorageService.loadMoodEntries();
    journalEntries = StorageService.loadJournalEntries();
    
    // Load app usage data
    _lastAppOpen = StorageService.loadLastAppOpen();
    _userStreak = StorageService.loadStreak();
    _lastStreakUpdate = StorageService.loadLastStreakUpdate();
    
    // Update ID counters based on loaded data
    _updateIdCounters();
    
    _log('📊 Loaded persisted data:');
    _log('   - Tasks: ${tasks.length}');
    _log('   - Mood entries: ${moodEntries.length}');
    _log('   - Journal entries: ${journalEntries.length}');
    _log('   - Test results: ${testResults.length}');
    _log('   - User streak: $_userStreak days');
  }

  // Safe logging method
  static void _log(String message) {
    print(message);
  }

  // Update ID counters based on existing data
  static void _updateIdCounters() {
    if (tasks.isNotEmpty) {
      final maxTaskId = tasks.map((task) {
        final id = task['id'] as String;
        final idNum = int.tryParse(id.replaceAll('task_', '')) ?? 0;
        return idNum;
      }).reduce((a, b) => a > b ? a : b);
      _nextTaskId = maxTaskId + 1;
    }

    if (testResults.isNotEmpty) {
      final maxTestId = testResults.map((test) {
        final id = test['id'] as String;
        final idNum = int.tryParse(id.replaceAll('test_', '')) ?? 0;
        return idNum;
      }).reduce((a, b) => a > b ? a : b);
      _nextTestId = maxTestId + 1;
    }

    if (moodEntries.isNotEmpty) {
      final maxMoodId = moodEntries.map((mood) {
        final id = mood['id'] as String;
        final idNum = int.tryParse(id.replaceAll('mood_', '')) ?? 0;
        return idNum;
      }).reduce((a, b) => a > b ? a : b);
      _nextMoodId = maxMoodId + 1;
    }

    if (journalEntries.isNotEmpty) {
      final maxJournalId = journalEntries.map((journal) {
        final id = journal['id'] as String;
        final idNum = int.tryParse(id.replaceAll('journal_', '')) ?? 0;
        return idNum;
      }).reduce((a, b) => a > b ? a : b);
      _nextJournalId = maxJournalId + 1;
    }
  }

  // ========== TASK METHODS ==========
  static Future<void> saveTask(String task, bool completed) async {
    final newTask = {
      'id': 'task_${_nextTaskId++}',
      'task': task,
      'isCompleted': completed,
      'createdAt': DateTime.now(),
    };
    tasks.add(newTask);
    await StorageService.saveTasks(tasks);
    
    await Future.delayed(const Duration(milliseconds: 200));
  }

  static Future<void> deleteTask(String taskId) async {
    tasks.removeWhere((task) => task['id'] == taskId);
    await StorageService.saveTasks(tasks);
    await Future.delayed(const Duration(milliseconds: 200));
  }

  static Future<void> updateTaskCompletion(String taskId, bool completed) async {
    final taskIndex = tasks.indexWhere((task) => task['id'] == taskId);
    if (taskIndex != -1) {
      final wasCompleted = tasks[taskIndex]['isCompleted'] ?? false;
      tasks[taskIndex]['isCompleted'] = completed;
      tasks[taskIndex]['updatedAt'] = DateTime.now();
      await StorageService.saveTasks(tasks);
      
      // If task was just completed, check for achievements
      if (completed && !wasCompleted) {
        await _checkTaskCompletionAchievements();
      }
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }

  static Future<void> _checkTaskCompletionAchievements() async {
    final completedTasks = tasks.where((task) => task['isCompleted'] == true).length;
    
    // Achievement notifications removed for now
    if (completedTasks == 1) {
      _log('🎯 Achievement: First Task Complete!');
    } else if (completedTasks == 5) {
      _log('🌟 Achievement: Task Master! Completed 5 tasks');
    } else if (completedTasks == 10) {
      _log('🏆 Achievement: Productivity Pro! 10 tasks done');
    }
  }

  // ========== APP USAGE TRACKING ==========
  static Future<void> trackAppOpen() async {
    final now = DateTime.now();
    
    // Update streak
    _updateStreak(now);
    
    _lastAppOpen = now;
    await StorageService.saveLastAppOpen(now);
  }

  static void _updateStreak(DateTime currentTime) {
    if (_lastStreakUpdate == null) {
      // First time using the app
      _userStreak = 1;
    } else {
      final daysSinceLastUpdate = currentTime.difference(_lastStreakUpdate!).inDays;
      
      if (daysSinceLastUpdate == 1) {
        // User opened app consecutive days - increase streak
        _userStreak++;
      } else if (daysSinceLastUpdate > 1) {
        // User missed days - reset streak
        _userStreak = 1;
      }
      // If daysSinceLastUpdate == 0, same day - don't change streak
    }
    
    _lastStreakUpdate = currentTime;
    StorageService.saveStreak(_userStreak);
    StorageService.saveLastStreakUpdate(currentTime);
    
    _log('🔥 Current streak: $_userStreak days');
  }

  static int getCurrentStreak() {
    return _userStreak;
  }

  static int getIncompleteTasksCount() {
    return tasks.where((task) => task['isCompleted'] != true).length;
  }

  // Check for incomplete tasks (call this daily)
  static Future<void> checkDailyTaskReminders() async {
    final incompleteTasks = getIncompleteTasksCount();
    if (incompleteTasks > 0) {
      _log('📝 Reminder: You have $incompleteTasks incomplete tasks');
    }
  }

  // ========== TEST METHODS ==========
  static Future<void> saveTestResult(int score, Map<String, dynamic> answers) async {
    final testResult = {
      'id': 'test_${_nextTestId++}',
      'score': score,
      'answers': answers,
      'date': DateTime.now(),
      'resultMessage': _getTestResultMessage(score),
    };
    
    testResults.add(testResult);
    await StorageService.saveTestResults(testResults);
    await Future.delayed(const Duration(milliseconds: 200));
    _log('Test result saved: Score $score');
  }

  static List<Map<String, dynamic>> getTestHistory() {
    testResults.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return List.from(testResults);
  }

  static Map<String, dynamic>? getLatestTestResult() {
    if (testResults.isEmpty) return null;
    testResults.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return testResults.first;
  }

  static String _getTestResultMessage(int score) {
    if (score <= 5) return 'You\'re doing great! Keep up the positive mindset.';
    if (score <= 10) return 'You might be experiencing some challenges. Consider talking to someone.';
    return 'It might be helpful to speak with a mental health professional for support.';
  }

  // ========== MOOD METHODS ==========
  static Future<void> saveMoodEntry(String mood, String notes) async {
    final moodEntry = {
      'id': 'mood_${_nextMoodId++}',
      'mood': mood,
      'notes': notes,
      'timestamp': DateTime.now(),
    };
    
    moodEntries.add(moodEntry);
    await StorageService.saveMoodEntries(moodEntries);
    await Future.delayed(const Duration(milliseconds: 200));
    _log('Mood entry saved: $mood');
  }

  static List<Map<String, dynamic>> getRecentMoods() {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    return moodEntries.where((entry) {
      final timestamp = entry['timestamp'] as DateTime;
      return timestamp.isAfter(oneWeekAgo);
    }).toList()
      ..sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
  }

  static Map<String, int> getMoodStats() {
    final stats = <String, int>{};
    for (final entry in moodEntries) {
      final mood = entry['mood'] as String;
      stats[mood] = (stats[mood] ?? 0) + 1;
    }
    return stats;
  }

  // ========== JOURNAL METHODS ==========
  static Future<void> saveJournalEntry(String title, String content) async {
    final journalEntry = {
      'id': 'journal_${_nextJournalId++}',
      'title': title,
      'content': content,
      'timestamp': DateTime.now(),
    };
    
    journalEntries.add(journalEntry);
    await StorageService.saveJournalEntries(journalEntries);
    await Future.delayed(const Duration(milliseconds: 200));
    _log('Journal entry saved: $title');
  }

  static List<Map<String, dynamic>> getJournalEntries() {
    journalEntries.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    return List.from(journalEntries);
  }

  static Future<void> deleteJournalEntry(String entryId) async {
    journalEntries.removeWhere((entry) => entry['id'] == entryId);
    await StorageService.saveJournalEntries(journalEntries);
    await Future.delayed(const Duration(milliseconds: 200));
  }

  static Map<String, dynamic>? getJournalEntry(String entryId) {
    try {
      return journalEntries.firstWhere((entry) => entry['id'] == entryId);
    } catch (e) {
      return null;
    }
  }

  // ========== DATA MANAGEMENT ==========
  static Future<void> clearAllData() async {
    tasks.clear();
    testResults.clear();
    moodEntries.clear();
    journalEntries.clear();
    _nextTaskId = 1;
    _nextTestId = 1;
    _nextMoodId = 1;
    _nextJournalId = 1;
    _userStreak = 0;
    _lastAppOpen = null;
    _lastStreakUpdate = null;
    
    // Clear persisted data
    StorageService.clearAllData();
  }

  // ========== DEBUG/UTILITY METHODS ==========
  static void printAllData() {
    _log('=== TASKS (${tasks.length}) ===');
    for (final task in tasks) {
      _log('${task['id']}: ${task['task']} - ${task['isCompleted']}');
    }
    
    _log('=== TESTS (${testResults.length}) ===');
    for (final test in testResults) {
      _log('${test['id']}: Score ${test['score']}');
    }
    
    _log('=== MOODS (${moodEntries.length}) ===');
    for (final mood in moodEntries) {
      _log('${mood['id']}: ${mood['mood']} - ${mood['notes']}');
    }
    
    _log('=== JOURNAL ENTRIES (${journalEntries.length}) ===');
    for (final entry in journalEntries) {
      _log('${entry['id']}: ${entry['title']}');
    }
    
    _log('=== USER STATS ===');
    _log('   - Streak: $_userStreak days');
    _log('   - Incomplete tasks: ${getIncompleteTasksCount()}');
  }
}