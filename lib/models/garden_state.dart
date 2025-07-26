class GardenTree {
  final String speciesId;
  final int currentStage;
  final Map<String, double> screenPosition;
  final DateTime plantedDate;

  GardenTree({
    required this.speciesId,
    required this.currentStage,
    required this.screenPosition,
    required this.plantedDate,
  });

  Map<String, dynamic> toJson() => {
    'speciesId': speciesId,
    'currentStage': currentStage,
    'screenPosition': screenPosition,
    'plantedDate': plantedDate.toIso8601String(),
  };

  factory GardenTree.fromJson(Map<String, dynamic> json) => GardenTree(
    speciesId: json['speciesId'],
    currentStage: json['currentStage'],
    screenPosition: Map<String, double>.from(json['screenPosition']),
    plantedDate: DateTime.parse(json['plantedDate']),
  );

  GardenTree copyWith({
    String? speciesId,
    int? currentStage,
    Map<String, double>? screenPosition,
    DateTime? plantedDate,
  }) {
    return GardenTree(
      speciesId: speciesId ?? this.speciesId,
      currentStage: currentStage ?? this.currentStage,
      screenPosition: screenPosition ?? this.screenPosition,
      plantedDate: plantedDate ?? this.plantedDate,
    );
  }
}

class GardenState {
  final String userId;
  final List<GardenTree> trees;

  GardenState({
    required this.userId,
    required this.trees,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'trees': trees.map((tree) => tree.toJson()).toList(),
  };

  factory GardenState.fromJson(Map<String, dynamic> json) => GardenState(
    userId: json['userId'],
    trees: (json['trees'] as List)
        .map((tree) => GardenTree.fromJson(tree))
        .toList(),
  );
}