import 'package:flutter/material.dart';
import '../data/ai_coach_service.dart';

/// Interactive AI Coach & Personal Study Planner Screen.
class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final AiCoachService _aiCoachService = AiCoachService();
  bool _isLoading = true;

  Map<String, dynamic> _coachData = {
    'predicted_overall_band': 7.0,
    'target_band': 7.5,
    'weakness_summary': <String>[],
    'remediation_tasks': <String>[],
    'ai_coach_notes': '',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _aiCoachService.fetchRecommendations();
      if (mounted) {
        setState(() {
          _coachData = {
            'predicted_overall_band': data['predicted_overall_band'] ?? 7.0,
            'target_band': data['target_band'] ?? 7.5,
            'weakness_summary': (data['weakness_summary'] as List?)?.map((e) => e.toString()).toList() ??
                [
                  'Task 2 Grammatical Range & Coherence',
                  'Listening Section 3 Multiple Choice',
                ],
            'remediation_tasks': (data['remediation_tasks'] as List?)?.map((e) => e.toString()).toList() ??
                [
                  'Complete 1 Sentence Builder exercise',
                  'Review 5 C1 Academic Flashcards',
                ],
            'ai_coach_notes': data['ai_coach_notes']?.toString() ??
                'Awesome progress! Your Speaking Part 1 fluency score rose to Band 7.5.',
          };
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('AI Personal Coach', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card with Band Prediction
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Predicted IELTS Band',
                                style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Band ${_coachData['predicted_overall_band']}',
                                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Target: Band ${_coachData['target_band']}',
                                style: const TextStyle(color: Color(0xFFA5B4FC), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.psychology, color: Colors.white, size: 38),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // AI Coach Message Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Color(0xFFF59E0B), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Coach Guidance',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _coachData['ai_coach_notes'] ?? '',
                          style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Today's Remediation Plan
                  const Text(
                    'Personalized Remediation Plan:',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...(_coachData['remediation_tasks'] as List<String>).map(
                    (task) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              task,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Weakness Matrix
                  const Text(
                    'Identified Weak Points:',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...(_coachData['weakness_summary'] as List<String>).map(
                    (weakness) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              weakness,
                              style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
