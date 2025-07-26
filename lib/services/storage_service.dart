import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/garden_state.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static StorageService get instance => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Daily Progress Methods
  Future<void> saveDailyProgress(UserProgress progress) async {
    final key = 'progress_${progress.date.toIso8601String().split('T')[0]}';
    await _prefs?.setString(key, jsonEncode(progress.toJson()));
  }

  Future<UserProgress?> getDailyProgress(DateTime date) async {
    final key = 'progress_${date.toIso8601String().split('T')[0]}';
    final progressJson = _prefs?.getString(key);
    if (progressJson != null) {
      return UserProgress.fromJson(jsonDecode(progressJson));
    }
    return null;
  }

  // Daily Tasks Methods
  Future<void> saveDailyTasks(List<DailyTask> tasks) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'tasks_$today';
    final tasksJson = tasks.map((task) => task.toJson()).toList();
    await _prefs?.setString(key, jsonEncode(tasksJson));
  }

  Future<List<DailyTask>> getDailyTasks() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'tasks_$today';
    final tasksJson = _prefs?.getString(key);
    
    if (tasksJson != null) {
      final tasksList = jsonDecode(tasksJson) as List;
      return tasksList.map((task) => DailyTask.fromJson(task)).toList();
    }
    
    // Return default tasks if none exist
    return _getDefaultTasks();
  }

  List<DailyTask> _getDefaultTasks() {
    return [
      DailyTask(
        id: '1',
        title: 'Morning Exercise',
        description: 'Complete 20 minutes of physical activity',
      ),
      DailyTask(
        id: '2',
        title: 'Healthy Meal',
        description: 'Eat a nutritious breakfast or lunch',
      ),
      DailyTask(
        id: '3',
        title: 'Learn Something New',
        description: 'Read, watch educational content, or practice a skill',
      ),
    ];
  }

  // Garden State Methods
  Future<void> saveGardenState(GardenState state) async {
    await _prefs?.setString('garden_state', jsonEncode(state.toJson()));
  }

  Future<GardenState?> getGardenState() async {
    final stateJson = _prefs?.getString('garden_state');
    if (stateJson != null) {
      return GardenState.fromJson(jsonDecode(stateJson));
    }
    return null;
  }

  // Total Trees Grown
  Future<int> getTotalTreesGrown() async {
    final gardenState = await getGardenState();
    if (gardenState == null) return 0;
    
    int totalGrowth = 0;
    for (final tree in gardenState.trees) {
      totalGrowth += tree.currentStage;
    }
    return totalGrowth;
  }
}