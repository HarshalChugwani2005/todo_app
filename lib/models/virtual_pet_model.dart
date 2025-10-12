import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'pet_emotions_model.dart';
import 'pet_achievements_model.dart';

part 'virtual_pet_model.g.dart';

enum PetType { cat, dog, plant, dragon }
enum PetMood { happy, neutral, sad, excited, sleeping }
enum GrowthStage { egg, baby, child, teen, adult, elder }

@HiveType(typeId: 2)
class VirtualPet extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int petType; // PetType enum index

  @HiveField(2)
  int level;

  @HiveField(3)
  int experience;

  @HiveField(4)
  int health;

  @HiveField(5)
  int happiness;

  @HiveField(6)
  int hunger;

  @HiveField(7)
  int energy;

  @HiveField(8)
  DateTime lastInteraction;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  int totalTasksCompleted;

  @HiveField(11)
  int currentMood; // PetMood enum index

  @HiveField(12)
  int growthStage; // GrowthStage enum index

  @HiveField(13)
  List<String> unlockedAccessories;

  @HiveField(14)
  String? currentAccessory;

  @HiveField(15)
  bool isAsleep;

  @HiveField(16)
  DateTime? lastFed;

  @HiveField(17)
  DateTime? lastPlayed;

  @HiveField(18)
  int primaryPersonalityTrait; // PersonalityTrait enum index

  @HiveField(19)
  int secondaryPersonalityTrait; // PersonalityTrait enum index

  @HiveField(20)
  List<String> emotionHistory; // JSON strings of recent emotions

  @HiveField(21)
  List<String> memoryHistory; // JSON strings of significant memories

  @HiveField(22)
  int currentEmotion; // EmotionType enum index

  @HiveField(23)
  double emotionalIntensity;

  @HiveField(24)
  int productivityStreak; // Days of consecutive task completion

  @HiveField(25)
  DateTime? lastEmotionChange;

  @HiveField(26)
  List<String> unlockedAchievements;

  @HiveField(27)
  int totalAchievementPoints;

  @HiveField(28)
  int highPriorityTasksCompleted;

  VirtualPet({
    required this.name,
    this.petType = 0, // Default to cat
    this.level = 1,
    this.experience = 0,
    this.health = 100,
    this.happiness = 80,
    this.hunger = 50,
    this.energy = 100,
    DateTime? lastInteraction,
    DateTime? createdAt,
    this.totalTasksCompleted = 0,
    this.currentMood = 1, // Default to neutral
    this.growthStage = 1, // Default to baby
    List<String>? unlockedAccessories,
    this.currentAccessory,
    this.isAsleep = false,
    this.lastFed,
    this.lastPlayed,
    this.primaryPersonalityTrait = 0, // Default to energetic
    this.secondaryPersonalityTrait = 6, // Default to loyal
    List<String>? emotionHistory,
    List<String>? memoryHistory,
    this.currentEmotion = 2, // Default to contentment
    this.emotionalIntensity = 0.6,
    this.productivityStreak = 0,
    this.lastEmotionChange,
    List<String>? unlockedAchievements,
    this.totalAchievementPoints = 0,
    this.highPriorityTasksCompleted = 0,
  }) : lastInteraction = lastInteraction ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now(),
       unlockedAccessories = unlockedAccessories ?? [],
       emotionHistory = emotionHistory ?? [],
       memoryHistory = memoryHistory ?? [],
       unlockedAchievements = unlockedAchievements ?? [];

  // Getters for enums
  PetType get petTypeEnum => PetType.values[petType];
  PetMood get moodEnum => PetMood.values[currentMood];
  GrowthStage get growthStageEnum => GrowthStage.values[growthStage];
  PersonalityTrait get primaryPersonalityEnum => PersonalityTrait.values[primaryPersonalityTrait];
  PersonalityTrait get secondaryPersonalityEnum => PersonalityTrait.values[secondaryPersonalityTrait];
  EmotionType get currentEmotionEnum => EmotionType.values[currentEmotion];
  
  // Get pet personality
  PetPersonality get personality => PetPersonality(
    primaryTrait: primaryPersonalityEnum,
    secondaryTrait: secondaryPersonalityEnum,
  );

  // Experience requirements for each level
  int get experienceToNextLevel => level * 100;
  double get experienceProgress => experience / experienceToNextLevel;

  // Overall pet status
  int get overallWellbeing => ((health + happiness + (100 - hunger) + energy) / 4).round();

  // Pet aging based on time and interaction
  int get ageInDays => DateTime.now().difference(createdAt).inDays;

  // Colors for different stats
  Color get healthColor {
    if (health >= 80) return Colors.green;
    if (health >= 50) return Colors.orange;
    return Colors.red;
  }

  Color get happinessColor {
    if (happiness >= 80) return Colors.pink;
    if (happiness >= 50) return Colors.yellow;
    return Colors.grey;
  }

  Color get hungerColor {
    if (hunger <= 30) return Colors.green;
    if (hunger <= 70) return Colors.orange;
    return Colors.red;
  }

  Color get energyColor {
    if (energy >= 80) return Colors.blue;
    if (energy >= 50) return Colors.lightBlue;
    return Colors.grey;
  }

  // Methods for pet care
  void feed() {
    hunger = (hunger - 30).clamp(0, 100);
    happiness = (happiness + 10).clamp(0, 100);
    health = (health + 5).clamp(0, 100);
    lastFed = DateTime.now();
    lastInteraction = DateTime.now();
    
    // Add emotion based on personality and hunger level
    if (hunger > 70) {
      addEmotion(EmotionType.gratitude, 0.8, trigger: 'You fed me when I was really hungry!');
    } else if (personality.prefersActivity('food')) {
      addEmotion(EmotionType.joy, 0.6, trigger: 'Delicious food!');
    } else {
      addEmotion(EmotionType.contentment, 0.4, trigger: 'Thanks for the meal');
    }
    
    _updateMood();
    save();
  }

  void play() {
    happiness = (happiness + 20).clamp(0, 100);
    energy = (energy - 15).clamp(0, 100);
    hunger = (hunger + 10).clamp(0, 100);
    lastPlayed = DateTime.now();
    lastInteraction = DateTime.now();
    
    // Add emotion based on personality
    if (personality.prefersActivity('play')) {
      addEmotion(EmotionType.playfulness, 0.9, trigger: 'Playing is my favorite!');
    } else if (energy < 30) {
      addEmotion(EmotionType.contentment, 0.5, trigger: 'That was fun, but I\'m getting tired');
    } else {
      addEmotion(EmotionType.joy, 0.7, trigger: 'Had a great time playing!');
    }
    
    _updateMood();
    save();
  }

  void rest() {
    energy = (energy + 30).clamp(0, 100);
    health = (health + 10).clamp(0, 100);
    isAsleep = true;
    lastInteraction = DateTime.now();
    
    // Add emotion based on personality and energy level
    if (personality.prefersActivity('rest')) {
      addEmotion(EmotionType.serenity, 0.8, trigger: 'I love peaceful rest time');
    } else {
      addEmotion(EmotionType.contentment, 0.5, trigger: 'Getting some needed rest');
    }
    
    _updateMood();
    save();
  }

  void wakeUp() {
    isAsleep = false;
    _updateMood();
    save();
  }

  // Task completion rewards
  void rewardForTaskCompletion(int taskPriority) {
    int expGain = 10 + (taskPriority * 5); // Higher priority = more exp
    int happinessGain = 5 + taskPriority;
    int healthGain = 2;

    experience += expGain;
    happiness = (happiness + happinessGain).clamp(0, 100);
    health = (health + healthGain).clamp(0, 100);
    totalTasksCompleted++;

    // Track high priority tasks
    if (taskPriority == 0) {
      highPriorityTasksCompleted++;
    }

    // Add appropriate emotion based on task priority and personality
    EmotionType rewardEmotion;
    double emotionIntensity;
    String trigger;

    if (taskPriority == 0) { // High priority
      rewardEmotion = personality.emotionalTendency(EmotionType.pride) > 0.6 
          ? EmotionType.pride : EmotionType.excitement;
      emotionIntensity = 0.8;
      trigger = 'Completed a high-priority task!';
    } else if (taskPriority == 1) { // Medium priority
      rewardEmotion = EmotionType.joy;
      emotionIntensity = 0.6;
      trigger = 'Finished a task successfully!';
    } else { // Low priority
      rewardEmotion = EmotionType.contentment;
      emotionIntensity = 0.4;
      trigger = 'Made some progress on tasks!';
    }

    addEmotion(rewardEmotion, emotionIntensity, trigger: trigger);

    // Update productivity streak
    updateProductivityStreak(true);

    _checkLevelUp();
    _updateGrowthStage();
    _updateMood();
    lastInteraction = DateTime.now();
    
    // Check for new achievements
    checkForNewAchievements();
    
    save();
  }

  // Neglect penalties (called periodically)
  void applyNeglectPenalties() {
    final hoursSinceLastInteraction = DateTime.now().difference(lastInteraction).inHours;
    
    if (hoursSinceLastInteraction >= 6) {
      happiness = (happiness - (hoursSinceLastInteraction ~/ 6)).clamp(0, 100);
      hunger = (hunger + (hoursSinceLastInteraction ~/ 4)).clamp(0, 100);
      
      if (hoursSinceLastInteraction >= 12) {
        health = (health - (hoursSinceLastInteraction ~/ 12)).clamp(0, 100);
        energy = (energy - (hoursSinceLastInteraction ~/ 8)).clamp(0, 100);
      }
    }

    _updateMood();
    save();
  }

  void _checkLevelUp() {
    while (experience >= experienceToNextLevel) {
      experience -= experienceToNextLevel;
      level++;
      
      // Level up bonuses
      health = (health + 20).clamp(0, 100);
      happiness = (happiness + 15).clamp(0, 100);
      
      // Unlock accessories at certain levels
      _unlockAccessories();
    }
  }

  void _updateGrowthStage() {
    GrowthStage newStage;
    
    if (level >= 50) {
      newStage = GrowthStage.elder;
    } else if (level >= 30) {
      newStage = GrowthStage.adult;
    } else if (level >= 20) {
      newStage = GrowthStage.teen;
    } else if (level >= 10) {
      newStage = GrowthStage.child;
    } else if (level >= 5) {
      newStage = GrowthStage.baby;
    } else {
      newStage = GrowthStage.egg;
    }

    growthStage = newStage.index;
  }

  void _updateMood() {
    if (isAsleep) {
      currentMood = PetMood.sleeping.index;
      return;
    }

    if (health < 30 || happiness < 30) {
      currentMood = PetMood.sad.index;
    } else if (happiness >= 90 && health >= 80) {
      currentMood = PetMood.excited.index;
    } else if (happiness >= 70 && health >= 60) {
      currentMood = PetMood.happy.index;
    } else {
      currentMood = PetMood.neutral.index;
    }
  }

  void _unlockAccessories() {
    final accessories = <String>[];
    
    if (level >= 5 && !unlockedAccessories.contains('hat')) {
      accessories.add('hat');
    }
    if (level >= 10 && !unlockedAccessories.contains('sunglasses')) {
      accessories.add('sunglasses');
    }
    if (level >= 15 && !unlockedAccessories.contains('bow_tie')) {
      accessories.add('bow_tie');
    }
    if (level >= 25 && !unlockedAccessories.contains('crown')) {
      accessories.add('crown');
    }
    if (level >= 40 && !unlockedAccessories.contains('magic_wand')) {
      accessories.add('magic_wand');
    }

    unlockedAccessories.addAll(accessories);
  }

  // Helper method to get pet sprite path
  String get spritePath {
    final petTypeName = petTypeEnum.name;
    final stageName = growthStageEnum.name;
    final moodName = moodEnum.name;
    
    return 'assets/pets/${petTypeName}_${stageName}_$moodName.png';
  }

  // Get status message for the pet
  String get statusMessage {
    if (health < 30) {
      return "I'm feeling sick... please take care of me!";
    } else if (hunger > 80) {
      return "I'm so hungry! Please feed me!";
    } else if (happiness < 30) {
      return "I'm feeling sad... let's play together!";
    } else if (energy < 20) {
      return "I'm so tired... I need to rest.";
    } else if (happiness >= 90) {
      return "I'm so happy! You're the best owner ever!";
    } else {
      return "I'm doing great! Keep completing those tasks!";
    }
  }

  // Check if pet needs immediate attention
  bool get needsAttention {
    return health < 40 || happiness < 40 || hunger > 80 || energy < 20;
  }

  // Emotion management methods
  void addEmotion(EmotionType emotion, double intensity, {String? trigger}) {
    final emotionData = {
      'type': emotion.index,
      'intensity': intensity,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'trigger': trigger,
    };
    
    emotionHistory.add(emotionData.toString());
    
    // Keep only last 20 emotions
    if (emotionHistory.length > 20) {
      emotionHistory.removeAt(0);
    }
    
    // Update current emotion if intensity is higher or emotion is more recent
    if (intensity > emotionalIntensity || 
        (lastEmotionChange != null && DateTime.now().difference(lastEmotionChange!).inMinutes > 30)) {
      currentEmotion = emotion.index;
      emotionalIntensity = intensity;
      lastEmotionChange = DateTime.now();
      
      // Create memory if emotion is significant
      if (intensity > 0.7) {
        addMemory(trigger ?? 'Had a strong emotional moment', emotion, intensity);
      }
    }
    
    save();
  }

  void addMemory(String event, EmotionType emotion, double intensity) {
    final memoryData = {
      'event': event,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'emotion': emotion.index,
      'intensity': intensity,
    };
    
    memoryHistory.add(memoryData.toString());
    
    // Keep only last 50 memories
    if (memoryHistory.length > 50) {
      memoryHistory.removeAt(0);
    }
    
    save();
  }

  // Get recent significant memories
  List<String> getRecentMemories({int limit = 10}) {
    return memoryHistory.reversed.take(limit).toList();
  }

  // Get current emotion description based on personality
  String get emotionalStatus {
    final emotion = currentEmotionEnum;
    final intensity = emotionalIntensity;
    
    switch (emotion) {
      case EmotionType.joy:
        return intensity > 0.8 ? "I'm absolutely thrilled!" : "I'm feeling quite happy!";
      case EmotionType.excitement:
        return "I can barely contain my excitement!";
      case EmotionType.contentment:
        return "I feel peaceful and satisfied.";
      case EmotionType.curiosity:
        return "I'm wondering about so many things!";
      case EmotionType.loneliness:
        return "I've been missing you...";
      case EmotionType.anxiety:
        return "I'm feeling a bit worried lately.";
      case EmotionType.boredom:
        return "Things have been pretty quiet around here.";
      case EmotionType.pride:
        return "I'm so proud of what we've accomplished!";
      case EmotionType.gratitude:
        return "I appreciate everything you do for me!";
      case EmotionType.disappointment:
        return "Things didn't go quite as I hoped...";
      case EmotionType.playfulness:
        return "I'm ready to play and have fun!";
      case EmotionType.serenity:
        return "I feel completely at peace.";
    }
  }

  // Update productivity streak
  void updateProductivityStreak(bool completedTaskToday) {
    if (completedTaskToday) {
      productivityStreak++;
      if (productivityStreak > 0 && productivityStreak % 7 == 0) {
        // Weekly streak milestone
        addEmotion(EmotionType.pride, 0.9, trigger: '$productivityStreak day productivity streak!');
      } else if (productivityStreak >= 3) {
        addEmotion(EmotionType.joy, 0.7, trigger: 'Great productivity streak!');
      }
    } else {
      if (productivityStreak > 5) {
        addEmotion(EmotionType.disappointment, 0.6, trigger: 'Productivity streak broken');
      }
      productivityStreak = 0;
    }
    save();
  }

  // Check and unlock new achievements
  List<String> checkForNewAchievements() {
    // Get unique emotions experienced
    final emotionTypes = <String>{};
    for (final emotionStr in emotionHistory) {
      // This is a simplified approach - in reality you'd parse the JSON
      // For now, we'll just collect available emotion types
      for (final emotion in EmotionType.values) {
        if (emotionStr.contains(emotion.index.toString())) {
          emotionTypes.add(emotion.name);
        }
      }
    }

    final newAchievements = AchievementSystem.checkAchievements(
      totalTasks: totalTasksCompleted,
      highPriorityTasks: highPriorityTasksCompleted,
      productivityStreak: productivityStreak,
      petLevel: level,
      growthStage: growthStageEnum.name,
      hasPet: true,
      daysWithPet: ageInDays,
      unlockedAccessories: unlockedAccessories,
      experiencedEmotions: emotionTypes,
      currentlyUnlocked: unlockedAchievements,
    );

    // Add new achievements
    for (final achievementId in newAchievements) {
      unlockedAchievements.add(achievementId);
      final achievement = AchievementSystem.getAchievementById(achievementId);
      if (achievement != null) {
        totalAchievementPoints += achievement.points;
        addMemory('Unlocked achievement: ${achievement.title}', EmotionType.pride, 0.8);
      }
    }

    if (newAchievements.isNotEmpty) {
      save();
    }

    return newAchievements;
  }

  // Get achievement progress summary
  Map<String, dynamic> getAchievementSummary() {
    final total = AchievementSystem.allAchievements.length;
    final unlocked = unlockedAchievements.length;
    final rarityCounts = AchievementSystem.getRarityCounts(unlockedAchievements);
    
    return {
      'total_achievements': total,
      'unlocked_achievements': unlocked,
      'completion_percentage': (unlocked / total * 100).round(),
      'total_points': totalAchievementPoints,
      'rarity_counts': rarityCounts,
    };
  }

  // Get attention urgency level
  int get attentionUrgency {
    if (health < 20 || happiness < 20 || hunger > 90) return 3; // Critical
    if (health < 40 || happiness < 40 || hunger > 70) return 2; // High
    if (health < 60 || happiness < 60 || hunger > 50 || energy < 30) return 1; // Medium
    return 0; // Good
  }
}