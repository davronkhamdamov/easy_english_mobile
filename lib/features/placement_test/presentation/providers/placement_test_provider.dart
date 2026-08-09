import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/diagnostic_session.dart';
import '../../domain/entities/estimated_band_score.dart';
import '../../domain/entities/placement_question.dart';
import '../../domain/entities/study_plan_recommendation.dart';
import '../../domain/usecases/calculate_placement_result.dart';
import '../../domain/usecases/fetch_placement_questions.dart';
import '../../domain/usecases/submit_placement_test.dart';

class PlacementTestProvider extends ChangeNotifier {
  final FetchPlacementQuestions _fetchPlacementQuestions;
  final SubmitPlacementTest _submitPlacementTestUseCase;
  final CalculatePlacementResult _calculatePlacementResult;

  late DiagnosticSession _session;
  Timer? _timer;
  bool _isPlayingAudio = false;
  double _audioProgress = 0.0;
  Timer? _audioTimer;

  EstimatedBandScore? _calculatedScore;
  StudyPlanRecommendation? _studyPlan;
  bool _isSubmitting = false;
  String? _errorMessage;

  PlacementTestProvider({
    FetchPlacementQuestions? fetchPlacementQuestions,
    SubmitPlacementTest? submitPlacementTestUseCase,
    CalculatePlacementResult? calculatePlacementResult,
    List<PlacementQuestion>? initialQuestions,
  }) : _fetchPlacementQuestions =
           fetchPlacementQuestions ?? FetchPlacementQuestions(),
       _submitPlacementTestUseCase =
           submitPlacementTestUseCase ?? SubmitPlacementTest(),
       _calculatePlacementResult =
           calculatePlacementResult ?? CalculatePlacementResult() {
    initDiagnosticSession(initialQuestions);
  }

  DiagnosticSession get session => _session;
  bool get isPlayingAudio => _isPlayingAudio;
  double get audioProgress => _audioProgress;
  EstimatedBandScore? get calculatedScore => _calculatedScore;
  StudyPlanRecommendation? get studyPlan => _studyPlan;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  void initDiagnosticSession([List<PlacementQuestion>? customQuestions]) {
    final questions = customQuestions ?? PlacementQuestion.sampleQuestions;
    _session = DiagnosticSession(
      id: 'diag_${DateTime.now().millisecondsSinceEpoch}',
      startTime: DateTime.now(),
      durationSeconds: 600, // 10 minutes countdown
      questions: questions,
    );
    _calculatedScore = null;
    _studyPlan = null;
    _isSubmitting = false;
    _isPlayingAudio = false;
    _audioProgress = 0.0;
    _audioTimer?.cancel();
    _startCountdownTimer();
    notifyListeners();
  }

  Future<void> loadQuestionsFromApi() async {
    try {
      final fetched = await _fetchPlacementQuestions();
      if (fetched.isNotEmpty) {
        initDiagnosticSession(fetched);
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_session.isCompleted) {
        timer.cancel();
        return;
      }
      if (_session.remainingSeconds > 0) {
        _session.remainingSeconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
        submitTest();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _audioTimer?.cancel();
  }

  void toggleAudioPlay() {
    if (_isPlayingAudio) {
      _audioTimer?.cancel();
      _isPlayingAudio = false;
      notifyListeners();
    } else {
      _isPlayingAudio = true;
      notifyListeners();

      _audioTimer?.cancel();
      _audioTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
        _audioProgress += 0.05;
        if (_audioProgress >= 1.0) {
          _audioProgress = 0.0;
          _isPlayingAudio = false;
          timer.cancel();
        }
        notifyListeners();
      });
    }
  }

  void selectOption(int index) {
    if (_session.isCompleted) return;
    final currentQ = _session.currentQuestion;
    _session.userAnswers[currentQ.id] = index;
    notifyListeners();
  }

  void nextQuestion() {
    if (_session.currentQuestionIndex < _session.questions.length - 1) {
      _session.currentQuestionIndex++;
      _isPlayingAudio = false;
      _audioProgress = 0.0;
      _audioTimer?.cancel();
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_session.currentQuestionIndex > 0) {
      _session.currentQuestionIndex--;
      _isPlayingAudio = false;
      _audioProgress = 0.0;
      _audioTimer?.cancel();
      notifyListeners();
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < _session.questions.length) {
      _session.currentQuestionIndex = index;
      _isPlayingAudio = false;
      _audioProgress = 0.0;
      _audioTimer?.cancel();
      notifyListeners();
    }
  }

  void submitTest() {
    if (_isSubmitting || _session.isCompleted) return;

    _isSubmitting = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 800), () async {
      _session.isCompleted = true;
      _isSubmitting = false;

      final result = _calculatePlacementResult(_session, targetBand: 7.5);
      _calculatedScore = result.score;
      _studyPlan = result.studyPlan;

      // Silently sync with backend API if needed
      try {
        await _submitPlacementTestUseCase(_session.userAnswers);
      } catch (_) {}

      notifyListeners();
    });
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
}
