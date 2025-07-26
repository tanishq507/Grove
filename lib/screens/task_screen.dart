import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../providers/garden_provider.dart';
import '../services/game_service.dart';

class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  Future<void> _toggleTask(int index) async {
    await ref.read(taskListProvider.notifier).toggleTask(index);

    final taskNotifier = ref.read(taskListProvider.notifier);
    final progressNotifier = ref.read(dailyProgressProvider.notifier);

    if (taskNotifier.allTasksCompleted && !progressNotifier.isRewardGranted) {
      _showTreeGrowthReward();
    }
  }

  Future<void> _showTreeGrowthReward() async {
    final gardenNotifier = ref.read(gardenStateProvider.notifier);
    final treeGrown = await gardenNotifier.growTree();

    if (treeGrown && mounted) {
      // Refresh progress state
      ref.invalidate(dailyProgressProvider);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.celebration, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text('Congratulations!'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🌳 Your tree has grown!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                  'Complete all tasks tomorrow to continue growing your forest.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Amazing!'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskListProvider);
    final progress = ref.watch(dailyProgressProvider);

    final isLoading = tasks.isEmpty;
    final rewardClaimed = progress?.rewardGranted ?? false;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(
                tasks: tasks,
                rewardClaimed: rewardClaimed,
                isLoading: isLoading,
              ),
              Expanded(
                child: _buildTaskList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required List tasks,
    required bool rewardClaimed,
    required bool isLoading,
  }) {
    final completedCount =
        ref.read(taskListProvider.notifier).completedTaskCount;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Daily Tasks',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Complete 3 tasks to grow your tree!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  completedCount == 3
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Text(
                  '$completedCount / 3 completed',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (rewardClaimed)
            Container(
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '🌳 Tree grown today!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                'Complete All',
                Icons.done_all,
                _completeAllTasks,
              ),
              _buildQuickActionButton(
                'Reset All',
                Icons.refresh,
                _resetAllTasks,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
      String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Future<void> _completeAllTasks() async {
    await ref.read(taskListProvider.notifier).completeAllTasks();

    if (!ref.read(dailyProgressProvider.notifier).isRewardGranted) {
      _showTreeGrowthReward();
    }
  }

  Future<void> _resetAllTasks() async {
    await ref.read(taskListProvider.notifier).resetAllTasks();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 All tasks reset!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildTaskList() {
    final tasks = ref.watch(taskListProvider);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: GestureDetector(
              onTap: () => _toggleTask(index),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? Colors.green : Colors.grey.shade300,
                  border: Border.all(
                    color:
                        task.isCompleted ? Colors.green : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? Colors.grey : Colors.black87,
              ),
            ),
            subtitle: Text(
              task.description,
              style: TextStyle(
                fontSize: 14,
                color: task.isCompleted ? Colors.grey : Colors.grey.shade600,
              ),
            ),
            onTap: () => _toggleTask(index),
          ),
        );
      },
    );
  }
}
