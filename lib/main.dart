import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  await StorageService.instance.init();
  await FirestoreService.instance.init();
  runApp(const ProviderScope(child: TreeGamificationApp()));
}

class TreeGamificationApp extends ConsumerWidget {
  const TreeGamificationApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Tree Gamification',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'sans-serif',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}