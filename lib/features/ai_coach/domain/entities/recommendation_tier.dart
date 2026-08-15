class RecommendationTier {
  final String title;
  final String status;
  final List<String> items;

  const RecommendationTier({
    required this.title,
    required this.status,
    required this.items,
  });

  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  bool get isLocked => status == 'locked';

  RecommendationTier copyWith({
    String? title,
    String? status,
    List<String>? items,
  }) {
    return RecommendationTier(
      title: title ?? this.title,
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }
}
