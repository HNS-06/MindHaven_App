// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ========== TASK METHODS ==========
  static List<Map<String, dynamic>> loadTasks() {
    final tasksString = _prefs.getString('tasks');
    if (tasksString == null) return [];
    
    try {
      final List<dynamic> tasksList = json.decode(tasksString);
      return tasksList.map((task) {
        final map = Map<String, dynamic>.from(task);
        // Convert date strings back to DateTime
        if (map['createdAt'] != null && map['createdAt'] is String) {
          map['createdAt'] = DateTime.parse(map['createdAt']);
        }
        if (map['updatedAt'] != null && map['updatedAt'] is String) {
          map['updatedAt'] = DateTime.parse(map['updatedAt']);
        }
        return map;
      }).toList();
    } catch (e) {
      print('Error loading tasks: $e');
      return [];
    }
  }

  static Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    try {
      // Convert DateTime objects to ISO strings for JSON serialization
      final preparedTasks = tasks.map((task) {
        final preparedTask = Map<String, dynamic>.from(task);
        preparedTask.forEach((key, value) {
          if (value is DateTime) {
            preparedTask[key] = value.toIso8601String();
          }
        });
        return preparedTask;
      }).toList();
      
      final tasksString = json.encode(preparedTasks);
      await _prefs.setString('tasks', tasksString);
    } catch (e) {
      print('Error saving tasks: $e');
    }
  }

  // ========== TEST RESULT METHODS ==========
  static List<Map<String, dynamic>> loadTestResults() {
    final testsString = _prefs.getString('testResults');
    if (testsString == null) return [];
    
    try {
      final List<dynamic> testsList = json.decode(testsString);
      return testsList.map((test) {
        final map = Map<String, dynamic>.from(test);
        // Convert date string back to DateTime
        if (map['date'] != null && map['date'] is String) {
          map['date'] = DateTime.parse(map['date']);
        }
        return map;
      }).toList();
    } catch (e) {
      print('Error loading test results: $e');
      return [];
    }
  }

  static Future<void> saveTestResults(List<Map<String, dynamic>> testResults) async {
    try {
      // Convert DateTime objects to ISO strings for JSON serialization
      final preparedTests = testResults.map((test) {
        final preparedTest = Map<String, dynamic>.from(test);
        preparedTest.forEach((key, value) {
          if (value is DateTime) {
            preparedTest[key] = value.toIso8601String();
          }
        });
        return preparedTest;
      }).toList();
      
      final testsString = json.encode(preparedTests);
      await _prefs.setString('testResults', testsString);
    } catch (e) {
      print('Error saving test results: $e');
    }
  }

  // ========== MOOD ENTRY METHODS ==========
  static List<Map<String, dynamic>> loadMoodEntries() {
    final moodsString = _prefs.getString('moodEntries');
    if (moodsString == null) return [];
    
    try {
      final List<dynamic> moodsList = json.decode(moodsString);
      return moodsList.map((mood) {
        final map = Map<String, dynamic>.from(mood);
        // Convert timestamp string back to DateTime
        if (map['timestamp'] != null && map['timestamp'] is String) {
          map['timestamp'] = DateTime.parse(map['timestamp']);
        }
        return map;
      }).toList();
    } catch (e) {
      print('Error loading mood entries: $e');
      return [];
    }
  }

  static Future<void> saveMoodEntries(List<Map<String, dynamic>> moodEntries) async {
    try {
      // Convert DateTime objects to ISO strings for JSON serialization
      final preparedMoods = moodEntries.map((mood) {
        final preparedMood = Map<String, dynamic>.from(mood);
        preparedMood.forEach((key, value) {
          if (value is DateTime) {
            preparedMood[key] = value.toIso8601String();
          }
        });
        return preparedMood;
      }).toList();
      
      final moodsString = json.encode(preparedMoods);
      await _prefs.setString('moodEntries', moodsString);
    } catch (e) {
      print('Error saving mood entries: $e');
    }
  }

  // ========== JOURNAL ENTRY METHODS ==========
  static List<Map<String, dynamic>> loadJournalEntries() {
    final journalsString = _prefs.getString('journalEntries');
    if (journalsString == null) return [];
    
    try {
      final List<dynamic> journalsList = json.decode(journalsString);
      return journalsList.map((journal) {
        final map = Map<String, dynamic>.from(journal);
        // Convert timestamp string back to DateTime
        if (map['timestamp'] != null && map['timestamp'] is String) {
          map['timestamp'] = DateTime.parse(map['timestamp']);
        }
        return map;
      }).toList();
    } catch (e) {
      print('Error loading journal entries: $e');
      return [];
    }
  }

  static Future<void> saveJournalEntries(List<Map<String, dynamic>> journalEntries) async {
    try {
      // Convert DateTime objects to ISO strings for JSON serialization
      final preparedJournals = journalEntries.map((journal) {
        final preparedJournal = Map<String, dynamic>.from(journal);
        preparedJournal.forEach((key, value) {
          if (value is DateTime) {
            preparedJournal[key] = value.toIso8601String();
          }
        });
        return preparedJournal;
      }).toList();
      
      final journalsString = json.encode(preparedJournals);
      await _prefs.setString('journalEntries', journalsString);
    } catch (e) {
      print('Error saving journal entries: $e');
    }
  }

  // ========== APP USAGE TRACKING METHODS ==========
  static DateTime? loadLastAppOpen() {
    final lastOpenString = _prefs.getString('lastAppOpen');
    if (lastOpenString == null) return null;
    
    try {
      return DateTime.parse(lastOpenString);
    } catch (e) {
      print('Error loading last app open: $e');
      return null;
    }
  }

  static Future<void> saveLastAppOpen(DateTime dateTime) async {
    await _prefs.setString('lastAppOpen', dateTime.toIso8601String());
  }

  static int loadStreak() {
    return _prefs.getInt('userStreak') ?? 0;
  }

  static Future<void> saveStreak(int streak) async {
    await _prefs.setInt('userStreak', streak);
  }

  static DateTime? loadLastStreakUpdate() {
    final lastUpdateString = _prefs.getString('lastStreakUpdate');
    if (lastUpdateString == null) return null;
    
    try {
      return DateTime.parse(lastUpdateString);
    } catch (e) {
      print('Error loading last streak update: $e');
      return null;
    }
  }

  static Future<void> saveLastStreakUpdate(DateTime dateTime) async {
    await _prefs.setString('lastStreakUpdate', dateTime.toIso8601String());
  }

  // ========== UTILITY METHODS ==========
  static void clearAllData() {
    _prefs.remove('tasks');
    _prefs.remove('testResults');
    _prefs.remove('moodEntries');
    _prefs.remove('journalEntries');
    _prefs.remove('lastAppOpen');
    _prefs.remove('userStreak');
    _prefs.remove('lastStreakUpdate');
  }
}