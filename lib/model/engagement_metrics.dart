class EngagementMetrics {
  final int viewCount;

  EngagementMetrics._raw({
    required this.viewCount,
  });

  factory EngagementMetrics.fromJson(Map<String, dynamic> json) {
    assert(json['viewCount'] is int);
    return EngagementMetrics._raw(
        viewCount: json['viewCount']! as int,
    );
  }
}
