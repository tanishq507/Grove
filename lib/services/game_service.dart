import '../models/tree_species.dart';
import '../models/garden_state.dart';
import '../models/user_progress.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class GameService {
  static final GameService _instance = GameService._internal();
  static GameService get instance => _instance;
  GameService._internal();

  Future<bool> completeAllTasks() async {
    final today = DateTime.now();
    final progress = await FirestoreService.instance.getDailyProgress(today);
    
    // Check if reward already granted today
    if (progress?.rewardGranted == true) {
      return false;
    }

    // Save progress
    final newProgress = UserProgress(
      userId: 'user1',
      date: today,
      tasksCompleted: 3,
      rewardGranted: true,
    );
    await FirestoreService.instance.saveDailyProgress(newProgress);

    // Trigger tree growth
    await _growTree();
    return true;
  }

  Future<bool> canGrowMoreTrees() async {
    final gardenState = await FirestoreService.instance.getGardenState();
    if (gardenState == null) return true;
    
    final species = TreeSpeciesData.allSpecies;
    
    // Check if we've completed all species
    if (gardenState.trees.length >= species.length) {
      final lastTree = gardenState.trees.last;
      final lastSpecies = species.firstWhere((s) => s.speciesId == lastTree.speciesId);
      return lastTree.currentStage < lastSpecies.totalStages;
    }
    
    return true;
  }

  Future<String> getForestStatus() async {
    final gardenState = await FirestoreService.instance.getGardenState();
    if (gardenState == null || gardenState.trees.isEmpty) {
      return 'Empty forest - plant your first tree!';
    }
    
    final species = TreeSpeciesData.allSpecies;
    final totalTrees = gardenState.trees.length;
    final totalGrowthStages = gardenState.trees.fold<int>(
      0, (sum, tree) => sum + tree.currentStage
    );
    
    final maxPossibleStages = species.fold<int>(
      0, (sum, species) => sum + species.totalStages
    );
    
    if (totalGrowthStages >= maxPossibleStages) {
      return 'Forest complete! 🌳 All trees fully grown.';
    }
    
    return 'Growing forest: $totalTrees trees, $totalGrowthStages growth stages';
  }

  Future<void> _growTree() async {
    GardenState? gardenState = await FirestoreService.instance.getGardenState();
    
    if (gardenState == null) {
      // Create first tree
      gardenState = GardenState(
        userId: 'user1',
        trees: [_createNewTree('oak', 0, 1)],
      );
    } else {
      gardenState = _processTreeGrowth(gardenState);
    }

    await FirestoreService.instance.saveGardenState(gardenState);
  }

  GardenState _processTreeGrowth(GardenState state) {
    final species = TreeSpeciesData.allSpecies;
    final trees = List<GardenTree>.from(state.trees);

    if (trees.isEmpty) {
      trees.add(_createNewTree('oak', 0, 1));
      return GardenState(userId: state.userId, trees: trees);
    }

    // Get the latest tree
    final latestTree = trees.last;
    final treeSpecies = species.firstWhere((s) => s.speciesId == latestTree.speciesId);

    if (latestTree.currentStage < treeSpecies.totalStages) {
      // Grow current tree
      trees[trees.length - 1] = latestTree.copyWith(
        currentStage: latestTree.currentStage + 1,
      );
    } else {
      // Plant new tree if current is fully grown
      final currentSpeciesIndex = species.indexWhere((s) => s.speciesId == latestTree.speciesId);
      if (currentSpeciesIndex < species.length - 1) {
        final nextSpecies = species[currentSpeciesIndex + 1];
        trees.add(_createNewTree(nextSpecies.speciesId, trees.length, 1));
      }
    }

    return GardenState(userId: state.userId, trees: trees);
  }

  GardenTree _createNewTree(String speciesId, int treeIndex, int initialStage) {
    final positions = [
      {'x': 80.0, 'y': 50.0},   // Oak - bottom left
      {'x': 200.0, 'y': 80.0},  // Pine - center
      {'x': 300.0, 'y': 60.0},  // Willow - bottom right
    ];

    return GardenTree(
      speciesId: speciesId,
      currentStage: initialStage,
      screenPosition: positions[treeIndex % positions.length],
      plantedDate: DateTime.now(),
    );
  }
}