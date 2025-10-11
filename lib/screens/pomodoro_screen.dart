import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import '../services/pomodoro_service.dart';
import '../models/todo_model.dart';

class PomodoroScreen extends StatefulWidget {
  final Todo? selectedTask;

  const PomodoroScreen({super.key, this.selectedTask});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  late CountDownController _countDownController;

  @override
  void initState() {
    super.initState();
    _countDownController = CountDownController();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: PomodoroService(),
      child: Consumer<PomodoroService>(
        builder: (context, pomodoroService, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('🍅 Pomodoro Timer'),
              centerTitle: true,
              backgroundColor: pomodoroService.phaseColor,
              foregroundColor: Colors.white,
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Current task display
                  if (widget.selectedTask != null || pomodoroService.currentTaskTitle != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Working on:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.selectedTask?.title ?? pomodoroService.currentTaskTitle ?? '',
                              style: const TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Phase indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: pomodoroService.phaseColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: pomodoroService.phaseColor),
                    ),
                    child: Text(
                      pomodoroService.phaseText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: pomodoroService.phaseColor,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Circular timer
                  Expanded(
                    child: Center(
                      child: CircularCountDownTimer(
                        duration: _getDuration(pomodoroService),
                        initialDuration: _getDuration(pomodoroService) - pomodoroService.timeRemaining,
                        controller: _countDownController,
                        width: 250,
                        height: 250,
                        ringColor: Colors.grey[300]!,
                        ringGradient: null,
                        fillColor: pomodoroService.phaseColor,
                        fillGradient: null,
                        backgroundColor: pomodoroService.phaseColor.withValues(alpha: 0.1),
                        backgroundGradient: null,
                        strokeWidth: 20.0,
                        strokeCap: StrokeCap.round,
                        textStyle: const TextStyle(
                          fontSize: 48.0,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        textFormat: CountdownTextFormat.MM_SS,
                        isReverse: true,
                        isReverseAnimation: true,
                        isTimerTextShown: true,
                        autoStart: false,
                        onStart: () {
                          debugPrint('Countdown Started');
                        },
                        onComplete: () {
                          debugPrint('Countdown Ended');
                        },
                      ),
                    ),
                  ),
                  
                  // Session counter
                  Text(
                    'Sessions completed: ${pomodoroService.completedSessions}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: pomodoroService.isRunning
                            ? () {
                                pomodoroService.pauseTimer();
                                _countDownController.pause();
                              }
                            : () {
                                pomodoroService.startTimer(
                                  taskTitle: widget.selectedTask?.title,
                                );
                                _countDownController.start();
                              },
                        icon: Icon(pomodoroService.isRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(pomodoroService.isRunning ? 'Pause' : 'Start'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pomodoroService.phaseColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                      
                      ElevatedButton.icon(
                        onPressed: () {
                          pomodoroService.stopTimer();
                          _countDownController.reset();
                        },
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                      
                      ElevatedButton.icon(
                        onPressed: pomodoroService.isRunning
                            ? () {
                                pomodoroService.skipPhase();
                                _countDownController.reset();
                              }
                            : null,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Skip'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Reset button
                  TextButton.icon(
                    onPressed: () {
                      pomodoroService.reset();
                      _countDownController.reset();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset All'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  int _getDuration(PomodoroService service) {
    switch (service.currentPhase) {
      case PomodoroPhase.work:
        return PomodoroService.workDuration;
      case PomodoroPhase.shortBreak:
        return PomodoroService.shortBreakDuration;
      case PomodoroPhase.longBreak:
        return PomodoroService.longBreakDuration;
      case PomodoroPhase.stopped:
        return PomodoroService.workDuration;
    }
  }

  @override
  void dispose() {
    // Don't reset the controller as it may already be disposed
    super.dispose();
  }
}