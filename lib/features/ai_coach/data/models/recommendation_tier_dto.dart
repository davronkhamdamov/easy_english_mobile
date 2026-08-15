import '../../domain/entities/recommendation_tier.dart';

class RecommendationTierDto {
  final String? title;
  final String? status;
  final List<String>? items;

  RecommendationTierDto({
    this.title,
    this.status,
    this.items,
  });

  factory RecommendationTierDto.fromJson(Map<String, dynamic> json) {
    return RecommendationTierDto(
      title: json['title']?.toString(),
      status: json['status']?.toString(),
      items: (json['items'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'status': status,
      'items': items,
    };
  }

  RecommendationTier toDomain({
    required String defaultTitle,
    required String defaultStatus,
  }) {
    return RecommendationTier(
      title: title ?? defaultTitle,
      status: status ?? defaultStatus,
      items: items ?? const [],
    );
  }
}
