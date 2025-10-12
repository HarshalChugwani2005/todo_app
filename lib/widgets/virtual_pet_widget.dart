import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/virtual_pet_model.dart';
import '../services/virtual_pet_service.dart';

class VirtualPetWidget extends StatefulWidget {
  final bool showStats;
  final bool isCompact;
  final VoidCallback? onTap;

  const VirtualPetWidget({
    super.key,
    this.showStats = true,
    this.isCompact = false,
    this.onTap,
  });

  @override
  State<VirtualPetWidget> createState() => _VirtualPetWidgetState();
}

class _VirtualPetWidgetState extends State<VirtualPetWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start continuous animations
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerBounce() {
    _bounceController.reset();
    _bounceController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VirtualPetService>(
      builder: (context, petService, child) {
        if (!petService.hasPet) {
          return _buildCreatePetPrompt(context);
        }

        final pet = petService.currentPet!;
        return GestureDetector(
          onTap: () {
            _triggerBounce();
            widget.onTap?.call();
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([_bounceAnimation, _pulseAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value + (_bounceAnimation.value * 0.2),
                child: Container(
                  padding: EdgeInsets.all(widget.isCompact ? 8 : 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: _getPetBorderColor(pet),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pet Avatar
                      _buildPetAvatar(pet),
                      const SizedBox(height: 8),
                      
                      // Pet Name and Level
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Level ${pet.level} ${pet.growthStageEnum.name.toUpperCase()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      if (widget.showStats && !widget.isCompact) ...[
                        const SizedBox(height: 12),
                        _buildStatsSection(pet),
                        const SizedBox(height: 8),
                        _buildMoodIndicator(pet),
                      ],
                      
                      if (pet.needsAttention) ...[
                        const SizedBox(height: 8),
                        _buildAttentionAlert(pet),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCreatePetPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pets,
            size: 48,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            'Create Your Pet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap to create a virtual pet that grows with your productivity!',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPetAvatar(VirtualPet pet) {
    return Container(
      width: widget.isCompact ? 60 : 80,
      height: widget.isCompact ? 60 : 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getPetBackgroundColor(pet),
        border: Border.all(
          color: pet.healthColor,
          width: 3,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main pet icon
          Icon(
            _getPetIcon(pet),
            size: widget.isCompact ? 30 : 40,
            color: _getPetIconColor(pet),
          ),
          
          // Accessory overlay
          if (pet.currentAccessory != null)
            Positioned(
              top: 5,
              right: 5,
              child: Icon(
                _getAccessoryIcon(pet.currentAccessory!),
                size: widget.isCompact ? 15 : 20,
                color: Colors.amber,
              ),
            ),
          
          // Sleep indicator
          if (pet.isAsleep)
            Positioned(
              top: 5,
              left: 5,
              child: Icon(
                Icons.bedtime,
                size: widget.isCompact ? 12 : 16,
                color: Colors.blue,
              ),
            ),
          
          // Mood indicator
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getMoodIcon(pet.moodEnum),
                size: widget.isCompact ? 12 : 16,
                color: _getMoodColor(pet.moodEnum),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(VirtualPet pet) {
    return Column(
      children: [
        // Experience bar
        _buildStatBar(
          'XP',
          pet.experienceProgress,
          Colors.purple,
          '${pet.experience}/${pet.experienceToNextLevel}',
        ),
        const SizedBox(height: 4),
        
        // Stats grid
        Row(
          children: [
            Expanded(
              child: _buildMiniStatBar('❤️', pet.health / 100, pet.healthColor),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildMiniStatBar('😊', pet.happiness / 100, pet.happinessColor),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildMiniStatBar('🍽️', (100 - pet.hunger) / 100, pet.hungerColor),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildMiniStatBar('⚡', pet.energy / 100, pet.energyColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBar(String label, double progress, Color color, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 2),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildMiniStatBar(String emoji, double progress, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 2),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 3,
        ),
      ],
    );
  }

  Widget _buildMoodIndicator(VirtualPet pet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getMoodColor(pet.moodEnum).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getMoodColor(pet.moodEnum).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getMoodIcon(pet.moodEnum),
            size: 16,
            color: _getMoodColor(pet.moodEnum),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              pet.statusMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getMoodColor(pet.moodEnum),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttentionAlert(VirtualPet pet) {
    Color alertColor;
    IconData alertIcon;
    String alertText;

    switch (pet.attentionUrgency) {
      case 3:
        alertColor = Colors.red;
        alertIcon = Icons.warning;
        alertText = 'CRITICAL!';
        break;
      case 2:
        alertColor = Colors.orange;
        alertIcon = Icons.error_outline;
        alertText = 'Needs attention!';
        break;
      default:
        alertColor = Colors.yellow[700]!;
        alertIcon = Icons.info_outline;
        alertText = 'Could use care';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: alertColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(alertIcon, size: 16, color: alertColor),
          const SizedBox(width: 4),
          Text(
            alertText,
            style: TextStyle(
              color: alertColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for pet appearance
  Color _getPetBorderColor(VirtualPet pet) {
    if (pet.needsAttention) {
      return pet.attentionUrgency >= 2 ? Colors.red : Colors.orange;
    }
    return Theme.of(context).primaryColor.withOpacity(0.3);
  }

  Color _getPetBackgroundColor(VirtualPet pet) {
    switch (pet.petTypeEnum) {
      case PetType.cat:
        return Colors.orange.withOpacity(0.1);
      case PetType.dog:
        return Colors.brown.withOpacity(0.1);
      case PetType.plant:
        return Colors.green.withOpacity(0.1);
      case PetType.dragon:
        return Colors.purple.withOpacity(0.1);
    }
  }

  IconData _getPetIcon(VirtualPet pet) {
    switch (pet.petTypeEnum) {
      case PetType.cat:
        return Icons.pets;
      case PetType.dog:
        return Icons.pets;
      case PetType.plant:
        return Icons.local_florist;
      case PetType.dragon:
        return Icons.auto_awesome;
    }
  }

  Color _getPetIconColor(VirtualPet pet) {
    switch (pet.petTypeEnum) {
      case PetType.cat:
        return Colors.orange;
      case PetType.dog:
        return Colors.brown;
      case PetType.plant:
        return Colors.green;
      case PetType.dragon:
        return Colors.purple;
    }
  }

  IconData _getMoodIcon(PetMood mood) {
    switch (mood) {
      case PetMood.happy:
        return Icons.sentiment_very_satisfied;
      case PetMood.excited:
        return Icons.star;
      case PetMood.neutral:
        return Icons.sentiment_neutral;
      case PetMood.sad:
        return Icons.sentiment_dissatisfied;
      case PetMood.sleeping:
        return Icons.bedtime;
    }
  }

  Color _getMoodColor(PetMood mood) {
    switch (mood) {
      case PetMood.happy:
        return Colors.green;
      case PetMood.excited:
        return Colors.amber;
      case PetMood.neutral:
        return Colors.grey;
      case PetMood.sad:
        return Colors.blue;
      case PetMood.sleeping:
        return Colors.indigo;
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
}