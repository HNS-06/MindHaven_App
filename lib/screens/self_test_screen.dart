import 'package:flutter/material.dart';
import 'package:mindhaven/services/firebase_service.dart';
import 'package:mindhaven/services/reward_service.dart';

class SelfTestScreen extends StatefulWidget {
  const SelfTestScreen({super.key});

  @override
  State<SelfTestScreen> createState() => _SelfTestScreenState();
}

class _SelfTestScreenState extends State<SelfTestScreen> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Little interest or pleasure in doing things',
      'options': ['Not at all', 'Several Days', 'More Than Half Days', 'Nearly everyday'],
    },
    {
      'question': 'Feeling down, depressed, or hopeless',
      'options': ['Not at all', 'Several Days', 'More Than Half Days', 'Nearly everyday'],
    },
    {
      'question': 'Trouble falling or staying asleep, or sleeping too much',
      'options': ['Not at all', 'Several Days', 'More Than Half Days', 'Nearly everyday'],
    },
    {
      'question': 'Feeling tired or having little energy',
      'options': ['Not at all', 'Several Days', 'More Than Half Days', 'Nearly everyday'],
    },
    {
      'question': 'Poor appetite or overeating',
      'options': ['Not at all', 'Several Days', 'More Than Half Days', 'Nearly everyday'],
    },
  ];

  final List<int?> _answers = List.filled(5, null);
  bool _isSubmitted = false;
  int _totalScore = 0;

  void _submitTest() {
    if (_answers.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

    int score = 0;
    Map<String, dynamic> answers = {};

    for (int i = 0; i < _answers.length; i++) {
      final answer = _answers[i]!;
      score += answer;
      answers['question_${i + 1}'] = {
        'answer': _questions[i]['options'][answer],
        'score': answer,
      };
    }

    setState(() {
      _totalScore = score;
      _isSubmitted = true;
    });

    FirebaseService.saveTestResult(score, answers);
    RewardService.addPoints(25);
  }

  String _getResultMessage(int score) {
    if (score <= 5) return 'You\'re doing great! Keep up the positive mindset.';
    if (score <= 10) return 'You might be experiencing some challenges. Consider talking to someone.';
    return 'It might be helpful to speak with a mental health professional for support.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Self Assessment'),
      ),
      body: _isSubmitted
          ? _buildResults()
          : _buildTest(),
    );
  }

  Widget _buildTest() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    'Self Assessment',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Over the last 2 weeks, how often have you been bothered by any of the following problems?',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(_questions.length, (index) {
                    return _buildQuestion(index);
                  }),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitTest,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit Assessment',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}. ${_questions[index]['question']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(4, (optionIndex) {
            return RadioListTile<int>(
              title: Text(_questions[index]['options'][optionIndex]),
              value: optionIndex,
              groupValue: _answers[index],
              onChanged: (value) => setState(() => _answers[index] = value),
              contentPadding: EdgeInsets.zero,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(
                    Icons.psychology,
                    size: 64,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Assessment Complete',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Score: $_totalScore',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _getResultMessage(_totalScore),
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '+25 points earned!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => setState(() {
                        _isSubmitted = false;
                        _answers.fillRange(0, _answers.length, null);
                      }),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Take Again'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}