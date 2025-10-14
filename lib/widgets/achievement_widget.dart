import 'package:flutter/material.dart';
import '../models/pet_achievements_model.dart';

class AchievementWidget extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementWidget({
    super.key,
    required this.achievement,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isUnlocked ? 4 : 1,
      color: isUnlocked ? null : Colors.grey[100],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isUnlocked 
                          ? achievement.rarityColor.withValues(alpha: 0.2)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isUnlocked 
                            ? achievement.rarityColor
                            : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      achievement.icon,
                      color: isUnlocked 
                          ? achievement.rarityColor
                          : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? null : Colors.grey[600],
                          ),
                        ),
                        Text(
                          achievement.categoryName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isUnlocked 
                                ? achievement.rarityColor
                                : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnlocked) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: achievement.rarityColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${achievement.points}pts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                achievement.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isUnlocked ? null : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: achievement.rarityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: achievement.rarityColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      achievement.rarityName,
                      style: TextStyle(
                        color: achievement.rarityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isUnlocked && achievement.unlockedAt != null)
                    Text(
                      'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class AchievementProgressWidget extends StatelessWidget {
  final Map<String, dynamic> summary;

  const AchievementProgressWidget({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final totalAchievements = summary['total_achievements'] as int;
    final unlockedAchievements = summary['unlocked_achievements'] as int;
    final completionPercentage = summary['completion_percentage'] as int;
    final totalPoints = summary['total_points'] as int;
    final rarityCounts = summary['rarity_counts'] as Map<AchievementRarity, int>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievement Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Overall progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$unlockedAchievements/$totalAchievements',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: completionPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 4),
            Text(
              '$completionPercentage% Complete',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Total points
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Total Points: $totalPoints',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Rarity breakdown
            Text(
              'Achievements by Rarity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...AchievementRarity.values.map((rarity) {
              final count = rarityCounts[rarity] ?? 0;
              final rarityAchievements = AchievementSystem.allAchievements
                  .where((a) => a.rarity == rarity)
                  .length;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getRarityColor(rarity),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getRarityName(rarity),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '$count/$rarityAchievements',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
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

  String _getRarityName(AchievementRarity rarity) {
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
}