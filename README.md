# 🌳 Grove– A Tree-Based Habit Tracker

**Grove** is a Flutter app that gamifies task completion by growing a visual forest. Every time a user completes **3 daily tasks**, a **tree grows or evolves**, creating an engaging and rewarding experience. With rich visuals powered by `CustomPainter`, smooth animations, and persistent data storage using Firebase Firestore and Riverpod state management — this app brings productivity to life.

---

## ✨ Features

### 🎮 Gamified Task Completion
- ✅ Complete **3 tasks** in a day to **trigger tree growth**
- 🌱 Trees grow one stage at a time and span **3 distinct species**
- 🌲 Each species has a unique number of **growth stages**:
  - **Oak**: 2 stages
  - **Pine**: 3 stages
  - **Willow**: 4 stages

### 🌿 Custom Forest Visualization
- 🌳 Trees drawn entirely with **CustomPainter**
- 📍 Each tree appears in a different position on the screen
- 🌄 Visually engaging **forest background** with gradient sky
- ✨ Natural, animated transitions between growth stages

### ☁️ Firebase Integration
- Firestore used to store:
  - Tree species master data
  - Daily user task completion status
  - Current garden state (trees, stages, positions)

---

## 🧪 Debug Features

### 🧭 Forest Screen (Garden Tab)
- 🔄 **Reset Forest**: Clear all trees and progress
- 🌳 **Grow Tree**: Manually simulate tree growth (for testing)
- 📋 **Reset Tasks**: Resets today's task completion

### 📋 Task Screen
- ✅ **Complete All**: Instantly completes all 3 tasks and grows tree
- 🔄 **Reset All**: Resets all tasks for the current day

---

## 🧠 State Management (Riverpod)

### 🔌 Core Providers
- `TaskListProvider`: Daily task state
- `DailyProgressProvider`: Tracks task completion & rewards
- `GardenStateProvider`: Tree growth and garden structure
- `TreeSpeciesProvider`: Master species/stage configuration
- `TotalTreesGrownProvider`: Tracks overall tree stats
- `ForestStatusProvider`: Checks forest completion status

### 🔄 Benefits
- ✅ **Reactive UI**: Screens auto-update on state change
- 💡 **Separation of Logic**: Business logic is fully decoupled from UI
- ⚡ **Efficient**: Caches and rebuilds only what’s necessary

---

## 📱 Screens Overview

| Screen         | Description |
|----------------|-------------|
| **TaskScreen** | Manage 3 daily tasks, complete or reset |
| **GardenScreen** | Visualize your forest, grow or reset trees |
| **HomeScreen**  | Unified view; listens to state changes via `ConsumerWidget` |

---



## 🗃️ Firestore Collections

### `species`
- Stores master data: ID, stages, visual parameters

### `user_progress/{userId}/daily`
- Daily task completions and reward given

### `user_gardens/{userId}/trees`
- Stores each tree's:
  - Species ID
  - Growth stage
  - Position on screen
  - Planted date

---

