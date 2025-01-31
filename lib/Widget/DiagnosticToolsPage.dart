/*import 'package:flutter/material.dart';
class DiagnosticToolsPage extends StatelessWidget {
  const DiagnosticToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostic Tools')),
      body: Container(
        color: const Color(0xFFE4E4EC),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/lamah_logo.png',
                height: 120,
              ),
              const SizedBox(height: 40),
              _buildToolButton(
                context,
                icon: Icons.assignment,
                label: 'Start Questionnaire',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuestionnairePage(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildToolButton(
                context,
                icon: Icons.remove_red_eye,
                label: 'Start AI Analysis',
                onPressed: () {
                  // Add AI analysis functionality here
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E225A),
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final List<String> questions = [
    "Does your child avoid eye contact with others?",
    "Does your child prefer to play alone?",
    "Does your child have difficulty understanding feelings?",
    "Does your child repeat words/phrases excessively?",
    "Does your child have intense special interests?",
    "Does your child struggle with routine changes?",
    "Does your child have difficulty making friends?",
    "Does your child make repetitive movements?",
    "Is your child hypersensitive to stimuli?",
    "Does your child have language delays?",
  ];

  int currentQuestionIndex = 0;
  int? selectedOption;
  int totalScore = 0;

  void nextQuestion() {
    if (selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option')),
      );
      return;
    }

    setState(() {
      totalScore += selectedOption!;
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        selectedOption = null;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ThankYouPage(score: totalScore),
          ),
        );
      }
    });
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        selectedOption = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questionnaire'),
        leading: currentQuestionIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: previousQuestion,
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              backgroundColor: const Color(0xFFE4E4EC),
              color: const Color(0xFF2E225A),
            ),
            const SizedBox(height: 20),
            Text(
              'Question ${currentQuestionIndex + 1} of ${questions.length}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E225A),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        questions[currentQuestionIndex],
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.separated(
                          itemCount: 5,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return RadioListTile<int>(
                              title: Text(
                                ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'][index],
                              ),
                              value: index + 1,
                              groupValue: selectedOption,
                              onChanged: (value) => setState(() => selectedOption = value),
                              activeColor: const Color(0xFF2E225A),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E225A),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  currentQuestionIndex < questions.length - 1 ? 'Next' : 'Submit',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThankYouPage extends StatelessWidget {
  final int score;

  const ThankYouPage({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Assessment Complete',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E225A),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Score: $score/50',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuestionnairePage(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E225A),
                ),
                child: const Text('Restart Assessment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// File: DiagnosticToolsPage.dart
// File: DiagnosticToolsPage.dart
*/

//deepseek
/*
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';

class DiagnosticToolsPage extends StatefulWidget {
  @override
  _DiagnosticToolsPageState createState() => _DiagnosticToolsPageState();
}

class _DiagnosticToolsPageState extends State<DiagnosticToolsPage> {
  final List<String> _answerOptions = const [
    'Never',
    'Rarely',
    'Sometimes',
    'Often',
    'Always'
  ];
  final Map<int, int?> _answers = {};
  int _currentQuestionIndex = 0;
  List<dynamic> questions = [];
  String? sessionId;
  bool isLoading = true;
  final Uuid _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _initializeSession();
    _fetchQuestions();
  }

  Future<void> _initializeSession() async {
    sessionId = _uuid.v4();
    await supabase.from('sessions').insert({
      'session_id': sessionId!,
      'user_id': supabase.auth.currentUser?.id,
      'type': 'questionnaire',
      'total_score': 0.0,
    });
  }

  Future<void> _fetchQuestions() async {
    try {
      final response = await supabase
          .from('questions')
          .select()
          .order('question_id', ascending: true);

      setState(() {
        questions = response;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching questions: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  void _handleAnswer(int answerIndex) {
    setState(() {
      _answers[_currentQuestionIndex] = answerIndex;
    });
    _autoNavigate();
  }

  void _autoNavigate() {
    if (_currentQuestionIndex < questions.length - 1) {
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() => _currentQuestionIndex++);
      });
    }
  }

  double _calculateTotalScore() {
    return _answers.values
        .fold(0.0, (sum, answer) => sum + (answer?.toDouble() ?? 0));
  }

  Future<void> _submitQuestionnaire() async {
    final totalScore = _calculateTotalScore();
    
    try {
      // Save individual responses
      for (int i = 0; i < questions.length; i++) {
        await supabase.from('questionnaire_responses').insert({
          'response_id': _uuid.v4(),
          'user_id': supabase.auth.currentUser?.id,
          'question_id': questions[i]['question_id'],
          'answer': _answers[i]?.toDouble(),
          'session_id': sessionId!,
        });
      }

      // Update session with total score
      await supabase
          .from('sessions')
          .update({'total_score': totalScore})
          .eq('session_id', sessionId!);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Questionnaire submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = questions[_currentQuestionIndex];
    final hasAnswer = _answers.containsKey(_currentQuestionIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentQuestionIndex + 1}/${questions.length}'),
        actions: [
          if (_currentQuestionIndex == questions.length - 1)
            TextButton(
              onPressed: _submitQuestionnaire,
              child: const Text('Submit',
                  style: TextStyle(color: Colors.white)),
            )
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / questions.length,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    currentQuestion['question_text'],
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ..._answerOptions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _answers[_currentQuestionIndex] == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey[200],
                          foregroundColor: _answers[_currentQuestionIndex] == index
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: () => _handleAnswer(index),
                        child: Text(option),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () => setState(() => _currentQuestionIndex--),
                    child: const Text('Previous'),
                  ),
                if (_currentQuestionIndex < questions.length - 1)
                  ElevatedButton(
                    onPressed: hasAnswer
                        ? () => setState(() => _currentQuestionIndex++)
                        : null,
                    child: const Text('Next'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/
// File: DiagnosticToolsPage.dart




// WORKING SAVING ANSWERS
/*
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart'; // Ensure this imports the initialized Supabase client
// Ensure this imports the initialized Supabase client
import '../pages/ai_analysis_page.dart'; // Import the AI Analysis Page

enum DiagnosticMode { menu, questionnaire, aiAnalysis }

class DiagnosticToolsPage extends StatefulWidget {
  const DiagnosticToolsPage({Key? key}) : super(key: key);

  @override
  _DiagnosticToolsPageState createState() => _DiagnosticToolsPageState();
}

class _DiagnosticToolsPageState extends State<DiagnosticToolsPage> {
  // Enumeration to manage different modes
  DiagnosticMode currentMode = DiagnosticMode.menu;

  // Questionnaire-related variables
  final List<String> _answerOptions = const [
    'Never',
    'Rarely',
    'Sometimes',
    'Often',
    'Always'
  ];
  final Map<int, int?> _answers = {};
  int _currentQuestionIndex = 0;
  List<dynamic> questions = [];
  String? sessionId;
  bool isLoading = false;
  final Uuid _uuid = const Uuid();

  @override
  void dispose() {
    super.dispose();
  }

  // Method to initialize the questionnaire session
  Future<void> _initializeSession() async {
    setState(() {
      isLoading = true;
    });

    try {
      sessionId = _uuid.v4();
      await supabase.from('sessions').insert({
        'session_id': sessionId!,
        'user_id': supabase.auth.currentUser?.id,
        'type': 'questionnaire',
        'total_score': 0.0,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      setState(() {
        currentMode = DiagnosticMode.questionnaire;
      });

      _fetchQuestions();
    } catch (e) {
      _handleError('Session Initialization Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to fetch questionnaire questions from Supabase
  Future<void> _fetchQuestions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase
          .from('questions')
          .select()
          .order('question_id', ascending: true);

      setState(() {
        questions = response;
        isLoading = false;
      });
    } catch (e) {
      _handleError('Error fetching questions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to handle user's answer selection
  void _handleAnswer(int answerIndex) {
    setState(() {
      _answers[_currentQuestionIndex] = answerIndex;
    });
    _autoNavigate();
  }

  // Method to auto-navigate to the next question
  void _autoNavigate() {
    if (_currentQuestionIndex < questions.length - 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _currentQuestionIndex++;
        });
      });
    }
  }

  // Method to calculate the total score based on answers
  double _calculateTotalScore() {
    return _answers.values.fold(0.0, (sum, answer) => sum + ((answer ?? 0)));
  }

  // Method to submit the questionnaire responses to Supabase
  Future<void> _submitQuestionnaire() async {
    setState(() {
      isLoading = true;
    });

    final totalScore = _calculateTotalScore();

    try {
      // Save individual responses
      for (int i = 0; i < questions.length; i++) {
        await supabase.from('questionnaire_responses').insert({
          'response_id': _uuid.v4(),
          'user_id': supabase.auth.currentUser?.id,
          'question_id': questions[i]['question_id'],
          'answer': _answers[i]?.toDouble(),
          'session_id': sessionId!,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      }

      // Update session with total score
      await supabase.from('sessions').update({'total_score': totalScore}).eq('session_id', sessionId!);

      // Reset state and navigate back to menu
      setState(() {
        currentMode = DiagnosticMode.menu;
        _answers.clear();
        _currentQuestionIndex = 0;
        questions.clear();
        sessionId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Questionnaire submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _handleError('Submission failed: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to handle and display errors
  void _handleError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Widget to build the initial menu with two buttons
  Widget _buildInitialMenu() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : _initializeSession,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF2E225A),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      'Start Questionnaire',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Placeholder for AI Analysis functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('AI Analysis feature is under development.'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.grey,
              ),
              child: const Text(
                'Start AI Analysis',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build the questionnaire form
  Widget _buildQuestionnaireForm() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentQuestionIndex >= questions.length) {
      // This state should be handled by the 'Submit' button
      return const SizedBox.shrink();
    }

    final currentQuestion = questions[_currentQuestionIndex];
    final hasAnswered = _answers.containsKey(_currentQuestionIndex);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Progress Indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / questions.length,
            backgroundColor: Colors.grey[300],
            color: const Color(0xFF2E225A),
            minHeight: 8,
          ),
          const SizedBox(height: 20),
          // Current Question Text
          Expanded(
            child: Center(
              child: Text(
                currentQuestion['question_text'],
                style: const TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Answer Options
          Column(
            children: _answerOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = _answers[_currentQuestionIndex] == index;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => _handleAnswer(index),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor:
                        isSelected ? const Color(0xFF2E225A) : Colors.grey[200],
                    foregroundColor:
                        isSelected ? Colors.white : Colors.black,
                  ),
                  child: Text(option),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Button
              if (_currentQuestionIndex > 0)
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            _currentQuestionIndex--;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 50),
                    backgroundColor: const Color(0xFF2E225A),
                  ),
                  child: const Text('Previous'),
                ),
              // Next or Submit Button
              if (_currentQuestionIndex < questions.length - 1)
                ElevatedButton(
                  onPressed: hasAnswered
                      ? () {
                          setState(() {
                            _currentQuestionIndex++;
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 50),
                    backgroundColor: hasAnswered
                        ? const Color(0xFF2E225A)
                        : Colors.grey,
                  ),
                  child: const Text('Next'),
                )
              else
                ElevatedButton(
                  onPressed: hasAnswered && !isLoading
                      ? _submitQuestionnaire
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 50),
                    backgroundColor: hasAnswered
                        ? const Color(0xFF2E225A)
                        : Colors.grey,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Submit'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    switch (currentMode) {
      case DiagnosticMode.menu:
        bodyContent = _buildInitialMenu();
        break;
      case DiagnosticMode.questionnaire:
        bodyContent = _buildQuestionnaireForm();
        break;
      case DiagnosticMode.aiAnalysis:
        // Placeholder for AI Analysis functionality
        bodyContent = Center(
          child: Text(
            'AI Analysis feature is under development.',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic Tools'),
        backgroundColor: const Color(0xFF2E225A),
      ),
      body: bodyContent,
    );
  }
}
*/
// File: lib/pages/diagnostic_tools_page.dart
// File: lib/pages/diagnostic_tools_page.dart
// File: lib/pages/diagnostic_tools_page.dart
// File: lib/pages/diagnostic_tools_page.dart
// File: lib/pages/diagnostic_tools_page.dart



// latest working beofre coloring buttons
// 
// File: lib/pages/diagnostic_tools_page.dart
// File: lib/pages/diagnostic_tools_page.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart'; // Ensure this imports the initialized Supabase client
import '../pages/ai_analysis_page.dart'; // Import the AI Analysis Page

enum DiagnosticMode { menu, questionnaire, aiAnalysis }

class DiagnosticToolsPage extends StatefulWidget {
  const DiagnosticToolsPage({Key? key}) : super(key: key);

  @override
  _DiagnosticToolsPageState createState() => _DiagnosticToolsPageState();
}

class _DiagnosticToolsPageState extends State<DiagnosticToolsPage> {
  // Enumeration to manage different modes
  DiagnosticMode currentMode = DiagnosticMode.menu;

  // Questionnaire-related variables
  final List<String> _answerOptions = const [
    'Never',
    'Rarely',
    'Sometimes',
    'Often',
    'Always'
  ];
  final Map<int, int?> _answers = {};
  int _currentQuestionIndex = 0;
  List<dynamic> questions = [];
  String? sessionId;
  bool isLoading = false;
  final Uuid _uuid = const Uuid();

  @override
  void dispose() {
    super.dispose();
  }

  // Method to initialize the questionnaire session
  Future<void> _initializeSession() async {
    setState(() {
      isLoading = true;
    });

    try {
      sessionId = _uuid.v4();
      await supabase.from('sessions').insert({
        'session_id': sessionId!,
        'user_id': supabase.auth.currentUser?.id,
        'type': 'questionnaire',
        'total_score': 0.0,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      setState(() {
        currentMode = DiagnosticMode.questionnaire;
      });

      await _fetchQuestions();
    } catch (e) {
      _handleError('Session Initialization Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to fetch questionnaire questions from Supabase
  Future<void> _fetchQuestions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase
          .from('questions')
          .select()
          .order('question_id', ascending: true);

      setState(() {
        questions = response;
        isLoading = false;
      });
    } catch (e) {
      _handleError('Error fetching questions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to handle user's answer selection
  void _handleAnswer(int answerIndex) {
    setState(() {
      // **CHANGED**: Store answerIndex + 1 to shift from 0-4 to 1-5
      _answers[_currentQuestionIndex] = answerIndex + 1;
    });
    _autoNavigate();
  }

  // Method to auto-navigate to the next question
  void _autoNavigate() {
    if (_currentQuestionIndex < questions.length - 1) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _currentQuestionIndex++;
        });
      });
    }
  }

  // Method to calculate the total score based on answers
  double _calculateTotalScore() {
    return _answers.values.fold(0.0, (sum, answer) => sum + ((answer ?? 0)));
  }

  // Method to submit the questionnaire responses to Supabase
  Future<void> _submitQuestionnaire() async {
    setState(() {
      isLoading = true;
    });

    final totalScore = _calculateTotalScore();

    try {
      // Save individual responses
      for (int i = 0; i < questions.length; i++) {
        await supabase.from('questionnaire_responses').insert({
          'response_id': _uuid.v4(),
          'user_id': supabase.auth.currentUser?.id,
          'question_id': questions[i]['question_id'],
          // **CHANGED**: Ensure that the stored answer is now between 1 and 5
          'answer': _answers[i]?.toDouble(),
          'session_id': sessionId!,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      }

      // Update session with total score
      await supabase
          .from('sessions')
          .update({'total_score': totalScore})
          .eq('session_id', sessionId!);

      // Reset state and navigate back to menu
      setState(() {
        currentMode = DiagnosticMode.menu;
        _answers.clear();
        _currentQuestionIndex = 0;
        questions.clear();
        sessionId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Questionnaire submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _handleError('Submission failed: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to handle and display errors
  void _handleError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Widget to build the initial menu with two buttons
  Widget _buildInitialMenu() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : _initializeSession,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF2E225A),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      'Start Questionnaire',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AIAnalysisPage()),
                      );
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF2E225A),
              ),
              child: const Text(
                'Start AI Analysis',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build the questionnaire form
  Widget _buildQuestionnaireForm() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentQuestionIndex >= questions.length) {
      // This state should be handled by the 'Submit' button
      return const SizedBox.shrink();
    }

    final currentQuestion = questions[_currentQuestionIndex];
    final hasAnswered = _answers.containsKey(_currentQuestionIndex);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Progress Indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / questions.length,
            backgroundColor: Colors.grey[300],
            color: const Color(0xFF2E225A),
            minHeight: 8,
          ),
          const SizedBox(height: 20),
          // Current Question Text
          Expanded(
            child: Center(
              child: Text(
                currentQuestion['question_text'],
                style: const TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Answer Options
          Column(
            children: _answerOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = _answers[_currentQuestionIndex] == (index + 1); // **CHANGED**

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => _handleAnswer(index),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: isSelected
                        ? const Color(0xFF2E225A)
                        : Colors.grey[200],
                    foregroundColor: isSelected ? Colors.white : Colors.black,
                  ),
                  child: Text('${index + 1} $option'), // **CHANGED**: Added numbering
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Button
              if (_currentQuestionIndex > 0)
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            _currentQuestionIndex--;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 50),
                    backgroundColor: const Color(0xFF2E225A),
                  ),
                  child: const Text(
                    'Previous',
                    style: TextStyle(
                      color: Colors.white, // Set text color to white
                    ),
                  ),
                ),
              // Next or Submit Button
              if (_currentQuestionIndex < questions.length - 1)
                ElevatedButton(
                  onPressed: hasAnswered
                      ? () {
                          setState(() {
                            _currentQuestionIndex++;
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 50),
                    backgroundColor: hasAnswered
                        ? const Color(0xFF2E225A)
                        : Colors.grey,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white, // Set text color to white
                    ),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: hasAnswered && !isLoading
                      ? _submitQuestionnaire
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 50),
                    backgroundColor: hasAnswered
                        ? const Color(0xFF2E225A)
                        : Colors.grey,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.white, // Set text color to white
                          ),
                        ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    switch (currentMode) {
      case DiagnosticMode.menu:
        bodyContent = _buildInitialMenu();
        break;
      case DiagnosticMode.questionnaire:
        bodyContent = _buildQuestionnaireForm();
        break;
      case DiagnosticMode.aiAnalysis:
        // Placeholder for AI Analysis functionality
        bodyContent = Center(
          child: Text(
            'AI Analysis feature is under development.',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diagnostic Tools',
          style: TextStyle(color: Colors.white), // Set the text color to white
        ),
        backgroundColor: const Color(0xFF2E225A),
      ),
      body: bodyContent,
    );
  }
}
