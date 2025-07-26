import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_progress.dart';
import '../services/firestore_service.dart';

// Task List Provider
final taskListProvider = StateNotifierProvider<TaskListNotifier, List<DailyTask>>((ref) {
  return TaskListNotifier();
});

class TaskListNotifier extends StateNotifier<List<DailyTask>> {
  TaskListNotifier() : super([]) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await FirestoreService.instance.getDailyTasks();
    state = tasks;
  }

  Future<void> toggleTask(int index) async {
    final updatedTasks = [...state];
    updatedTasks[index] = DailyTask(
      id: updatedTasks[index].id,
      title: updatedTasks[index].title,
      description: updatedTasks[index].description,
      isCompleted: !updatedTasks[index].isCompleted,
    );
    
    state = updatedTasks;
    await FirestoreService.instance.saveDailyTasks(updatedTasks);
  }

  Future<void> completeAllTasks() async {
    final updatedTasks = state.map((task) => DailyTask(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: true,
    )).toList();
    
    state = updatedTasks;
    await FirestoreService.instance.saveDailyTasks(updatedTasks);
  }

  Future<void> resetAllTasks() async {
    final updatedTasks = state.map((task) => DailyTask(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: false,
    )).toList();
    
    state = updatedTasks;
    await FirestoreService.instance.saveDailyTasks(updatedTasks);
    
    // Reset daily progress
    final resetProgress = UserProgress(
      userId: 'user1',
      date: DateTime.now(),
      tasksCompleted: 0,
      rewardGranted: false,
    );
    await FirestoreService.instance.saveDailyProgress(resetProgress);
  }

  int get completedTaskCount => state.where((task) => task.isCompleted).length;
  bool get allTasksCompleted => completedTaskCount == 3;
}

// Daily Progress Provider
final dailyProgressProvider = StateNotifierProvider<DailyProgressNotifier, UserProgress?>((ref) {
  return DailyProgressNotifier();
});

class DailyProgressNotifier extends StateNotifier<UserProgress?> {
  DailyProgressNotifier() : super(null) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await FirestoreService.instance.getDailyProgress(DateTime.now());
    state = progress;
  }

  Future<void> updateProgress(UserProgress progress) async {
    state = progress;
    await FirestoreService.instance.saveDailyProgress(progress);
  }

  Future<void> resetProgress() async {
    final resetProgress = UserProgress(
      userId: 'user1',
      date: DateTime.now(),
      tasksCompleted: 0,
      rewardGranted: false,
    );
    state = resetProgress;
    await FirestoreService.instance.saveDailyProgress(resetProgress);
  }

  bool get isRewardGranted => state?.rewardGranted ?? false;
}