import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

part 'speed_meter.dart';
part 'rpm_meter.dart';
part 'gg_plot_test.dart';
part 'throttle_position.dart';

const _kToDegree = 180.0 / math.pi;
const _kToRadian = math.pi / 180.0;

///
/// This variable is for G-G Plot
/// Simply it's the max distance between every generated point
/// There's a chance that a point switches its location with a distance more than 0.2 pixel (small chance) as this model is not 100% accurate but
/// that's fine for showing GUI capabilities only
///
/// The implemented model doesn't generate accurate data all the time so of course real-world data for the plot may act in different manner
/// Check line 77 for `_generateGGOffset` function (my approximate model)
///
const _kMaxNextPointDisplacement = 0.2;

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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final math.Random _random;

  ///
  /// This function will generate dummy data to show GUI capabilities.
  /// This function generates a number between 0..1 then the generated number is multiplied by max speed, RPM etc... to get current speed of sensor.
  ///
  double _generateDummyData() {
    return _random.nextDouble();
  }

  Timer? _timer;

  ///
  /// This queue will holds 10 offsets of values
  ///
  final Queue<Offset> _ggQueue = Queue<Offset>();

  ///
  /// This function simulates read G-G Plot
  ///
  void _generateGGOffset() {
    ///
    /// First we fill our queue with a dummy data
    ///
    for (int i = 0; i < 10; i++) {
      _ggQueue.add(const Offset(0.0, 0.0));
    }

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final xRangeMin =
          ((_ggQueue.last.dx - _kMaxNextPointDisplacement) <= 1.0 &&
                  (_ggQueue.last.dx - _kMaxNextPointDisplacement) >= -1.0)
              ? (_ggQueue.last.dx - _kMaxNextPointDisplacement)
              : (_ggQueue.last.dx - _kMaxNextPointDisplacement) % 1.0;
      final xRangeMax =
          ((_ggQueue.last.dx + _kMaxNextPointDisplacement) <= 1.0 &&
                  (_ggQueue.last.dx + _kMaxNextPointDisplacement) >= -1.0)
              ? (_ggQueue.last.dx + _kMaxNextPointDisplacement)
              : (_ggQueue.last.dx + _kMaxNextPointDisplacement) % 1.0;

      final xSmallRange =
          xRangeMin + _random.nextDouble() * (xRangeMax - xRangeMin);

      final yRangeMin =
          ((_ggQueue.last.dy - _kMaxNextPointDisplacement) <= 1.0 &&
                  (_ggQueue.last.dy - _kMaxNextPointDisplacement) >= -1.0)
              ? (_ggQueue.last.dy - _kMaxNextPointDisplacement)
              : (_ggQueue.last.dy - _kMaxNextPointDisplacement) % 1.0;
      final yRangeMax =
          ((_ggQueue.last.dy + _kMaxNextPointDisplacement) <= 1.0 &&
                  (_ggQueue.last.dy + _kMaxNextPointDisplacement) >= -1.0)
              ? (_ggQueue.last.dy + _kMaxNextPointDisplacement)
              : (_ggQueue.last.dy + _kMaxNextPointDisplacement) % 1.0;

      final ySmallRange =
          yRangeMin + _random.nextDouble() * (yRangeMax - yRangeMin);

      ///
      /// After we generated a new offset we add it and remove the first one so that we keep number of points constant (equal 10)
      ///
      _ggQueue.add(Offset(xSmallRange, ySmallRange));
      _ggQueue.removeFirst();
    });
  }

  @override
  void initState() {
    super.initState();
    _random = math.Random();
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _controller
      ..addListener(_animationChanged)
      ..addStatusListener(_animationStatusChanged);
    _controller.animateTo(
      _generateDummyData(),
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
    _generateGGOffset();
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.removeStatusListener((status) {});
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _animationChanged() {
    setState(() {
      // The animation controller's state is our build state, and it changed already.
    });
  }

  void _animationStatusChanged(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.forward:
        break;
      case AnimationStatus.reverse:
        break;
      case AnimationStatus.dismissed:
        break;
      case AnimationStatus.completed:
        _controller.animateTo(
          _generateDummyData(),
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    isComplex: true,
                    willChange: true,
                    painter: SpeedView(
                      value: _controller.value,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          isComplex: true,
                          willChange: true,
                          painter: GGView(
                            ggQueue: _ggQueue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          isComplex: true,
                          willChange: true,
                          painter: ThrottlePositionView(
                            value: _controller.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    isComplex: true,
                    willChange: true,
                    painter: RPMView(
                      value: _controller.value,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
