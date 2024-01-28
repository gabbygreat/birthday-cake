import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      home: const NoiseMeterApp(),
    );
  }
}

class NoiseMeterApp extends StatefulWidget {
  const NoiseMeterApp({super.key});

  @override
  State<NoiseMeterApp> createState() => _NoiseMeterAppState();
}

class _NoiseMeterAppState extends State<NoiseMeterApp>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? noiseMeter;

  late AnimationController _controller;

  @override
  initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    // start();
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void onData(NoiseReading noiseReading) =>
      setState(() => _latestReading = noiseReading);

  void onError(Object error) {
    stop();
  }

  /// Check if microphone permission is granted.
  Future<bool> checkPermission() async => await Permission.microphone.isGranted;

  /// Request the microphone permission.
  Future<void> requestPermission() async =>
      await Permission.microphone.request();

  /// Start noise sampling.
  Future<void> start() async {
    noiseMeter ??= NoiseMeter();

    if (!(await checkPermission())) await requestPermission();

    _noiseSubscription = noiseMeter?.noise.listen(onData, onError: onError);
    setState(() => _isRecording = true);
  }

  /// Stop sampling.
  void stop() {
    _noiseSubscription?.cancel();
    setState(() => _isRecording = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Birthday Cake",
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) {
                      return CustomPaint(
                        size: const Size(10, 60),
                        painter: CandlePainter(
                          animationValue: _controller.value * 0.9,
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) {
                      return CustomPaint(
                        size: const Size(10, 60),
                        painter: CandlePainter(
                          animationValue: _controller.value * 1.2,
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) {
                      return CustomPaint(
                        size: const Size(10, 60),
                        painter: CandlePainter(
                          animationValue: _controller.value,
                        ),
                      );
                    },
                  ),
                  // CustomPaint(
                  //   size: const Size(10, 60),
                  //   painter: CandlePainter(),
                  // ),
                  // CustomPaint(
                  //   size: const Size(10, 60),
                  //   painter: CandlePainter(),
                  // ),
                  // CustomPaint(
                  //   size: const Size(40, 40),
                  //   painter: CandleFlamePainter(),
                  // ),
                  // CustomPaint(
                  //   size: const Size(40, 40),
                  //   painter: CandleFlamePainter(),
                  // ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              width: 200,
              child: CustomPaint(
                painter: SecondCakeLayer(),
              ),
            ),
            SizedBox(
              height: 130,
              width: 300,
              child: CustomPaint(
                painter: SecondCakeLayer(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isRecording ? Colors.red : Colors.green,
        onPressed: _isRecording ? stop : start,
        child: _isRecording ? const Icon(Icons.stop) : const Icon(Icons.mic),
      ),
    );
  }
}

class SecondCakeLayer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double offset = 20;
    const int width = 20;
    var pinkPaint = Paint()..color = const Color.fromRGBO(251, 124, 162, 1);
    var creamPaint = Paint()..color = const Color.fromRGBO(254, 228, 193, 1);

    var pinkPath = Path();
    var creamPath = Path();

    pinkPath.moveTo(0, offset);
    pinkPath.lineTo(0, size.height / 2);
    double x = 0.0;

    for (int i = 0; i <= size.width / (width + 1); i++) {
      x += width;
      if (i.isEven) {
        pinkPath.lineTo(x, (size.height / 2) - width);
      } else {
        pinkPath.lineTo(x, (size.height / 2));
      }
    }

    pinkPath.lineTo(size.width, offset);
    pinkPath.quadraticBezierTo(size.width, 0, size.width - offset, 0);
    pinkPath.lineTo(offset, 0);
    pinkPath.quadraticBezierTo(0, 0, 0, offset);

    // For the Cream Color layer
    creamPath.moveTo(0, offset);
    creamPath.lineTo(0, size.height);
    creamPath.lineTo(size.width, size.height);
    creamPath.lineTo(size.width, offset);
    creamPath.quadraticBezierTo(size.width, 0, size.width - offset, 0);
    creamPath.lineTo(offset, 0);
    creamPath.quadraticBezierTo(0, 0, 0, offset);

    canvas.drawPath(creamPath, creamPaint);
    canvas.drawPath(pinkPath, pinkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CandlePainter extends CustomPainter {
  final double animationValue;

  CandlePainter({required this.animationValue});
  @override
  void paint(Canvas canvas, Size size) {
    var flameHeight = size.height * 0.4;
    var flameWidth = size.width * 0.5;
    var windEffect = math.sin(animationValue * 2 * math.pi) * 10;

    var paint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.fill;
    var innerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    var candleStickPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    var path = Path();
    var innerPath = Path();
    var candleStickPath = Path();

    // The flame with wind effect
    path.moveTo(flameWidth, flameHeight);
    path.quadraticBezierTo(
      -flameWidth + windEffect,
      flameHeight * 0.1,
      flameWidth * 0.2,
      flameHeight * 0.1,
    );
    path.quadraticBezierTo(
      flameWidth + windEffect,
      flameHeight * 0.2 + windEffect,
      flameWidth,
      flameHeight,
    );

    // The flame
    innerPath.moveTo(flameWidth, flameHeight);
    innerPath.quadraticBezierTo(
      -flameWidth + windEffect,
      flameHeight * 0.1,
      flameWidth * 0.4,
      flameHeight * 0.1,
    );
    innerPath.quadraticBezierTo(
      flameWidth + windEffect,
      flameHeight * 0.2 - windEffect,
      flameWidth,
      flameHeight,
    );

    // The Stick
    candleStickPath.moveTo(0, flameHeight);
    candleStickPath.lineTo(0, size.height);
    candleStickPath.lineTo(size.width, size.height);
    candleStickPath.lineTo(size.width, flameHeight);
    candleStickPath.close();

    // Draw the flame
    canvas.drawPath(path, paint);
    // Draw the inner flame
    canvas.drawPath(innerPath, innerPaint);
    // Draw the candle stick
    canvas.drawPath(candleStickPath, candleStickPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
