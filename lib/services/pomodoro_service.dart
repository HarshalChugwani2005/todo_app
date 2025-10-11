import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/notification_service.dart';

enum PomodoroPhase { work, shortBreak, longBreak, stopped }

class PomodoroService extends ChangeNotifier {
  static final PomodoroService _instance = PomodoroService._internal();
  factory PomodoroService() => _instance;
  PomodoroService._internal();

  // Timer settings (in seconds)
  static const int workDuration = 25 * 60; // 25 minutes
  static const int shortBreakDuration = 5 * 60; // 5 minutes
  static const int longBreakDuration = 15 * 60; // 15 minutes
  static const int longBreakInterval = 4; // After 4 work sessions

  Timer? _timer;
  PomodoroPhase _currentPhase = PomodoroPhase.stopped;
  int _timeRemaining = workDuration;
  int _completedSessions = 0;
  bool _isRunning = false;
  String? _currentTaskTitle;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Getters
  PomodoroPhase get currentPhase => _currentPhase;
  int get timeRemaining => _timeRemaining;
  int get completedSessions => _completedSessions;
  bool get isRunning => _isRunning;
  String? get currentTaskTitle => _currentTaskTitle;
  
  String get phaseText {
    switch (_currentPhase) {
      case PomodoroPhase.work:
        return 'Work Session';
      case PomodoroPhase.shortBreak:
        return 'Short Break';
      case PomodoroPhase.longBreak:
        return 'Long Break';
      case PomodoroPhase.stopped:
        return 'Ready to Start';
    }
  }

  Color get phaseColor {
    switch (_currentPhase) {
      case PomodoroPhase.work:
        return Colors.red;
      case PomodoroPhase.shortBreak:
        return Colors.green;
      case PomodoroPhase.longBreak:
        return Colors.blue;
      case PomodoroPhase.stopped:
        return Colors.grey;
    }
  }

  String get formattedTime {
    final minutes = (_timeRemaining / 60).floor();
    final seconds = _timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void startTimer({String? taskTitle}) {
    _currentTaskTitle = taskTitle;
    _isRunning = true;
    
    if (_currentPhase == PomodoroPhase.stopped) {
      _currentPhase = PomodoroPhase.work;
      _timeRemaining = workDuration;
    }
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeRemaining--;
      notifyListeners();
      
      if (_timeRemaining <= 0) {
        _onTimerComplete();
      }
    });
    
    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    _currentPhase = PomodoroPhase.stopped;
    _timeRemaining = workDuration;
    _currentTaskTitle = null;
    notifyListeners();
  }

  void skipPhase() {
    _timer?.cancel();
    _onTimerComplete();
  }

  void _onTimerComplete() {
    _timer?.cancel();
    _isRunning = false;
    
    // Play completion sound
    _playNotificationSound();
    
    // Show notification
    _showPhaseCompletionNotification();
    
    // Move to next phase
    _moveToNextPhase();
    
    notifyListeners();
  }

  void _moveToNextPhase() {
    switch (_currentPhase) {
      case PomodoroPhase.work:
        _completedSessions++;
        if (_completedSessions % longBreakInterval == 0) {
          _currentPhase = PomodoroPhase.longBreak;
          _timeRemaining = longBreakDuration;
        } else {
          _currentPhase = PomodoroPhase.shortBreak;
          _timeRemaining = shortBreakDuration;
        }
        break;
      case PomodoroPhase.shortBreak:
      case PomodoroPhase.longBreak:
        _currentPhase = PomodoroPhase.work;
        _timeRemaining = workDuration;
        break;
      case PomodoroPhase.stopped:
        // This shouldn't happen
        break;
    }
  }

  void _playNotificationSound() async {
    try {
      // You can add a sound file to assets and play it here
      // await _audioPlayer.play(AssetSource('sounds/timer_complete.mp3'));
    } catch (e) {
      debugPrint('Could not play notification sound: $e');
    }
  }

  void _showPhaseCompletionNotification() {
    String title = '';
    String body = '';
    
    switch (_currentPhase) {
      case PomodoroPhase.work:
        title = 'Work Session Complete!';
        body = 'Time for a break. You completed session #$_completedSessions';
        break;
      case PomodoroPhase.shortBreak:
        title = 'Break Complete!';
        body = 'Time to get back to work!';
        break;
      case PomodoroPhase.longBreak:
        title = 'Long Break Complete!';
        body = 'Ready for another focused work session?';
        break;
      case PomodoroPhase.stopped:
        break;
    }
    
    if (title.isNotEmpty) {
      NotificationService().showInstantNotification(
        id: 999,
        title: title,
        body: body,
      );
    }
  }

  void reset() {
    stopTimer();
    _completedSessions = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}