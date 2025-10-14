import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/virtual_pet_model.dart';
import '../models/pet_achievements_model.dart';
import '../services/virtual_pet_service.dart';
import '../widgets/virtual_pet_widget.dart';
import 'achievements_screen.dart';

class VirtualPetScreen extends StatefulWidget {
  const VirtualPetScreen({super.key});

  @override
  State<VirtualPetScreen> createState() => _VirtualPetScreenState();
}

class _VirtualPetScreenState extends State<VirtualPetScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _triggerCelebration() {
    _celebrationController.reset();
    _celebrationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Pet'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer<VirtualPetService>(
            builder: (context, petService, child) {
              if (petService.hasPet) {
                return PopupMenuButton<String>(
                  onSelected: (value) async {
                    switch (value) {
                      case 'delete':
                        _showDeletePetDialog(context, petService);
                        break;
                      case 'rename':
                        _showRenamePetDialog(context, petService);
                        break;
                      case 'stats':
                        _showDetailedStats(context, petService);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'stats',
                      child: ListTile(
                        leading: Icon(Icons.bar_chart),
                        title: Text('Detailed Stats'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'rename',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Rename Pet'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete Pet', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<VirtualPetService>(
        builder: (context, petService, child) {
          if (!petService.hasPet) {
            return _buildCreatePetScreen(context, petService);
          }

          final pet = petService.currentPet!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Main pet display
                AnimatedBuilder(
                  animation: _celebrationAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_celebrationAnimation.value * 0.1),
                      child: VirtualPetWidget(
                        showStats: true,
                        onTap: () => _triggerCelebration(),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Care actions
                _buildCareActions(context, petService, pet),
                
                const SizedBox(height: 24),
                
                // Accessories section
                _buildAccessoriesSection(context, petService, pet),
                
                const SizedBox(height: 24),
                
                // Pet suggestions
                _buildSuggestions(context, petService),
                
                const SizedBox(height: 24),
                
                // Pet history
                _buildPetHistory(context, pet),
                
                const SizedBox(height: 24),
                
                // Achievements section
                _buildAchievementsSection(context, pet),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreatePetScreen(BuildContext context, VirtualPetService petService) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 120,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Create Your Virtual Pet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your virtual pet will grow and evolve based on your productivity! Complete tasks to keep your pet happy and healthy.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCreatePetDialog(context, petService),
              icon: const Icon(Icons.add),
              label: const Text('Create Pet'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareActions(BuildContext context, VirtualPetService petService, VirtualPet pet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pet Care',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildCareButton(
                  context,
                  'Feed',
                  Icons.restaurant,
                  Colors.green,
                  pet.hunger > 30,
                  () {
                    petService.feedPet();
                    _triggerCelebration();
                  },
                ),
                _buildCareButton(
                  context,
                  'Play',
                  Icons.sports_esports,
                  Colors.blue,
                  pet.happiness < 80 && pet.energy > 20,
                  () {
                    petService.playWithPet();
                    _triggerCelebration();
                  },
                ),
                _buildCareButton(
                  context,
                  pet.isAsleep ? 'Wake Up' : 'Sleep',
                  pet.isAsleep ? Icons.wb_sunny : Icons.bedtime,
                  Colors.purple,
                  pet.isAsleep || pet.energy < 50,
                  () {
                    if (pet.isAsleep) {
                      petService.wakePetUp();
                    } else {
                      petService.putPetToSleep();
                    }
                    _triggerCelebration();
                  },
                ),
                _buildCareButton(
                  context,
                  'Refresh',
                  Icons.refresh,
                  Colors.orange,
                  true,
                  () {
                    petService.refresh();
                    _triggerCelebration();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    bool enabled,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color : Colors.grey[300],
        foregroundColor: enabled ? Colors.white : Colors.grey[600],
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  Widget _buildAccessoriesSection(BuildContext context, VirtualPetService petService, VirtualPet pet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accessories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (pet.unlockedAccessories.isEmpty)
              Text(
                'Complete more tasks to unlock accessories!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Remove accessory chip
                  if (pet.currentAccessory != null)
                    ActionChip(
                      label: const Text('None'),
                      avatar: const Icon(Icons.close, size: 18),
                      onPressed: () => petService.removeAccessory(),
                      backgroundColor: pet.currentAccessory == null ? Theme.of(context).primaryColor : null,
                    ),
                  
                  // Accessory chips
                  ...pet.unlockedAccessories.map((accessory) {
                    return ActionChip(
                      label: Text(_getAccessoryName(accessory)),
                      avatar: Icon(_getAccessoryIcon(accessory), size: 18),
                      onPressed: () => petService.equipAccessory(accessory),
                      backgroundColor: pet.currentAccessory == accessory ? Theme.of(context).primaryColor : null,
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, VirtualPetService petService) {
    final suggestions = petService.getPetSuggestions();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pet Tips',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...suggestions.map((suggestion) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildPetHistory(BuildContext context, VirtualPet pet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pet History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildHistoryItem('Age', '${pet.ageInDays} days old'),
            _buildHistoryItem('Tasks Completed', '${pet.totalTasksCompleted}'),
            _buildHistoryItem('High Priority Tasks', '${pet.highPriorityTasksCompleted}'),
            _buildHistoryItem('Productivity Streak', '${pet.productivityStreak} days'),
            _buildHistoryItem('Growth Stage', pet.growthStageEnum.name.toUpperCase()),
            _buildHistoryItem('Pet Type', pet.petTypeEnum.name.toUpperCase()),
            _buildHistoryItem('Personality', pet.personality.description),
            _buildHistoryItem('Current Emotion', pet.emotionalStatus),
            if (pet.lastFed != null)
              _buildHistoryItem('Last Fed', _formatTime(pet.lastFed!)),
            if (pet.lastPlayed != null)
              _buildHistoryItem('Last Played', _formatTime(pet.lastPlayed!)),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context, VirtualPet pet) {
    final summary = pet.getAchievementSummary();
    final recentAchievements = AchievementSystem.getUnlockedAchievements(pet.unlockedAchievements)
        .take(3)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Achievements',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _showAllAchievements(context, pet),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Quick stats
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${summary['unlocked_achievements']}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          'Unlocked',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${summary['total_points']}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                        Text(
                          'Points',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (recentAchievements.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Recent Achievements',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...recentAchievements.map((achievement) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        achievement.icon,
                        size: 20,
                        color: achievement.rarityColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: achievement.rarityColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${achievement.points}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              const SizedBox(height: 16),
              Text(
                'Complete tasks to unlock your first achievement!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _getAccessoryName(String accessory) {
    switch (accessory) {
      case 'hat':
        return 'Hat';
      case 'sunglasses':
        return 'Sunglasses';
      case 'bow_tie':
        return 'Bow Tie';
      case 'crown':
        return 'Crown';
      case 'magic_wand':
        return 'Magic Wand';
      default:
        return accessory;
    }
  }

  IconData _getAccessoryIcon(String accessory) {
    switch (accessory) {
      case 'hat':
        return Icons.checkroom;
      case 'sunglasses':
        return Icons.remove_red_eye;
      case 'bow_tie':
        return Icons.favorite;
      case 'crown':
        return Icons.emoji_events;
      case 'magic_wand':
        return Icons.auto_fix_high;
      default:
        return Icons.star;
    }
  }

  void _showCreatePetDialog(BuildContext context, VirtualPetService petService) {
    final nameController = TextEditingController();
    PetType selectedType = PetType.cat;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Your Pet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Pet Name',
                  hintText: 'Enter a name for your pet',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Choose Pet Type:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: PetType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.name.toUpperCase()),
                    selected: selectedType == type,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => selectedType = type);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  await petService.createPet(
                    name: nameController.text.trim(),
                    petType: selectedType,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    _triggerCelebration();
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeletePetDialog(BuildContext context, VirtualPetService petService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Are you sure you want to delete ${petService.currentPet?.name}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await petService.deletePet();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRenamePetDialog(BuildContext context, VirtualPetService petService) {
    final nameController = TextEditingController(text: petService.currentPet?.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Pet'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'New Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty && petService.currentPet != null) {
                petService.currentPet!.name = nameController.text.trim();
                petService.currentPet!.save();
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDetailedStats(BuildContext context, VirtualPetService petService) {
    final stats = petService.getPetStatistics();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detailed Statistics'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: stats.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key.replaceAll('_', ' ').toUpperCase()),
                    Text(entry.value.toString()),
                  ],
                ),
              );
            }).toList(),
          ),
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

  void _showAllAchievements(BuildContext context, VirtualPet pet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AchievementsScreen(pet: pet),
      ),
    );
  }
}