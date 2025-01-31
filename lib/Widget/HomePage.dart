/*
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For signOut
import '../pages/login.dart'; // So we can navigate to LoginPage

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4E4EC),
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildLogo(),
          const SizedBox(height: 20),
          _buildWelcomeText(),
          const SizedBox(height: 20),
          Divider(thickness: 1, color: Colors.grey[300], indent: 30, endIndent: 30),
          const SizedBox(height: 20),
          _buildScoreCardContainer(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Possibly add a function
        },
        backgroundColor: const Color(0xFF2E225A),
        elevation: 6,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'assets/lamah_logo.png', // Replace with your actual logo path
        height: 120,
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        const Text(
          'Welcome to Lamah',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E225A),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Early Autism Detection, Simplified and Delivered Right at Your Fingertips!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCardContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildScoreBox('AI Tool Score', '0.0'),
        _buildScoreBox('Questionnaire Score', '0.0'),
        _buildScoreBox('Final Score', '0.0'),
      ],
    );
  }

  Widget _buildScoreBox(String title, String score) {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

*/
// File: HomePage.dart

// File: lib/pages/home_page.dart




// File: lib/pages/home_page.dart

// File: lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For Supabase client
import '../pages/login.dart'; // Ensure the correct path to LoginPage
import '../Widget/DiagnosticToolsPage.dart'; // Import DiagnosticToolsPage

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variables to hold scores
  double questionnaireScore = 0.0;
  double aiToolScore = 0.0; // Placeholder for future AI Tool integration
  double finalScore = 0.0;

  // Loading state
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestScores();
  }

  // Method to fetch both questionnaire and AI scores
  Future<void> _fetchLatestScores() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        // User is not logged in
        _handleError('No authenticated user found.');
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Fetch the latest questionnaire session for the user
      final questionnaireSession = await supabase
          .from('sessions')
          .select('session_id, created_at')
          .eq('user_id', user.id)
          .eq('type', 'questionnaire')
          .order('created_at', ascending: false) // Fetch latest session
          .limit(1)
          .maybeSingle(); // Safely get a single record

      // Initialize scores
      double fetchedQuestionnaireScore = 0.0;
      double fetchedAIScore = 0.0;

      // Handle Questionnaire Score
      if (questionnaireSession != null) {
        final sessionId = questionnaireSession['session_id'];

        // Fetch all questionnaire responses for the latest session
        final responses = await supabase
            .from('questionnaire_responses')
            .select('answer')
            .eq('session_id', sessionId)
            .order('created_at', ascending: true); // Correct 'order' parameter

        if (responses.isNotEmpty) {
          // Calculate the total questionnaire score by summing up the 'answer' fields
          double totalQuestionnaireScore = 0.0;
          for (var response in responses) {
            // 'answer' is float8, so cast to double
            totalQuestionnaireScore += (response['answer'] as num?)?.toDouble() ?? 0.0;
          }
          fetchedQuestionnaireScore = totalQuestionnaireScore;
        }
      }

      // Fetch the latest AI analysis for the user
      final aiAnalysis = await supabase
          .from('ai_analysis')
          .select('result, created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: false) // Fetch latest AI analysis
          .limit(1)
          .maybeSingle(); // Safely get a single record

      // Handle AI Score
      if (aiAnalysis != null) {
        final resultString = aiAnalysis['result'] as String?;

        if (resultString != null) {
          // Determine if the result starts with 'ASD' or 'Non-ASD'
          bool isASD = resultString.startsWith('ASD');
          bool isNonASD = resultString.startsWith('Non-ASD');

          // Use RegExp to extract the numerical value within parentheses
          final regex = RegExp(r'\((\d+(\.\d+)?)%\)');
          
          final match = regex.firstMatch(resultString);

          if (match != null && match.groupCount >= 1) {
            final aiScoreString = match.group(1); // Extracted number as string
            if (aiScoreString != null) {
              double extractedAIScore = double.parse(aiScoreString);
              if (isNonASD) {
                extractedAIScore = -extractedAIScore; // Assign negative score
              }
              fetchedAIScore = extractedAIScore;
            }
          } else {
            // Handle unexpected format
            _handleError('AI result format is invalid.');
          }
        }
      }

      // Update the state variables
      setState(() {
        questionnaireScore = fetchedQuestionnaireScore;
        aiToolScore = fetchedAIScore;
        finalScore = fetchedQuestionnaireScore + fetchedAIScore;
        isLoading = false;
      });
    } catch (e) {
      _handleError('Error fetching scores: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to handle user logout
  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
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

  // Widget to build the logo
  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'assets/lamah_logo.png', // Replace with your actual logo path
        height: 120,
      ),
    );
  }

  // Widget to build the welcome text
  Widget _buildWelcomeText() {
    return Column(
      children: [
        const Text(
          'Welcome to Lamah',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E225A),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Early Autism Detection, Simplified and Delivered Right at Your Fingertips!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  // Widget to build the score card container
  Widget _buildScoreCardContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildScoreBox('AI Tool Score', aiToolScore.toStringAsFixed(1)),
        _buildScoreBox('Questionnaire Score', questionnaireScore.toStringAsFixed(1)),
        _buildScoreBox('Final Score', finalScore.toStringAsFixed(1)),
      ],
    );
  }

  // Widget to build individual score boxes
  Widget _buildScoreBox(String title, String score) {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build the main content
  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildLogo(),
          const SizedBox(height: 20),
          _buildWelcomeText(),
          const SizedBox(height: 20),
          Divider(
            thickness: 1,
            color: Colors.grey[300],
            indent: 30,
            endIndent: 30,
          ),
          const SizedBox(height: 20),
          _buildScoreCardContainer(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4E4EC),
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Set AppBar text and icon color to black
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DiagnosticToolsPage()),
          );
        },
        backgroundColor: const Color(0xFF2E225A),
        elevation: 6,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

