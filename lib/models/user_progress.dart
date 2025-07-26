class UserProgress {
  final String userId;
  final DateTime date;
  final int tasksCompleted;
  final bool rewardGranted;

  UserProgress({
    required this.userId,
    required this.date,
    required this.tasksCompleted,
    required this.rewardGranted,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'date': date.toIso8601String(),
    'tasksCompleted': tasksCompleted,
    'rewardGranted': rewardGranted,
  };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
    userId: json['userId'],
    date: DateTime.parse(json['date']),
    tasksCompleted: json['tasksCompleted'],
    rewardGranted: json['rewardGranted'],
  );
}

class DailyTask {
  final String id;
  final String title;
  final String description;
  bool isCompleted;

  DailyTask({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
  };

  factory DailyTask.fromJson(Map<String, dynamic> json) => DailyTask(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    isCompleted: json['isCompleted'] ?? false,
  );
}