class AiQuota {
  const AiQuota({required this.used, required this.limit, required this.remaining, required this.period});

  final int used;
  final int limit;
  final int remaining;

  /// 'daily' | 'monthly'.
  final String period;

  factory AiQuota.fromJson(Map<String, dynamic> json) {
    return AiQuota(
      used: json['used'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
      remaining: json['remaining'] as int? ?? 0,
      period: json['period'] as String? ?? 'daily',
    );
  }
}

/// Keyed by feature: 'explain' | 'chat' | 'study_plan' | 'weak_area'.
class AiQuotas {
  const AiQuotas(this.byFeature);

  final Map<String, AiQuota> byFeature;

  AiQuota? get chat => byFeature['chat'];
  AiQuota? get explain => byFeature['explain'];
  AiQuota? get studyPlan => byFeature['study_plan'];
  AiQuota? get weakArea => byFeature['weak_area'];

  factory AiQuotas.fromJson(Map<String, dynamic> json) {
    return AiQuotas(json.map((key, value) => MapEntry(key, AiQuota.fromJson(value as Map<String, dynamic>))));
  }
}
