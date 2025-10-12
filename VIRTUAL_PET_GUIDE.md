# Virtual Pet Feature 🐾

## Overview
The Virtual Pet feature adds a gamification element to your todo app, making productivity fun and engaging! Your virtual pet grows and evolves based on your task completion, creating motivation to stay productive.

## Features

### 🐱 Pet Types
- **Cat**: Friendly and playful companion
- **Dog**: Loyal and energetic buddy  
- **Plant**: Calm and growing companion
- **Dragon**: Magical and powerful creature

### 📊 Pet Stats
- **Health** ❤️: Overall wellbeing (affected by neglect)
- **Happiness** 😊: Mood and contentment (increased by play and task completion)
- **Hunger** 🍽️: Needs feeding (increases over time)
- **Energy** ⚡: Rest and activity levels (depleted by play, restored by sleep)

### 🌱 Growth System
- **Egg** → **Baby** → **Child** → **Teen** → **Adult** → **Elder**
- Pet evolves based on level and experience gained from task completion
- Higher priority tasks give more experience points

### 🎭 Mood System
- **Happy**: All stats are good, pet is content
- **Excited**: Very high happiness and health
- **Neutral**: Average stats, doing okay
- **Sad**: Low happiness or health, needs attention
- **Sleeping**: Pet is resting to restore energy

### 👑 Accessories System
Unlock accessories by reaching certain levels:
- **Level 5**: Hat 🎩
- **Level 10**: Sunglasses 🕶️
- **Level 15**: Bow Tie 🎀
- **Level 25**: Crown 👑
- **Level 40**: Magic Wand ✨

### 🎮 Pet Care Actions
- **Feed**: Reduces hunger, increases happiness and health
- **Play**: Increases happiness but uses energy and increases hunger
- **Sleep**: Restores energy and health
- **Wake Up**: Brings pet out of sleep mode

### 🏆 Task Integration
- **Task Completion**: Rewards pet with experience, happiness, and health
- **Priority Bonus**: Higher priority tasks give bigger rewards
  - High Priority: +15 XP, +7 Happiness, +2 Health
  - Medium Priority: +10 XP, +5 Happiness, +2 Health  
  - Low Priority: +5 XP, +3 Happiness, +2 Health

### 📱 Notifications
- Level up celebrations
- Evolution announcements
- Care reminders when pet needs attention
- Critical alerts when pet's health is low

### 🎯 Attention System
Pet requires attention based on stats:
- **Critical** (Red): Health < 20 or Happiness < 20 or Hunger > 90
- **High** (Orange): Health < 40 or Happiness < 40 or Hunger > 70
- **Medium** (Yellow): Health < 60 or Happiness < 60 or Hunger > 50 or Energy < 30

### 📈 Statistics Tracking
- Total tasks completed
- Pet age in days
- Current level and growth stage
- Unlocked accessories count
- Overall wellbeing score

## How to Use

### Creating Your Pet
1. Navigate to the Pet tab (🐾) in the bottom navigation
2. Tap "Create Pet" 
3. Choose a name and pet type
4. Your pet starts as a baby and grows with your productivity!

### Daily Care
- Check your pet regularly in the Pet tab
- Feed when hungry (hunger bar is orange/red)
- Play when sad (happiness bar is low)
- Let pet sleep when tired (energy bar is low)

### Productivity Rewards
- Complete tasks to earn experience for your pet
- Higher priority tasks = bigger rewards
- Consistent task completion keeps your pet happy and healthy
- Level ups unlock new accessories and growth stages

### Pet Integration in Home Screen
- Your pet appears as a compact widget when it needs attention
- Tap the pet widget to quickly navigate to the pet care screen
- Automatic rewards when you complete tasks

## Tips for Success

1. **Consistent Care**: Check on your pet at least once a day
2. **Balanced Tasks**: Mix high and low priority tasks for steady growth
3. **Regular Feeding**: Don't let hunger get too high
4. **Play Time**: Keep happiness up with regular play sessions
5. **Rest Periods**: Let your pet sleep when energy is low

## Technical Implementation

### Models
- `VirtualPet`: Core pet data model with Hive storage
- Enum support for pet types, moods, and growth stages
- Automatic stat calculations and validation

### Services
- `VirtualPetService`: Manages pet lifecycle and notifications
- Integration with existing notification system
- Automatic neglect penalties and stat updates

### Widgets
- `VirtualPetWidget`: Animated pet display with stats
- `VirtualPetScreen`: Full pet interaction interface
- Responsive design for different screen sizes

### Data Persistence
- Hive database storage for offline support
- Automatic backups with existing data export/import
- Cross-device sync support (when cloud sync is implemented)

Enjoy raising your virtual pet and boosting your productivity! 🚀