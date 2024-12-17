import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizzesScreen extends StatefulWidget {
  @override
  _QuizzesScreenState createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  String? selectedSubject;
  int currentQuestionIndex = 0;
  bool quizFinished = false;
  String? selectedOption;

  Map<String, int> techniqueScores = {
    "Mind Mapping": 0,
    "Pomodoro Technique": 0,
    "Spaced Repetition": 0,
    "The Feynman Technique": 0,
    "Active Recall": 0,
  };

  final Map<String, Color> subjectColors = {
    "Mathematics": Colors.blue,
    "Science": Colors.green,
    "Physical Education": Colors.red,
    "Geography": Colors.purple,
    "Art": Colors.pinkAccent,
  };

  final Map<String, IconData> subjectIcons = {
    "Mathematics": Icons.calculate,
    "Science": Icons.science,
    "Physical Education": Icons.fitness_center,
    "Geography": Icons.map,
    "Art": Icons.brush,
  };

  final Map<String, List<Map<String, dynamic>>> subjectQuizzes = {
    "Mathematics": [
      {
        "question": "How do you solve complex math problems?",
        "options": [
          {"text": "Drawing diagrams or maps", "technique": "Mind Mapping"},
          {"text": "Short, focused study sessions", "technique": "Pomodoro Technique"},
          {"text": "Revising periodically", "technique": "Spaced Repetition"},
          {"text": "Explaining solutions to others", "technique": "The Feynman Technique"},
        ],
        "answer": "Drawing diagrams or maps",
        "flashcard": {
          "header": "Math Tip",
          "content": "Visualizing problems with diagrams simplifies solutions.",
          "icon": Icons.calculate,
        }
      },
      {
        "question": "What helps you remember formulas effectively?",
        "options": [
          {"text": "Writing repeatedly", "technique": "Active Recall"},
          {"text": "Teaching others", "technique": "The Feynman Technique"},
          {"text": "Spacing reviews over time", "technique": "Spaced Repetition"},
          {"text": "Short revision bursts", "technique": "Pomodoro Technique"},
        ],
        "answer": "Writing repeatedly",
        "flashcard": {
          "header": "Recall Tip",
          "content": "Practice formulas repeatedly through self-testing.",
          "icon": Icons.edit,
        }
      },
    ],
    "Science": [
      {
        "question": "What helps you learn scientific processes best?",
        "options": [
          {"text": "Drawing diagrams", "technique": "Mind Mapping"},
          {"text": "Teaching it to a peer", "technique": "The Feynman Technique"},
          {"text": "Testing your knowledge frequently", "technique": "Active Recall"},
          {"text": "Short intervals of focus", "technique": "Pomodoro Technique"},
        ],
        "answer": "Drawing diagrams",
        "flashcard": {
          "header": "Science Tip",
          "content": "Use diagrams to understand steps in scientific processes.",
          "icon": Icons.science,
        }
      },
    ],
    "Physical Education": [
      {
        "question": "How do you stay consistent with fitness goals?",
        "options": [
          {"text": "Working in short bursts of activity", "technique": "Pomodoro Technique"},
          {"text": "Teaching others workout techniques", "technique": "The Feynman Technique"},
          {"text": "Tracking your progress over time", "technique": "Spaced Repetition"},
          {"text": "Visualizing routines", "technique": "Mind Mapping"},
        ],
        "answer": "Tracking your progress over time",
        "flashcard": {
          "header": "Fitness Tip",
          "content": "Track your goals consistently to stay motivated.",
          "icon": Icons.fitness_center,
        }
      },
    ],
    "Geography": [
      {
        "question": "How do you remember geographical locations?",
        "options": [
          {"text": "Using labeled diagrams", "technique": "Mind Mapping"},
          {"text": "Testing your knowledge frequently", "technique": "Active Recall"},
          {"text": "Reviewing maps regularly", "technique": "Spaced Repetition"},
          {"text": "Teaching others", "technique": "The Feynman Technique"},
        ],
        "answer": "Using labeled diagrams",
        "flashcard": {
          "header": "Geography Tip",
          "content": "Visualize maps with clear labels for better memory.",
          "icon": Icons.map,
        }
      },
    ],
    "Art": [
      {
        "question": "How do you develop creative art skills?",
        "options": [
          {"text": "Practicing consistently", "technique": "Active Recall"},
          {"text": "Breaking projects into smaller tasks", "technique": "Pomodoro Technique"},
          {"text": "Using visual inspiration boards", "technique": "Mind Mapping"},
          {"text": "Explaining your art process", "technique": "The Feynman Technique"},
        ],
        "answer": "Using visual inspiration boards",
        "flashcard": {
          "header": "Art Tip",
          "content": "Create visual boards to organize and inspire creative ideas.",
          "icon": Icons.brush,
        }
      },
    ],
  };

  void startQuiz(String subject) {
    setState(() {
      selectedSubject = subject;
      currentQuestionIndex = 0;
      quizFinished = false;
      selectedOption = null;
      techniqueScores.updateAll((key, value) => 0);
    });
  }

  void checkAnswer(String selectedOption, String correctAnswer, String technique) {
    setState(() {
      this.selectedOption = selectedOption;
      if (selectedOption == correctAnswer) {
        techniqueScores[technique] = techniqueScores[technique]! + 1;
      }
    });
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestionIndex < subjectQuizzes[selectedSubject!]!.length - 1) {
        currentQuestionIndex++;
        selectedOption = null;
      } else {
        quizFinished = true;
        saveQuizResults();
      }
    });
  }

  String getRecommendedTechnique() {
    List<MapEntry<String, int>> sortedScores = techniqueScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedScores.first.key;
  }

  void saveQuizResults() {
    if (selectedSubject != null) {
      String technique = getRecommendedTechnique();
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        FirebaseFirestore.instance.collection('results').doc(user.uid).set({
          selectedSubject!: {'recommendedTechnique': technique}
        }, SetOptions(merge: true));
      } else {
        print("No user is logged in. Can't save the quiz results.");
      }
    }
  }

  String getTechniqueExplanation(String technique) {
    const explanations = {
      "Mind Mapping": "Organize concepts visually with diagrams to improve understanding.",
      "Pomodoro Technique": "Use short, focused study sessions with regular breaks to improve concentration.",
      "Spaced Repetition": "Review content periodically to strengthen long-term memory retention.",
      "The Feynman Technique": "Simplify and reinforce learning by teaching concepts to others.",
      "Active Recall": "Test yourself regularly to actively engage your memory and reinforce learning.",
    };
    return explanations[technique] ?? "This technique matches your learning style.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedSubject == null ? 'Select Subject' : 'Quiz - $selectedSubject'),
        backgroundColor: subjectColors[selectedSubject] ?? Colors.blueGrey,
      ),
      body: selectedSubject == null
          ? _buildSubjectSelection()
          : quizFinished
          ? _buildResultSection()
          : _buildQuizSection(),
    );
  }

  Widget _buildSubjectSelection() {
    final subjects = subjectQuizzes.keys.toList();
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 2,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        String subject = subjects[index];
        return GestureDetector(
          onTap: () => startQuiz(subject),
          child: Card(
            color: subjectColors[subject] ?? Colors.grey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(subjectIcons[subject], size: 48, color: Colors.white),
                  Text(subject, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizSection() {
    final question = subjectQuizzes[selectedSubject!]![currentQuestionIndex];
    Map<String, dynamic> flashcard = question["flashcard"];
    Color? cardColor = subjectColors[selectedSubject];

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardColor?.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(question["question"], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cardColor)),
          ),
          ...(question["options"] as List<Map<String, dynamic>>).map((option) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              color: cardColor,
              child: ListTile(
                title: Text(option["text"], style: TextStyle(color: Colors.white)),
                onTap: () => checkAnswer(option["text"], question["answer"], option["technique"]),
              ),
            );
          }).toList(),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.amber[100],
            child: Row(
              children: [
                Icon(flashcard["icon"], color: Colors.amber[800], size: 36),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(flashcard["header"], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(flashcard["content"], style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: cardColor),
            onPressed: nextQuestion,
            child: Text('Next Question', style: TextStyle(fontSize: 18)),
          )
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    String technique = getRecommendedTechnique();
    Color? cardColor = subjectColors[selectedSubject];
    return Center(
      child: Card(
        margin: EdgeInsets.all(16),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, size: 80, color: cardColor),
              SizedBox(height: 10),
              Text('Recommended Study Technique',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cardColor)),
              SizedBox(height: 10),
              Text(
                technique,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                getTechniqueExplanation(technique),
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
