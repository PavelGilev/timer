import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const TimerApp());
}

class TimerApp extends StatelessWidget {
  const TimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linux Timer Widget',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system, // Respects Linux system theme
      home: const TimerScreen(),
    );
  }
}

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countdown Timer'),
        centerTitle: true,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CountdownTimerWidget(),
        ),
      ),
    );
  }
}

class CountdownTimerWidget extends StatefulWidget {
  const CountdownTimerWidget({super.key});

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;
  int _totalSeconds = 300; // Default 5 minutes
  int _remainingSeconds = 300;
  bool _isRunning = false;

  // Controllers for input fields
  final TextEditingController _minutesController = TextEditingController(text: '5');
  final TextEditingController _secondsController = TextEditingController(text: '0');

  @override
  void dispose() {
    _timer?.cancel();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) return;
    
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _pauseTimer();
          _showTimeUpDialog();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      _remainingSeconds = _totalSeconds;
    });
  }

  void _updateDuration() {
    if (_isRunning) return; // Prevent updating while running
    
    final mins = int.tryParse(_minutesController.text) ?? 0;
    final secs = int.tryParse(_secondsController.text) ?? 0;
    
    setState(() {
      _totalSeconds = (mins * 60) + secs;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time is up!'),
        content: const Text('The countdown has finished.'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (_totalSeconds == 0) return 0.0;
    return (_totalSeconds - _remainingSeconds) / _totalSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final isFinished = _remainingSeconds == 0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Time Input Fields (disabled when running)
            if (!_isRunning && !isFinished)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _minutesController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: 'Min',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _updateDuration(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _secondsController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: 'Sec',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _updateDuration(),
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 32),

            // Timer Display with Circular Progress
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 8,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    color: isFinished ? Colors.red : Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  _formatTime(_remainingSeconds),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()], // Keeps numbers from jumping
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRunning)
                  FilledButton.icon(
                    onPressed: _remainingSeconds > 0 ? _startTimer : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  )
                else
                  FilledButton.icon(
                    onPressed: _pauseTimer,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                
                const SizedBox(width: 16),
                
                FilledButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
