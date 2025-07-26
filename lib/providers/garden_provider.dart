import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/garden_state.dart';
import '../models/tree_species.dart';
import '../services/firestore_service.dart';
import '../services/game_service.dart';

// Garden State Provider
final gardenStateProvider = StateNotifierProvider<GardenStateNotifier, GardenState?>((ref) {
  return GardenStateNotifier();
});

class GardenStateNotifier extends StateNotifier<GardenState?> {
  GardenStateNotifier() : super(null) {
    _loadGardenState();
  }

  Future<void> _loadGardenState() async {
    final gardenState = await FirestoreService.instance.getGardenState();
    state = gardenState;
  }

  Future<void> updateGardenState(GardenState newState) async {
    state = newState;
    await FirestoreService.instance.saveGardenState(newState);
  }

  Future<void> resetGarden() async {
    final emptyGarden = GardenState(userId: 'user1', trees: []);
    state = emptyGarden;
    await FirestoreService.instance.saveGardenState(emptyGarden);
  }

  Future<bool> growTree() async {
    final treeGrown = await GameService.instance.completeAllTasks();
    if (treeGrown) {
      await _loadGardenState();
    }
    return treeGrown;
  }

  List<GardenTree> get trees => state?.trees ?? [];
  bool get hasAnyTrees => trees.isNotEmpty;
}

// Tree Species Provider
final treeSpeciesProvider = Provider<List<TreeSpecies>>((ref) {
  return TreeSpeciesData.allSpecies;
});

// Total Trees Grown Provider
final totalTreesGrownProvider = FutureProvider<int>((ref) async {
  return await FirestoreService.instance.getTotalTreesGrown();
});

// Forest Status Provider
final forestStatusProvider = FutureProvider<String>((ref) async {
  return await GameService.instance.getForestStatus();
});