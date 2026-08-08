class LeaderboardUser {
  const LeaderboardUser({required this.id, required this.name, required this.username, this.avatarUrl});

  final int id;
  final String name;
  final String username;
  final String? avatarUrl;

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.totalScore,
    required this.examsCompleted,
    required this.avgScorePercent,
    this.user,
  });

  final int rank;
  final num totalScore;
  final int examsCompleted;
  final num avgScorePercent;

  /// Null for [Leaderboard.myEntry] when the backend already knows who "I"
  /// am from the auth context, so it omits the redundant user block.
  final LeaderboardUser? user;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      totalScore: json['total_score'] as num? ?? 0,
      examsCompleted: json['exams_completed'] as int? ?? 0,
      avgScorePercent: json['avg_score_percent'] as num? ?? 0,
      user: json['user'] != null ? LeaderboardUser.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }
}

class Leaderboard {
  const Leaderboard({required this.top, this.myEntry});

  final List<LeaderboardEntry> top;
  final LeaderboardEntry? myEntry;

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      top: (json['top'] as List<dynamic>? ?? [])
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      myEntry: json['my_entry'] != null
          ? LeaderboardEntry.fromJson(json['my_entry'] as Map<String, dynamic>)
          : null,
    );
  }
}
