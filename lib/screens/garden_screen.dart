import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/garden_provider.dart';
import '../providers/task_provider.dart';
import '../models/tree_species.dart';
import '../widgets/forest_background.dart';
import '../widgets/tree_painter.dart';

class GardenScreen extends ConsumerStatefulWidget {
  const GardenScreen({super.key});

  @override
  ConsumerState<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends ConsumerState<GardenScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gardenState = ref.watch(gardenStateProvider);
    final totalTreesAsync = ref.watch(totalTreesGrownProvider);

    return Scaffold(
      body: ForestBackground(
        child: gardenState == null
            ? const Center(child: CircularProgressIndicator())
            : _buildGardenContent(gardenState),
      ),
    );
  }

  Widget _buildGardenContent(gardenState) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: gardenState.trees.isEmpty
                ? _buildEmptyGarden()
                : _buildGardenWithTrees(gardenState),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Forest',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Consumer(builder: (context, ref, child) {
                final totalTreesAsync = ref.watch(totalTreesGrownProvider);
                return totalTreesAsync.when(
                  data: (totalTrees) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🌱 $totalTrees growth stages',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => const Text('Error loading data'),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDebugButton(
                'Reset Forest',
                Icons.refresh,
                Colors.red,
                _resetForest,
              ),
              _buildDebugButton(
                'Grow Tree',
                Icons.park,
                Colors.green,
                _simulateTreeGrowth,
              ),
              _buildDebugButton(
                'Reset Tasks',
                Icons.task_alt,
                Colors.orange,
                _resetTasks,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebugButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(80, 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Future<void> _resetForest() async {
    final confirmed = await _showConfirmationDialog(
      'Reset Forest',
      'This will delete all your trees and progress. Are you sure?',
    );

    if (confirmed) {
      await ref.read(gardenStateProvider.notifier).resetGarden();
      await ref.read(dailyProgressProvider.notifier).resetProgress();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🌱 Forest reset! Start growing new trees.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _simulateTreeGrowth() async {
    final treeGrown = await ref.read(gardenStateProvider.notifier).growTree();

    if (treeGrown) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🌳 Tree grown! Check your forest.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Tree already grown today or forest complete.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _resetTasks() async {
    final confirmed = await _showConfirmationDialog(
      'Reset Tasks',
      'This will reset today\'s task completion. Continue?',
    );

    if (confirmed) {
      await ref.read(taskListProvider.notifier).resetAllTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📋 Tasks reset! Complete them to grow trees.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildEmptyGarden() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.park_outlined,
            size: 80,
            color: Colors.white70,
          ),
          SizedBox(height: 20),
          Text(
            'Your forest is waiting!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Complete 3 daily tasks to grow your first tree',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGardenWithTrees(gardenState) {
    final species = ref.watch(treeSpeciesProvider);

    return Stack(
      children: gardenState.trees
          .map((tree) {
            final treeSpecies =
                species.firstWhere((s) => s.speciesId == tree.speciesId);
            final stageData = treeSpecies.renderingParameters['stages']
                [tree.currentStage.toString()];

            return Positioned(
              left: tree.screenPosition['x']!,
              bottom: tree.screenPosition['y']!,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 +
                        ((_animationController.value * 0.03) *
                            tree.currentStage),
                    child: CustomPaint(
                      size: Size(
                        stageData['width'].toDouble(),
                        stageData['height'].toDouble(),
                      ),
                      painter: TreePainter(tree: tree, species: treeSpecies),
                    ),
                  );
                },
              ),
            );
          })
          .whereType<Widget>()
          .toList(),
    );
  }
}
