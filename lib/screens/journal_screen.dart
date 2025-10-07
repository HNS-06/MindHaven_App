import 'package:flutter/material.dart';
import 'package:mindhaven/services/firebase_service.dart';
import 'package:mindhaven/services/reward_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isWriting = false;

  void _startWriting() {
    setState(() => _isWriting = true);
  }

  void _cancelWriting() {
    setState(() => _isWriting = false);
    _titleController.clear();
    _contentController.clear();
  }

  void _saveEntry() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add both title and content')),
      );
      return;
    }

    await FirebaseService.saveJournalEntry(title, content);
    await RewardService.addPoints(20);

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Journal entry saved! +20 points'),
        backgroundColor: Colors.green,
      ),
    );

    _cancelWriting();
    setState(() {}); // Refresh the journal list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          if (!_isWriting)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _startWriting,
            ),
        ],
      ),
      body: _isWriting ? _buildEditor() : _buildJournalList(),
    );
  }

  Widget _buildEditor() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Entry Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Write your thoughts...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelWriting,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Entry'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJournalList() {
    final entries = FirebaseService.getJournalEntries();

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.book,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No journal entries yet',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start writing to reflect on your thoughts',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startWriting,
              child: const Text('Write First Entry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              entry['title'] ?? 'Untitled',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              entry['content'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              _formatTimestamp(entry['timestamp']),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            onTap: () {
              _showEntryDetail(entry);
            },
          ),
        );
      },
    );
  }

  void _showEntryDetail(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['title'] ?? 'Untitled'),
        content: SingleChildScrollView(
          child: Text(data['content'] ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = timestamp as DateTime;
    return '${date.day}/${date.month}/${date.year}';
  }
}