import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tree_gamification_app/services/storage_service.dart';
import '../models/user_progress.dart';
import '../models/garden_state.dart';
import '../models/tree_species.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  static FirestoreService get instance => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = 'user1'; // In a real app, this would come from authentication
  bool _firestoreAvailable = true;

  Future<void> init() async {
    try {
      // Test Firestore connectivity and permissions
      await _firestore.collection('test').limit(1).get();
      await _initializeSpeciesData();
    } catch (e) {
      if (kDebugMode) {
        print('Firestore not available, using local data: $e');
      }
      _firestoreAvailable = false;
    }
  }

  Future<void> _initializeSpeciesData() async {
    if (!_firestoreAvailable) return;
    
    final speciesCollection = _firestore.collection('species_master');
    
    try {
      for (final species in TreeSpeciesData.allSpecies) {
        final doc = await speciesCollection.doc(species.speciesId).get();
        if (!doc.exists) {
        await speciesCollection.doc(species.speciesId).set(species.toJson());
        }
      }
    } catch (e) {
      _firestoreAvailable = false;
    }
  }

  // Species Master Collection Methods
  Future<List<TreeSpecies>> getAllSpecies() async {
    if (!_firestoreAvailable) {
      return TreeSpeciesData.allSpecies;
    }
    
    try {
    final snapshot = await _firestore.collection('species_master').get();
    return snapshot.docs
        .map((doc) => TreeSpecies.fromJson(doc.data()))
        .toList();
    } catch (e) {
      return TreeSpeciesData.allSpecies;
    }
  }

  Future<TreeSpecies?> getSpeciesById(String speciesId) async {
    if (!_firestoreAvailable) {
      return TreeSpeciesData.allSpecies
          .where((s) => s.speciesId == speciesId)
          .firstOrNull;
    }
    
    try {
    final doc = await _firestore
        .collection('species_master')
        .doc(speciesId)
        .get();
    
    if (doc.exists) {
      return TreeSpecies.fromJson(doc.data()!);
    }
    } catch (e) {
      return TreeSpeciesData.allSpecies
          .where((s) => s.speciesId == speciesId)
          .firstOrNull;
    }
    return null;
  }

  // User Daily Progress Collection Methods
  Future<void> saveDailyProgress(UserProgress progress) async {
    if (!_firestoreAvailable) {
      await StorageService.instance.saveDailyProgress(progress);
      return;
    }
    
    try {
    final dateKey = progress.date.toIso8601String().split('T')[0];
    await _firestore
        .collection('user_daily_progress')
        .doc('${progress.userId}_$dateKey')
        .set(progress.toJson());
    } catch (e) {
      await StorageService.instance.saveDailyProgress(progress);
    }
  }

  Future<UserProgress?> getDailyProgress(DateTime date) async {
    if (!_firestoreAvailable) {
      return await StorageService.instance.getDailyProgress(date);
    }
    
    try {
    final dateKey = date.toIso8601String().split('T')[0];
    final doc = await _firestore
        .collection('user_daily_progress')
        .doc('${_userId}_$dateKey')
        .get();
    
    if (doc.exists) {
      return UserProgress.fromJson(doc.data()!);
    }
    } catch (e) {
      return await StorageService.instance.getDailyProgress(date);
    }
    return null;
  }

  Future<List<UserProgress>> getUserProgressHistory(int days) async {
    if (!_firestoreAvailable) {
      // For local storage, we'll return empty list for now
      // In a full implementation, you could store history locally too
      return [];
    }
    
    try {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    
    final snapshot = await _firestore
        .collection('user_daily_progress')
        .where('userId', isEqualTo: _userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => UserProgress.fromJson(doc.data()))
        .toList();
    } catch (e) {
      return [];
    }
  }

  // Daily Tasks Methods
  Future<void> saveDailyTasks(List<DailyTask> tasks) async {
    if (!_firestoreAvailable) {
      await StorageService.instance.saveDailyTasks(tasks);
      return;
    }
    
    try {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final tasksData = {
      'userId': _userId,
      'date': today,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    await _firestore
        .collection('daily_tasks')
        .doc('${_userId}_$today')
        .set(tasksData);
    } catch (e) {
      await StorageService.instance.saveDailyTasks(tasks);
    }
  }

  Future<List<DailyTask>> getDailyTasks() async {
    if (!_firestoreAvailable) {
      return await StorageService.instance.getDailyTasks();
    }
    
    try {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final doc = await _firestore
        .collection('daily_tasks')
        .doc('${_userId}_$today')
        .get();
    
    if (doc.exists) {
      final data = doc.data()!;
      final tasksList = data['tasks'] as List;
      return tasksList.map((task) => DailyTask.fromJson(task)).toList();
    }
    
    // Return default tasks if none exist
    return _getDefaultTasks();
    } catch (e) {
      return await StorageService.instance.getDailyTasks();
    }
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

  // User Garden State Collection Methods
  Future<void> saveGardenState(GardenState state) async {
    if (!_firestoreAvailable) {
      await StorageService.instance.saveGardenState(state);
      return;
    }
    
    try {
    await _firestore
        .collection('user_garden_state')
        .doc(state.userId)
        .set({
      ...state.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    } catch (e) {
      await StorageService.instance.saveGardenState(state);
    }
  }

  Future<GardenState?> getGardenState() async {
    if (!_firestoreAvailable) {
      return await StorageService.instance.getGardenState();
    }
    
    try {
    final doc = await _firestore
        .collection('user_garden_state')
        .doc(_userId)
        .get();
    
    if (doc.exists) {
      return GardenState.fromJson(doc.data()!);
    }
    } catch (e) {
      return await StorageService.instance.getGardenState();
    }
    return null;
  }

  // Analytics and Statistics
  Future<int> getTotalTreesGrown() async {
    if (!_firestoreAvailable) {
      return await StorageService.instance.getTotalTreesGrown();
    }
    
    final gardenState = await getGardenState();
    if (gardenState == null) return 0;
    
    int totalGrowth = 0;
    for (final tree in gardenState.trees) {
      totalGrowth += tree.currentStage;
    }
    return totalGrowth;
  }

  Future<int> getConsecutiveDays() async {
    if (!_firestoreAvailable) {
      return 0; // Simplified for local storage
    }
    
    final progressHistory = await getUserProgressHistory(30);
    if (progressHistory.isEmpty) return 0;
    
    int consecutiveDays = 0;
    DateTime currentDate = DateTime.now();
    
    for (final progress in progressHistory) {
      final progressDate = progress.date;
      final daysDifference = currentDate.difference(progressDate).inDays;
      
      if (daysDifference == consecutiveDays && progress.rewardGranted) {
        consecutiveDays++;
        currentDate = progressDate;
      } else {
        break;
      }
    }
    
    return consecutiveDays;
  }

  // Real-time listeners
  Stream<GardenState?> gardenStateStream() {
    if (!_firestoreAvailable) {
      return Stream.value(null);
    }
    
    return _firestore
        .collection('user_garden_state')
        .doc(_userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return GardenState.fromJson(doc.data()!);
      }
      return null;
    });
  }

  Stream<List<DailyTask>> dailyTasksStream() {
    if (!_firestoreAvailable) {
      return Stream.value(_getDefaultTasks());
    }
    
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _firestore
        .collection('daily_tasks')
        .doc('${_userId}_$today')
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        final tasksList = data['tasks'] as List;
        return tasksList.map((task) => DailyTask.fromJson(task)).toList();
      }
      return _getDefaultTasks();
    });
  }
}