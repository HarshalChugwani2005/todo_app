import 'package:flutter/material.dart';

enum AchievementCategory {
  productivity,
  petCare,
  milestones,
  social,
  special,
  seasonal
}

enum AchievementRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final DateTime? unlockedAt;
  final Map<String, dynamic> metadata;
  final List<String> requirements;
  final int points;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.rarity,
    this.unlockedAt,
    this.metadata = const {},
    this.requirements = const [],
    required this.points,
  });

  bool get isUnlocked => unlockedAt != null;

  Color get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.uncommon:
        return Colors.green;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.amber;
    }
  }

  String get rarityName {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.uncommon:
        return 'Uncommon';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }

  String get categoryName {
    switch (category) {
      case AchievementCategory.productivity:
        return 'Productivity';
      case AchievementCategory.petCare:
        return 'Pet Care';
      case AchievementCategory.milestones:
        return 'Milestones';
      case AchievementCategory.social:
        return 'Social';
      case AchievementCategory.special:
        return 'Special';
      case AchievementCategory.seasonal:
        return 'Seasonal';
    }
  }
}

class AchievementSystem {
  static final List<Achievement> _allAchievements = [
    // Productivity Achievements
    Achievement(
      id: 'first_task',
      title: 'Getting Started',
      description: 'Complete your first task',
      icon: Icons.task_alt,
      category: AchievementCategory.productivity,
      rarity: AchievementRarity.common,
      points: 10,
    ),
    Achievement(
      id: 'task_streak_7',
      title: 'Week Warrior',
      description: 'Complete tasks for 7 consecutive days',
      icon: Icons.local_fire_department,
      category: AchievementCategory.productivity,
      rarity: AchievementRarity.uncommon,
      points: 50,
    ),
    Achievement(
      id: 'task_streak_30',
      title: 'Consistency Champion',
      description: 'Complete tasks for 30 consecutive days',
      icon: Icons.emoji_events,
      category: AchievementCategory.productivity,
      rarity: AchievementRarity.rare,
      points: 200,
    ),
    Achievement(
      id: 'high_priority_master',
      title: 'Priority Master',
      description: 'Complete 50 high-priority tasks',
      icon: Icons.priority_high,
      category: AchievementCategory.productivity,
      rarity: AchievementRarity.uncommon,
      points: 75,
    ),
    Achievement(
      id: 'task_completionist',
      title: 'Task Completionist',
      description: 'Complete 1000 tasks total',
      icon: Icons.star,
      category: AchievementCategory.productivity,
      rarity: AchievementRarity.epic,
      points: 500,
    ),

    // Pet Care Achievements
    Achievement(
      id: 'first_pet',
      title: 'Pet Parent',
      description: 'Create your first virtual pet',
      icon: Icons.pets,
      category: AchievementCategory.petCare,
      rarity: AchievementRarity.common,
      points: 20,
    ),
    Achievement(
      id: 'pet_care_week',
      title: 'Caring Companion',
      description: 'Take care of your pet every day for a week',
      icon: Icons.favorite,
      category: AchievementCategory.petCare,
      rarity: AchievementRarity.uncommon,
      points: 60,
    ),
    Achievement(
      id: 'pet_happiness_master',
      title: 'Happiness Guru',
      description: 'Keep your pet\'s happiness above 90 for 5 days',
      icon: Icons.sentiment_very_satisfied,
      category: AchievementCategory.petCare,
      rarity: AchievementRarity.rare,
      points: 100,
    ),
    Achievement(
      id: 'perfect_pet_care',
      title: 'Perfect Caretaker',
      description: 'Keep all pet stats above 80 for 7 days',
      icon: Icons.health_and_safety,
      category: AchievementCategory.petCare,
      rarity: AchievementRarity.epic,
      points: 300,
    ),

    // Milestone Achievements
    Achievement(
      id: 'pet_level_10',
      title: 'Growing Up',
      description: 'Reach level 10 with your pet',
      icon: Icons.trending_up,
      category: AchievementCategory.milestones,
      rarity: AchievementRarity.uncommon,
      points: 40,
    ),
    Achievement(
      id: 'pet_level_25',
      title: 'Experienced Companion',
      description: 'Reach level 25 with your pet',
      icon: Icons.military_tech,
      category: AchievementCategory.milestones,
      rarity: AchievementRarity.rare,
      points: 100,
    ),
    Achievement(
      id: 'pet_level_50',
      title: 'Master Level',
      description: 'Reach level 50 with your pet',
      icon: Icons.workspace_premium,
      category: AchievementCategory.milestones,
      rarity: AchievementRarity.epic,
      points: 250,
    ),
    Achievement(
      id: 'pet_elder',
      title: 'Ancient Wisdom',
      description: 'Evolve your pet to Elder stage',
      icon: Icons.auto_awesome,
      category: AchievementCategory.milestones,
      rarity: AchievementRarity.legendary,
      points: 1000,
    ),

    // Special Achievements
    Achievement(
      id: 'midnight_warrior',
      title: 'Midnight Warrior',
      description: 'Complete a task between 12 AM and 6 AM',
      icon: Icons.nightlight,
      category: AchievementCategory.special,
      rarity: AchievementRarity.uncommon,
      points: 30,
    ),
    Achievement(
      id: 'weekend_grind',
      title: 'Weekend Grinder',
      description: 'Complete 10 tasks on a weekend',
      icon: Icons.weekend,
      category: AchievementCategory.special,
      rarity: AchievementRarity.rare,
      points: 80,
    ),
    Achievement(
      id: 'emotion_master',
      title: 'Emotion Master',
      description: 'Experience all 12 emotion types with your pet',
      icon: Icons.psychology,
      category: AchievementCategory.special,
      rarity: AchievementRarity.epic,
      points: 200,
    ),
    Achievement(
      id: 'accessory_collector',
      title: 'Accessory Collector',
      description: 'Unlock all pet accessories',
      icon: Icons.collections,
      category: AchievementCategory.special,
      rarity: AchievementRarity.rare,
      points: 150,
    ),

    // Seasonal Achievements (can be expanded)
    Achievement(
      id: 'new_year_resolution',
      title: 'New Year, New Me',
      description: 'Complete 5 tasks on New Year\'s Day',
      icon: Icons.celebration,
      category: AchievementCategory.seasonal,
      rarity: AchievementRarity.rare,
      points: 100,
    ),
  ];

  static List<Achievement> get allAchievements => _allAchievements;

  static List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return _allAchievements.where((a) => a.category == category).toList();
  }

  static List<Achievement> getUnlockedAchievements(List<String> unlockedIds) {
    return _allAchievements.where((a) => unlockedIds.contains(a.id)).toList();
  }

  static List<Achievement> getLockedAchievements(List<String> unlockedIds) {
    return _allAchievements.where((a) => !unlockedIds.contains(a.id)).toList();
  }

  static Achievement? getAchievementById(String id) {
    try {
      return _allAchievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // Check if conditions are met for specific achievements
  static List<String> checkAchievements({
    required int totalTasks,
    required int highPriorityTasks,
    required int productivityStreak,
    required int petLevel,
    required String growthStage,
    required bool hasPet,
    required int daysWithPet,
    required List<String> unlockedAccessories,
    required Set<String> experiencedEmotions,
    required List<String> currentlyUnlocked,
  }) {
    final newUnlocked = <String>[];

    // Productivity achievements
    if (totalTasks >= 1 && !currentlyUnlocked.contains('first_task')) {
      newUnlocked.add('first_task');
    }
    if (productivityStreak >= 7 && !currentlyUnlocked.contains('task_streak_7')) {
      newUnlocked.add('task_streak_7');
    }
    if (productivityStreak >= 30 && !currentlyUnlocked.contains('task_streak_30')) {
      newUnlocked.add('task_streak_30');
    }
    if (highPriorityTasks >= 50 && !currentlyUnlocked.contains('high_priority_master')) {
      newUnlocked.add('high_priority_master');
    }
    if (totalTasks >= 1000 && !currentlyUnlocked.contains('task_completionist')) {
      newUnlocked.add('task_completionist');
    }

    // Pet care achievements
    if (hasPet && !currentlyUnlocked.contains('first_pet')) {
      newUnlocked.add('first_pet');
    }

    // Milestone achievements
    if (petLevel >= 10 && !currentlyUnlocked.contains('pet_level_10')) {
      newUnlocked.add('pet_level_10');
    }
    if (petLevel >= 25 && !currentlyUnlocked.contains('pet_level_25')) {
      newUnlocked.add('pet_level_25');
    }
    if (petLevel >= 50 && !currentlyUnlocked.contains('pet_level_50')) {
      newUnlocked.add('pet_level_50');
    }
    if (growthStage == 'elder' && !currentlyUnlocked.contains('pet_elder')) {
      newUnlocked.add('pet_elder');
    }

    // Special achievements
    if (experiencedEmotions.length >= 12 && !currentlyUnlocked.contains('emotion_master')) {
      newUnlocked.add('emotion_master');
    }
    if (unlockedAccessories.length >= 5 && !currentlyUnlocked.contains('accessory_collector')) {
      newUnlocked.add('accessory_collector');
    }

    return newUnlocked;
  }

  static int getTotalPoints(List<String> unlockedIds) {
    return getUnlockedAchievements(unlockedIds)
        .fold(0, (sum, achievement) => sum + achievement.points);
  }

  static Map<AchievementRarity, int> getRarityCounts(List<String> unlockedIds) {
    final counts = <AchievementRarity, int>{};
    for (final rarity in AchievementRarity.values) {
      counts[rarity] = 0;
    }

    for (final achievement in getUnlockedAchievements(unlockedIds)) {
      counts[achievement.rarity] = (counts[achievement.rarity] ?? 0) + 1;
    }

    return counts;
  }
}