import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../config/routes.dart';

class WorkoutTimerCard extends StatefulWidget {
  const WorkoutTimerCard({Key? key}) : super(key: key);

  @override
  State<WorkoutTimerCard> createState() => _WorkoutTimerCardState();
}

class _WorkoutTimerCardState extends State<WorkoutTimerCard> with SingleTickerProviderStateMixin {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _displayTime = "00:00:00";
  
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _resetTimer() {
    HapticFeedback.selectionClick();
    _stopwatch.stop();
    _stopwatch.reset();
    _timer?.cancel();
    _animController.stop();
    setState(() {
      _displayTime = "00:00:00";
    });
  }

  void _handleTimer() {
    HapticFeedback.mediumImpact();
    
    if (_stopwatch.isRunning) {
      // STOP Logic
      _stopwatch.stop();
      _timer?.cancel();
      _animController.stop();
      
      int minutes = _stopwatch.elapsed.inMinutes;
      if (_stopwatch.elapsed.inSeconds % 60 > 30) minutes += 1;
      if (minutes == 0 && _stopwatch.elapsed.inSeconds > 10) minutes = 1;

      _stopwatch.reset();
      setState(() {
        _displayTime = "00:00:00";
      });

      // Navigate
      Navigator.pushNamed(
        context, 
        AppRoutes.addActivity, 
        arguments: minutes 
      );

    } else {
      // START Logic
      _stopwatch.start();
      _animController.repeat(reverse: true);
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          // This setState ONLY rebuilds this card, not the whole dashboard!
          setState(() {
            _displayTime = _formatTime(_stopwatch.elapsedMilliseconds);
          });
        }
      });
    }
    setState(() {}); 
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String hoursStr = (minutes / 60).truncate().toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color timerCardColor = _stopwatch.isRunning 
        ? (isDark ? Colors.teal.shade900 : Colors.teal.shade50)
        : (isDark ? Colors.grey.shade800 : Colors.white);
    final Color timerTextColor = _stopwatch.isRunning 
        ? Colors.teal 
        : (isDark ? Colors.white : Colors.black87);

    return ScaleTransition(
      scale: _stopwatch.isRunning ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        decoration: BoxDecoration(
          color: timerCardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _stopwatch.isRunning 
                  ? Colors.teal.withOpacity(0.3) 
                  : Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
          border: Border.all(
            color: _stopwatch.isRunning ? Colors.teal : Colors.grey.shade200,
            width: _stopwatch.isRunning ? 2 : 1
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer, color: timerTextColor),
                const SizedBox(width: 8),
                Text(
                  _stopwatch.isRunning ? "WORKOUT IN PROGRESS" : "QUICK START",
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: timerTextColor.withOpacity(0.8),
                  ),
                ),
                if (_stopwatch.isRunning || _stopwatch.elapsedMilliseconds > 0) ...[
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: _resetTimer,
                    tooltip: "Cancel Timer",
                  )
                ]
              ],
            ),
            const SizedBox(height: 15),
            Text(
              _displayTime,
              style: TextStyle(
                fontSize: 50, 
                fontWeight: FontWeight.w700, 
                fontFamily: 'monospace', 
                color: timerTextColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("HR", style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                  Text("MIN", style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                  Text("SEC", style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                ],
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handleTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _stopwatch.isRunning ? Colors.teal : Colors.black87,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_stopwatch.isRunning ? Icons.check_circle : Icons.play_arrow_rounded, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      _stopwatch.isRunning ? "FINISH & SAVE" : "START ACTIVITY",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}