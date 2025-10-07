import 'package:flutter/material.dart';
import 'package:mindhaven/services/firebase_service.dart';
import 'package:mindhaven/services/reward_service.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  String? _selectedMood;
  final TextEditingController _notesController = TextEditingController();
  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'label': 'Happy', 'color': Colors.green},
    {'emoji': '😌', 'label': 'Calm', 'color': Colors.blue},
    {'emoji': '😐', 'label': 'Neutral', 'color': Colors.grey},
    {'emoji': '😔', 'label': 'Sad', 'color': Colors.blueGrey},
    {'emoji': '😠', 'label': 'Angry', 'color': Colors.red},
  ];

  void _saveMood() async {
    if (_selectedMood == null) return;

    await FirebaseService.saveMoodEntry(_selectedMood!, _notesController.text);
    await RewardService.addPoints(10);

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mood saved! +10 points'),
        backgroundColor: Colors.green,
      ),
    );

    _notesController.clear();
    setState(() => _selectedMood = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Selection
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'How are you feeling today?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _moods.map((mood) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMood = mood['label']),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _selectedMood == mood['label']
                                      ? mood['color'].withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedMood == mood['label']
                                        ? mood['color']
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  mood['emoji'],
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(mood['label']),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Notes
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Share your thoughts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Write about your day, feelings, or anything on your mind...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedMood == null ? null : _saveMood,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Mood Entry',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Mood History
            const Text(
              'Recent Mood History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMoodHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodHistory() {
    final recentMoods = FirebaseService.getRecentMoods();
    
    if (recentMoods.isEmpty) {
      return const Center(
        child: Text(
          'No mood entries yet\nTrack your first mood to see history here!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return Column(
      children: recentMoods.take(5).map((mood) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Text(
            _getMoodEmoji(mood['mood']),
            style: const TextStyle(fontSize: 24),
          ),
          title: Text(mood['mood']),
          subtitle: Text(mood['notes']?.isNotEmpty == true ? mood['notes'] : 'No notes'),
          trailing: Text(
            _formatDate(mood['timestamp']),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      )).toList(),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Happy': return '😊';
      case 'Calm': return '😌';
      case 'Neutral': return '😐';
      case 'Sad': return '😔';
      case 'Angry': return '😠';
      default: return '😐';
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = timestamp as DateTime;
    return '${date.day}/${date.month}/${date.year}';
  }
}