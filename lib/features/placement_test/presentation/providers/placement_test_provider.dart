import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/placement_repository_impl.dart';
import '../../domain/entities/diagnostic_session.dart';
import '../../domain/entities/estimated_band_score.dart';
import '../../domain/entities/placement_question.dart';
import '../../domain/entities/placement_result.dart';
import '../../domain/entities/study_plan_recommendation.dart';
import '../../domain/usecases/fetch_placement_questions.dart';
import '../../domain/usecases/submit_placement_test.dart';
import '../state/placement_test_state.dart';

class PlacementTestProvider extends ChangeNotifier {
  final FetchPlacementQuestionsUseCase _fetchQuestionsUseCase;
  final SubmitPlacementTestUseCase _submitTestUseCase;

  PlacementTestState _state = const PlacementTestState();
  Timer? _timer;
  bool _isPlayingAudio = false;
  double _audioProgress = 0.0;
  Timer? _audioTimer;

  PlacementTestProvider({
    FetchPlacementQuestionsUseCase? fetchQuestionsUseCase,
    SubmitPlacementTestUseCase? submitTestUseCase,
    List<PlacementQuestion>? initialQuestions,
  })  : _fetchQuestionsUseCase = fetchQuestionsUseCase ??
            FetchPlacementQuestionsUseCase(PlacementRepositoryImpl()),
        _submitTestUseCase = submitTestUseCase ??
            SubmitPlacementTestUseCase(PlacementRepositoryImpl()) {
    if (initialQuestions != null && initialQuestions.isNotEmpty) {
      _state = _state.copyWith(questions: initialQuestions);
      _startTimer();
    } else {
      loadQuestions();
    }
  }

  PlacementTestState get state => _state;
  bool get isLoading => _state.isLoading;
  List<PlacementQuestion> get questions => _state.questions;
  int get currentIndex => _state.currentIndex;
  Map<String, int> get userAnswers => _state.userAnswers;
  bool get isSubmitting => _state.isSubmitting;
  PlacementResult? get result => _state.result;
  String? get errorMessage => _state.errorMessage;
  bool get isPlayingAudio => _isPlayingAudio;
  double get audioProgress => _audioProgress;

  DiagnosticSession get session => DiagnosticSession(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        startTime: DateTime.now(),
        durationSeconds: 600,
        questions: _state.questions,
        userAnswers: Map.from(_state.userAnswers),
        currentQuestionIndex: _state.currentIndex,
        isCompleted: _state.result != null,
        remainingSeconds: (600 - _state.elapsedSeconds).clamp(0, 600),
      );
  EstimatedBandScore? get calculatedScore => _state.result != null
      ? EstimatedBandScore(
          overallBand: _state.result!.estimatedIeltsBand,
          grammarBand: _state.result!.estimatedIeltsBand,
          vocabularyBand: _state.result!.estimatedIeltsBand,
          readingBand: _state.result!.estimatedIeltsBand,
          listeningBand: _state.result!.estimatedIeltsBand,
          cefrEquivalent: 'CEFR ${_state.result!.estimatedCefrLevel}',
          skillBreakdown: _state.result!.sectionScores.map((k, v) => MapEntry(k, v.score / 10.0)),
          strengths: const ['Completed Diagnostic Assessment'],
          weaknesses: _state.result!.weakAreas,
        )
      : null;
  StudyPlanRecommendation? get studyPlan => _state.result != null
      ? StudyPlanRecommendation.generate(bandScore: calculatedScore!, targetBand: _state.result!.targetBandScore)
      : null;

  void initDiagnosticSession([List<PlacementQuestion>? customQuestions]) {
    if (customQuestions != null && customQuestions.isNotEmpty) {
      _state = PlacementTestState(questions: customQuestions);
      _startTimer();
      notifyListeners();
    } else {
      loadQuestions();
    }
  }

  Future<void> loadQuestions() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();
    try {
      final qList = await _fetchQuestionsUseCase();
      _state = _state.copyWith(isLoading: false, questions: qList, currentIndex: 0, userAnswers: {}, result: null);
      _startTimer();
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    } finally {
      notifyListeners();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _state = _state.copyWith(elapsedSeconds: _state.elapsedSeconds + 1);
      notifyListeners();
    });
  }

  void selectOption(int index) {
    if (_state.isSubmitting || _state.result != null) return;
    final q = _state.currentQuestion;
    if (q == null) return;
    final updated = Map<String, int>.from(_state.userAnswers)..[q.id] = index;
    _state = _state.copyWith(userAnswers: updated);
    notifyListeners();
  }

  void nextQuestion() {
    if (_state.currentIndex < _state.questions.length - 1) {
      _state = _state.copyWith(currentIndex: _state.currentIndex + 1);
      _resetAudio();
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_state.currentIndex > 0) {
      _state = _state.copyWith(currentIndex: _state.currentIndex - 1);
      _resetAudio();
      notifyListeners();
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < _state.questions.length) {
      _state = _state.copyWith(currentIndex: index);
      _resetAudio();
      notifyListeners();
    }
  }

  void toggleAudioPlay() {
    if (_isPlayingAudio) {
      _isPlayingAudio = false;
      _audioTimer?.cancel();
    } else {
      _isPlayingAudio = true;
      _audioTimer?.cancel();
      _audioTimer = Timer.periodic(const Duration(milliseconds: 200), (t) {
        _audioProgress += 0.05;
        if (_audioProgress >= 1.0) {
          _audioProgress = 0.0;
          _isPlayingAudio = false;
          t.cancel();
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void _resetAudio() {
    _isPlayingAudio = false;
    _audioProgress = 0.0;
    _audioTimer?.cancel();
  }

  Future<void> submitTest() async {
    if (_state.isSubmitting || _state.result != null) return;
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();
    try {
      final res = await _submitTestUseCase(answers: _state.userAnswers, totalTimeSeconds: _state.elapsedSeconds);
      _timer?.cancel();
      _state = _state.copyWith(isSubmitting: false, result: res);
    } catch (e) {
      _state = _state.copyWith(isSubmitting: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioTimer?.cancel();
    super.dispose();
  }
}
