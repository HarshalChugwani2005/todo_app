import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/virtual_pet_model.dart';
import '../models/pet_achievements_model.dart';
import 'notification_service.dart';

class VirtualPetService extends ChangeNotifier {
  static final VirtualPetService _instance = VirtualPetService._internal();
  factory VirtualPetService() => _instance;
  VirtualPetService._internal();

  VirtualPet? _currentPet;
  late Box<VirtualPet> _petBox;
  bool _isInitialized = false;

  VirtualPet? get currentPet => _currentPet;
  bool get hasPet => _currentPet != null;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _petBox = await Hive.openBox<VirtualPet>('virtual_pets');
      _loadCurrentPet();
      _isInitialized = true;
      
      // Start periodic neglect checking
      _startNeglectTimer();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing VirtualPetService: $e');
    }
  }

  void _loadCurrentPet() {
    if (_petBox.isNotEmpty) {
      _currentPet = _petBox.getAt(0);
      _currentPet?.applyNeglectPenalties();
    }
  }

  Future<VirtualPet> createPet({
    required String name,
    required PetType petType,
  }) async {
    // If there's already a pet, remove it first
    if (_currentPet != null) {
      await _currentPet!.delete();
    }

    _currentPet = VirtualPet(
      name: name,
      petType: petType.index,
    );

    await _petBox.add(_currentPet!);
    notifyListeners();

    // Send welcome notification
    await NotificationService().showInstantNotification(
      id: 999,
      title: 'Welcome ${_currentPet!.name}!',
      body: 'Your new virtual pet is ready to grow with you!',
    );

    return _currentPet!;
  }

  Future<void> deletePet() async {
    if (_currentPet != null) {
      await _currentPet!.delete();
      _currentPet = null;
      notifyListeners();
    }
  }

  // Pet care actions
  Future<void> feedPet() async {
    if (_currentPet == null) return;

    _currentPet!.feed();
    notifyListeners();

    await NotificationService().showInstantNotification(
      id: 1001,
      title: '${_currentPet!.name} says thanks!',
      body: 'Your pet enjoyed the meal! 🍽️',
    );
  }

  Future<void> playWithPet() async {
    if (_currentPet == null) return;

    _currentPet!.play();
    notifyListeners();

    await NotificationService().showInstantNotification(
      id: 1002,
      title: 'Playtime with ${_currentPet!.name}!',
      body: 'Your pet had fun playing! 🎾',
    );
  }

  Future<void> putPetToSleep() async {
    if (_currentPet == null) return;

    _currentPet!.rest();
    notifyListeners();

    await NotificationService().showInstantNotification(
      id: 1003,
      title: '${_currentPet!.name} is sleeping',
      body: 'Sweet dreams! Your pet is resting. 😴',
    );
  }

  Future<void> wakePetUp() async {
    if (_currentPet == null) return;

    _currentPet!.wakeUp();
    notifyListeners();

    await NotificationService().showInstantNotification(
      id: 1004,
      title: '${_currentPet!.name} is awake!',
      body: 'Good morning! Your pet is ready for the day! ☀️',
    );
  }

  // Task completion rewards
  Future<void> rewardPetForTask(int taskPriority) async {
    if (_currentPet == null) return;

    // Store previous state for comparison
    final oldLevel = _currentPet!.level;
    final oldGrowthStage = _currentPet!.growthStageEnum;
    final oldAchievementCount = _currentPet!.unlockedAchievements.length;

    // Reward pet for task completion (may unlock achievements)
    _currentPet!.rewardForTaskCompletion(taskPriority);

    // Notify if pet leveled up
    if (_currentPet!.level > oldLevel) {
      await _showLevelUpNotification(oldLevel, _currentPet!.level);
    }

    // Notify if pet changed growth stage
    if (_currentPet!.growthStageEnum != oldGrowthStage) {
      await _showGrowthNotification(oldGrowthStage, _currentPet!.growthStageEnum);
    }

    // Notify for each newly unlocked achievement
    if (_currentPet!.unlockedAchievements.length > oldAchievementCount) {
      final newAchievements = _currentPet!.unlockedAchievements
          .skip(oldAchievementCount)
          .toList();

      for (final achievementId in newAchievements) {
        await _showAchievementNotification(achievementId);
      }
    }

    // Update listeners/UI
    notifyListeners();
  }

  Future<void> _showLevelUpNotification(int oldLevel, int newLevel) async {
    await NotificationService().showInstantNotification(
      id: 1005,
      title: '🎉 ${_currentPet!.name} leveled up!',
      body: 'Level $oldLevel → $newLevel! Keep up the great work!',
    );
  }

  Future<void> _showGrowthNotification(GrowthStage oldStage, GrowthStage newStage) async {
    String stageMessage = '';
    switch (newStage) {
      case GrowthStage.baby:
        stageMessage = 'Your pet has hatched! 🐣';
        break;
      case GrowthStage.child:
        stageMessage = 'Your pet is growing up! 🌱';
        break;
      case GrowthStage.teen:
        stageMessage = 'Your pet is now a teenager! 🌿';
        break;
      case GrowthStage.adult:
        stageMessage = 'Your pet has reached adulthood! 🌳';
        break;
      case GrowthStage.elder:
        stageMessage = 'Your pet is now a wise elder! 🎋';
        break;
      default:
        stageMessage = 'Your pet is evolving! ✨';
    }

    await NotificationService().showInstantNotification(
      id: 1006,
      title: '🌟 ${_currentPet!.name} evolved!',
      body: stageMessage,
    );
  }

  Future<void> _showAchievementNotification(String achievementId) async {
    final achievement = AchievementSystem.getAchievementById(achievementId);
    if (achievement != null) {
      await NotificationService().showInstantNotification(
        id: 1020 + achievement.hashCode % 100, // Unique ID for each achievement
        title: '🏆 Achievement Unlocked!',
        body: '${achievement.title} - ${achievement.points} points earned!',
      );
    }
  }

  // Neglect management
  void _startNeglectTimer() {
    // Check every hour for neglect
    Stream.periodic(const Duration(hours: 1)).listen((_) {
      _checkForNeglect();
    });
  }

  Future<void> _checkForNeglect() async {
    if (_currentPet == null) return;

    final oldWellbeing = _currentPet!.overallWellbeing;
    _currentPet!.applyNeglectPenalties();
    
    // Send notification if pet needs attention
    if (_currentPet!.needsAttention) {
      await _sendAttentionNotification();
    }

    // If wellbeing significantly dropped, notify user
    if (_currentPet!.overallWellbeing < oldWellbeing - 10) {
      await NotificationService().showInstantNotification(
        id: 1007,
        title: '${_currentPet!.name} needs you!',
        body: 'Your pet\'s wellbeing is declining. Show some love! 💔',
      );
    }

    notifyListeners();
  }

  Future<void> _sendAttentionNotification() async {
    String message = '';
    int notificationId = 1008;

    switch (_currentPet!.attentionUrgency) {
      case 3: // Critical
        message = 'URGENT: ${_currentPet!.name} is in critical condition! 🚨';
        notificationId = 1008;
        break;
      case 2: // High
        message = '${_currentPet!.name} really needs your attention! 🆘';
        notificationId = 1009;
        break;
      case 1: // Medium
        message = '${_currentPet!.name} could use some care 🤗';
        notificationId = 1010;
        break;
    }

    if (message.isNotEmpty) {
      await NotificationService().showInstantNotification(
        id: notificationId,
        title: 'Pet Care Reminder',
        body: message,
      );
    }
  }

  // Accessory management
  Future<void> equipAccessory(String accessory) async {
    if (_currentPet == null) return;
    if (!_currentPet!.unlockedAccessories.contains(accessory)) return;

    _currentPet!.currentAccessory = accessory;
    _currentPet!.save();
    notifyListeners();
  }

  Future<void> removeAccessory() async {
    if (_currentPet == null) return;

    _currentPet!.currentAccessory = null;
    _currentPet!.save();
    notifyListeners();
  }

  // Statistics
  Map<String, dynamic> getPetStatistics() {
    if (_currentPet == null) return {};

    return {
      'name': _currentPet!.name,
      'type': _currentPet!.petTypeEnum.name,
      'level': _currentPet!.level,
      'age_days': _currentPet!.ageInDays,
      'tasks_completed': _currentPet!.totalTasksCompleted,
      'growth_stage': _currentPet!.growthStageEnum.name,
      'wellbeing': _currentPet!.overallWellbeing,
      'unlocked_accessories': _currentPet!.unlockedAccessories.length,
      'days_since_creation': DateTime.now().difference(_currentPet!.createdAt).inDays,
    };
  }

  // Pet interaction suggestions
  List<String> getPetSuggestions() {
    if (_currentPet == null) return [];

    final suggestions = <String>[];

    if (_currentPet!.hunger > 70) {
      suggestions.add('Your pet is hungry! Consider feeding them.');
    }

    if (_currentPet!.happiness < 50) {
      suggestions.add('Your pet seems sad. How about playing together?');
    }

    if (_currentPet!.energy < 30) {
      suggestions.add('Your pet looks tired. Maybe it\'s time for a nap.');
    }

    if (_currentPet!.health < 60) {
      suggestions.add('Your pet\'s health is low. Take better care of them!');
    }

    final hoursSinceLastPlay = _currentPet!.lastPlayed != null 
        ? DateTime.now().difference(_currentPet!.lastPlayed!).inHours 
        : 999;
    
    if (hoursSinceLastPlay > 12) {
      suggestions.add('It\'s been a while since you played together!');
    }

    if (suggestions.isEmpty) {
      suggestions.add('Your pet is doing great! Keep completing tasks to help them grow!');
    }

    return suggestions;
  }

  // Force refresh (useful for debugging or manual updates)
  Future<void> refresh() async {
    if (_currentPet != null) {
      _currentPet!.applyNeglectPenalties();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _petBox.close();
    super.dispose();
  }
}