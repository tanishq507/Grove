class TreeSpecies {
  final String speciesId;
  final int totalStages;
  final Map<String, dynamic> renderingParameters;

  TreeSpecies({
    required this.speciesId,
    required this.totalStages,
    required this.renderingParameters,
  });

  Map<String, dynamic> toJson() => {
    'speciesId': speciesId,
    'totalStages': totalStages,
    'renderingParameters': renderingParameters,
  };

  factory TreeSpecies.fromJson(Map<String, dynamic> json) => TreeSpecies(
    speciesId: json['speciesId'],
    totalStages: json['totalStages'],
    renderingParameters: json['renderingParameters'],
  );
}

class TreeSpeciesData {
  static List<TreeSpecies> get allSpecies => [
    TreeSpecies(
      speciesId: 'oak',
      totalStages: 2,
      renderingParameters: {
        'baseColor': 0xFF8B4513,
        'leafColor': 0xFF228B22,
        'stages': {
          '1': {'height': 60.0, 'width': 30.0, 'branches': 2},
          '2': {'height': 120.0, 'width': 80.0, 'branches': 6},
        }
      },
    ),
    TreeSpecies(
      speciesId: 'pine',
      totalStages: 3,
      renderingParameters: {
        'baseColor': 0xFF654321,
        'leafColor': 0xFF006400,
        'stages': {
          '1': {'height': 50.0, 'width': 25.0, 'layers': 2},
          '2': {'height': 90.0, 'width': 40.0, 'layers': 4},
          '3': {'height': 140.0, 'width': 70.0, 'layers': 7},
        }
      },
    ),
    TreeSpecies(
      speciesId: 'willow',
      totalStages: 4,
      renderingParameters: {
        'baseColor': 0xFF8B7355,
        'leafColor': 0xFF9ACD32,
        'stages': {
          '1': {'height': 40.0, 'width': 20.0, 'droopiness': 0.2},
          '2': {'height': 70.0, 'width': 35.0, 'droopiness': 0.4},
          '3': {'height': 100.0, 'width': 60.0, 'droopiness': 0.6},
          '4': {'height': 150.0, 'width': 100.0, 'droopiness': 0.8},
        }
      },
    ),
  ];
}