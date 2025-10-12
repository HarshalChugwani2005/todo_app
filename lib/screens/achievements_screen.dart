import 'package:flutter/material.dart';
import '../models/virtual_pet_model.dart';
import '../models/pet_achievements_model.dart';
import '../widgets/achievement_widget.dart';

class AchievementsScreen extends StatefulWidget {
  final VirtualPet pet;

  const AchievementsScreen({
    super.key,
    required this.pet,
  });

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AchievementCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Progress'),
            Tab(text: 'Unlocked'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProgressTab(),
          _buildUnlockedTab(),
          _buildAllAchievementsTab(),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    final summary = widget.pet.getAchievementSummary();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AchievementProgressWidget(summary: summary),
          const SizedBox(height: 24),
          
          // Progress by category
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress by Category',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...AchievementCategory.values.map((category) {
                    final categoryAchievements = AchievementSystem.getAchievementsByCategory(category);
                    final unlockedInCategory = categoryAchievements
                        .where((a) => widget.pet.unlockedAchievements.contains(a.id))
                        .length;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getCategoryName(category),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                '$unlockedInCategory/${categoryAchievements.length}',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: categoryAchievements.isEmpty 
                                ? 0.0 
                                : unlockedInCategory / categoryAchievements.length,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getCategoryColor(category),
                            ),
                            minHeight: 6,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockedTab() {
    final unlockedAchievements = AchievementSystem.getUnlockedAchievements(widget.pet.unlockedAchievements);
    
    if (unlockedAchievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No achievements unlocked yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete tasks and take care of your pet to unlock achievements!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: unlockedAchievements.length,
      itemBuilder: (context, index) {
        final achievement = unlockedAchievements[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AchievementWidget(
            achievement: achievement,
            isUnlocked: true,
            onTap: () => _showAchievementDetails(achievement, true),
          ),
        );
      },
    );
  }

  Widget _buildAllAchievementsTab() {
    return Column(
      children: [
        // Category filter
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All', _selectedCategory == null),
                ...AchievementCategory.values.map((category) {
                  return _buildCategoryChip(
                    _getCategoryName(category),
                    _selectedCategory == category,
                    category: category,
                  );
                }),
              ],
            ),
          ),
        ),
        
        // Achievements list
        Expanded(
          child: Builder(
            builder: (context) {
              final achievements = _selectedCategory == null
                  ? AchievementSystem.allAchievements
                  : AchievementSystem.getAchievementsByCategory(_selectedCategory!);
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  final isUnlocked = widget.pet.unlockedAchievements.contains(achievement.id);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AchievementWidget(
                      achievement: achievement,
                      isUnlocked: isUnlocked,
                      onTap: () => _showAchievementDetails(achievement, isUnlocked),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, {AchievementCategory? category}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        selectedColor: category != null 
            ? _getCategoryColor(category).withOpacity(0.2)
            : Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: category != null 
            ? _getCategoryColor(category)
            : Theme.of(context).primaryColor,
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement, bool isUnlocked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              achievement.icon,
              color: isUnlocked ? achievement.rarityColor : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                achievement.title,
                style: TextStyle(
                  color: isUnlocked ? null : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: TextStyle(
                color: isUnlocked ? null : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: achievement.rarityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: achievement.rarityColor.withOpacity(0.3),
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
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(achievement.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getCategoryColor(achievement.category).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    achievement.categoryName,
                    style: TextStyle(
                      color: _getCategoryColor(achievement.category),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                ),
              ),
              child: Text(
                '${achievement.points} Points',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isUnlocked && achievement.unlockedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Unlocked: ${_formatDateTime(achievement.unlockedAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(AchievementCategory category) {
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

  Color _getCategoryColor(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.productivity:
        return Colors.blue;
      case AchievementCategory.petCare:
        return Colors.pink;
      case AchievementCategory.milestones:
        return Colors.purple;
      case AchievementCategory.social:
        return Colors.green;
      case AchievementCategory.special:
        return Colors.orange;
      case AchievementCategory.seasonal:
        return Colors.teal;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}