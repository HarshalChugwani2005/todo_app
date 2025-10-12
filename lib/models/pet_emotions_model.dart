import 'package:flutter/material.dart';

enum EmotionType {
  joy,
  excitement,
  contentment,
  curiosity,
  loneliness,
  anxiety,
  boredom,
  pride,
  gratitude,
  disappointment,
  playfulness,
  serenity
}

enum PersonalityTrait {
  energetic,
  calm,
  social,
  independent,
  curious,
  lazy,
  loyal,
  mischievous,
  sensitive,
  brave
}

class PetEmotion {
  final EmotionType type;
  final double intensity; // 0.0 to 1.0
  final DateTime timestamp;
  final String? trigger; // What caused this emotion
  
  PetEmotion({
    required this.type,
    required this.intensity,
    DateTime? timestamp,
    this.trigger,
  }) : timestamp = timestamp ?? DateTime.now();

  // Get emotion description
  String get description {
    final intensityDesc = intensity > 0.8 ? 'very' : intensity > 0.5 ? 'quite' : 'a bit';
    return '$intensityDesc ${type.name}';
  }

  // Get emotion color
  Color get color {
    switch (type) {
      case EmotionType.joy:
      case EmotionType.excitement:
        return Colors.yellow;
      case EmotionType.contentment:
      case EmotionType.serenity:
        return Colors.green;
      case EmotionType.curiosity:
      case EmotionType.playfulness:
        return Colors.blue;
      case EmotionType.loneliness:
      case EmotionType.anxiety:
        return Colors.purple;
      case EmotionType.boredom:
        return Colors.grey;
      case EmotionType.pride:
      case EmotionType.gratitude:
        return Colors.orange;
      case EmotionType.disappointment:
        return Colors.red;
    }
  }

  // Get emotion icon
  IconData get icon {
    switch (type) {
      case EmotionType.joy:
        return Icons.sentiment_very_satisfied;
      case EmotionType.excitement:
        return Icons.star_border;
      case EmotionType.contentment:
        return Icons.sentiment_satisfied;
      case EmotionType.curiosity:
        return Icons.help_outline;
      case EmotionType.loneliness:
        return Icons.sentiment_neutral;
      case EmotionType.anxiety:
        return Icons.sentiment_dissatisfied;
      case EmotionType.boredom:
        return Icons.sentiment_dissatisfied;
      case EmotionType.pride:
        return Icons.emoji_events;
      case EmotionType.gratitude:
        return Icons.favorite;
      case EmotionType.disappointment:
        return Icons.sentiment_very_dissatisfied;
      case EmotionType.playfulness:
        return Icons.sports_esports;
      case EmotionType.serenity:
        return Icons.spa;
    }
  }

  // Get emotion message
  String get message {
    switch (type) {
      case EmotionType.joy:
        return "I'm feeling so happy right now! 😊";
      case EmotionType.excitement:
        return "This is amazing! I can't contain my excitement! ⭐";
      case EmotionType.contentment:
        return "I feel peaceful and content. Life is good! 😌";
      case EmotionType.curiosity:
        return "I wonder what we'll discover today? 🤔";
      case EmotionType.loneliness:
        return "I miss spending time with you... 😔";
      case EmotionType.anxiety:
        return "I'm feeling a bit worried. Can you comfort me? 😰";
      case EmotionType.boredom:
        return "I'm so bored... Let's do something fun! 😑";
      case EmotionType.pride:
        return "Look how much we've accomplished together! 🏆";
      case EmotionType.gratitude:
        return "Thank you for taking such good care of me! ❤️";
      case EmotionType.disappointment:
        return "I was hoping for something different... 😞";
      case EmotionType.playfulness:
        return "Let's play! I'm full of energy! 🎮";
      case EmotionType.serenity:
        return "I feel so calm and peaceful right now... 🧘";
    }
  }
}

class PetPersonality {
  final PersonalityTrait primaryTrait;
  final PersonalityTrait secondaryTrait;
  final Map<String, double> preferences; // Activity preferences 0.0-1.0
  final Map<EmotionType, double> emotionalTendencies; // How likely to feel each emotion
  
  PetPersonality({
    required this.primaryTrait,
    required this.secondaryTrait,
    Map<String, double>? preferences,
    Map<EmotionType, double>? emotionalTendencies,
  }) : preferences = preferences ?? _getDefaultPreferences(primaryTrait),
       emotionalTendencies = emotionalTendencies ?? _getDefaultEmotionalTendencies(primaryTrait);

  static Map<String, double> _getDefaultPreferences(PersonalityTrait trait) {
    switch (trait) {
      case PersonalityTrait.energetic:
        return {'play': 0.9, 'exercise': 0.8, 'rest': 0.2, 'food': 0.7};
      case PersonalityTrait.calm:
        return {'play': 0.3, 'exercise': 0.4, 'rest': 0.9, 'food': 0.6};
      case PersonalityTrait.social:
        return {'play': 0.8, 'exercise': 0.6, 'rest': 0.5, 'food': 0.7};
      case PersonalityTrait.independent:
        return {'play': 0.4, 'exercise': 0.7, 'rest': 0.6, 'food': 0.5};
      case PersonalityTrait.curious:
        return {'play': 0.7, 'exercise': 0.6, 'rest': 0.4, 'food': 0.6};
      case PersonalityTrait.lazy:
        return {'play': 0.2, 'exercise': 0.1, 'rest': 0.9, 'food': 0.8};
      case PersonalityTrait.loyal:
        return {'play': 0.6, 'exercise': 0.5, 'rest': 0.6, 'food': 0.6};
      case PersonalityTrait.mischievous:
        return {'play': 0.9, 'exercise': 0.7, 'rest': 0.3, 'food': 0.5};
      case PersonalityTrait.sensitive:
        return {'play': 0.5, 'exercise': 0.4, 'rest': 0.7, 'food': 0.6};
      case PersonalityTrait.brave:
        return {'play': 0.7, 'exercise': 0.8, 'rest': 0.4, 'food': 0.6};
    }
  }

  static Map<EmotionType, double> _getDefaultEmotionalTendencies(PersonalityTrait trait) {
    switch (trait) {
      case PersonalityTrait.energetic:
        return {
          EmotionType.excitement: 0.8,
          EmotionType.playfulness: 0.9,
          EmotionType.joy: 0.7,
          EmotionType.boredom: 0.3,
        };
      case PersonalityTrait.calm:
        return {
          EmotionType.serenity: 0.9,
          EmotionType.contentment: 0.8,
          EmotionType.anxiety: 0.2,
          EmotionType.excitement: 0.3,
        };
      case PersonalityTrait.social:
        return {
          EmotionType.joy: 0.8,
          EmotionType.loneliness: 0.7,
          EmotionType.gratitude: 0.8,
          EmotionType.playfulness: 0.7,
        };
      case PersonalityTrait.independent:
        return {
          EmotionType.contentment: 0.7,
          EmotionType.pride: 0.8,
          EmotionType.loneliness: 0.3,
          EmotionType.anxiety: 0.4,
        };
      case PersonalityTrait.curious:
        return {
          EmotionType.curiosity: 0.9,
          EmotionType.excitement: 0.7,
          EmotionType.boredom: 0.6,
          EmotionType.joy: 0.6,
        };
      case PersonalityTrait.lazy:
        return {
          EmotionType.contentment: 0.8,
          EmotionType.serenity: 0.7,
          EmotionType.boredom: 0.4,
          EmotionType.excitement: 0.2,
        };
      case PersonalityTrait.loyal:
        return {
          EmotionType.gratitude: 0.9,
          EmotionType.joy: 0.7,
          EmotionType.loneliness: 0.6,
          EmotionType.pride: 0.6,
        };
      case PersonalityTrait.mischievous:
        return {
          EmotionType.playfulness: 0.9,
          EmotionType.excitement: 0.8,
          EmotionType.curiosity: 0.7,
          EmotionType.boredom: 0.5,
        };
      case PersonalityTrait.sensitive:
        return {
          EmotionType.anxiety: 0.7,
          EmotionType.gratitude: 0.8,
          EmotionType.disappointment: 0.6,
          EmotionType.joy: 0.6,
        };
      case PersonalityTrait.brave:
        return {
          EmotionType.pride: 0.8,
          EmotionType.excitement: 0.7,
          EmotionType.anxiety: 0.2,
          EmotionType.contentment: 0.6,
        };
    }
  }

  String get description {
    return '${primaryTrait.name.toUpperCase()} & ${secondaryTrait.name.toUpperCase()}';
  }

  String get detailedDescription {
    return '${_getTraitDescription(primaryTrait)} ${_getTraitDescription(secondaryTrait)}';
  }

  String _getTraitDescription(PersonalityTrait trait) {
    switch (trait) {
      case PersonalityTrait.energetic:
        return 'Full of energy and always ready for action!';
      case PersonalityTrait.calm:
        return 'Peaceful and serene, enjoys quiet moments.';
      case PersonalityTrait.social:
        return 'Loves spending time with you and being social.';
      case PersonalityTrait.independent:
        return 'Self-reliant and enjoys some alone time.';
      case PersonalityTrait.curious:
        return 'Always wondering and exploring new things.';
      case PersonalityTrait.lazy:
        return 'Prefers relaxation over high-energy activities.';
      case PersonalityTrait.loyal:
        return 'Devoted and faithful companion.';
      case PersonalityTrait.mischievous:
        return 'Playful troublemaker who loves fun and games.';
      case PersonalityTrait.sensitive:
        return 'Emotionally aware and responsive to your mood.';
      case PersonalityTrait.brave:
        return 'Courageous and confident in facing challenges.';
    }
  }

  // Check if pet would prefer this activity based on personality
  bool prefersActivity(String activity) {
    return (preferences[activity] ?? 0.5) > 0.6;
  }

  // Get how likely pet is to feel this emotion (0.0-1.0)
  double emotionalTendency(EmotionType emotion) {
    return emotionalTendencies[emotion] ?? 0.5;
  }
}

class PetMemory {
  final String event;
  final DateTime timestamp;
  final EmotionType associatedEmotion;
  final double emotionalIntensity;
  final Map<String, dynamic> metadata;

  PetMemory({
    required this.event,
    required this.timestamp,
    required this.associatedEmotion,
    required this.emotionalIntensity,
    this.metadata = const {},
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  bool get isSignificant => emotionalIntensity > 0.7;
  
  Color get emotionColor => PetEmotion(type: associatedEmotion, intensity: emotionalIntensity).color;
}