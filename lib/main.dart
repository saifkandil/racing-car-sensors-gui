import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

const _kToDegree = 180.0 / math.pi;
const _kToRadian = math.pi / 180.0;

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
  late AnimationController _controller;
  late math.Random _random;

  ///
  /// This function will generate dummy data to show GUI capabilities
  ///
  double _generateDummyData() {
    return _random.nextDouble();
  }

  @override
  void initState() {
    super.initState();
    _random = math.Random();
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _controller
      ..addListener(_animationChanged)
      ..addStatusListener(_animationStatusChanged);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: SpeedView(
                      speedProgressValue:
                          _generateDummyData() * _controller.value,
                      fuelProgressValue:
                          _generateDummyData() * _controller.value,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: RPMView(
                      rpmProgressValue:
                          _generateDummyData() * _controller.value,
                      batteryProgressValue:
                          _generateDummyData() * _controller.value,
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

class SpeedView extends CustomPainter {
  final _paint = Paint();
  final _path = Path();

  final double _speedProgressValue;
  final double _fuelProgressValue;

  SpeedView({
    required double speedProgressValue,
    required double fuelProgressValue,
  })  : _speedProgressValue = speedProgressValue,
        _fuelProgressValue = fuelProgressValue;

  @override
  void paint(Canvas canvas, Size size) {
    final bool heightGreater = (size.height > size.width);

    final centerPoint = Offset(
      size.width * 0.5,
      size.height * 0.5,
    );

    ///
    /// This is speed progress arc view radius, it's responsive to different screen sizes
    /// This value is max constraints for this property
    ///
    final double speedProgressViewRadius =
        (heightGreater) ? size.width * 0.42 : size.height * 0.42;

    ///
    /// Note that rotating is Anti-clock wise starting from +ve part of x-axis
    ///
    final speedProgressViewStartAngle = (120.0 * _kToRadian);
    final speedProgressViewEndAngle = (10.0 * _kToRadian);

    ///
    /// Speed progress arc length has two parts
    ///  - First part: angle from `xSpeedProgressArcStartPoint` till `+ve part of x-axis` in Anti-clock wise direction
    ///  - Second part: angle from `+ve part of x-axis` till `speedProgressViewEndAngle` in Anti-clock wise direction
    ///
    /// Here in that diagram `#` represents first part while `+` represents second part
    ///
    ///                                  (+ve y-axis)
    ///                                     |
    ///                                     |
    ///                                ###########
    ///                            #########|#########
    ///           (First part)   ###########|###########
    ///                        #############|#############
    ///       <----------------#############|############&&&&&&&&&&&-------> (+ve x-axis)
    ///                        ###########  |  &&&&&&&&&&&&&&&&&&&&&
    ///                          ######     |      &&&&&&&&&&&&&&&
    ///                            #        |          &&&&&&&&&   (Second part)
    ///                         *           |              &&
    ///                      *              |                  *
    ///                   *                 |                      *
    ///   (speedProgressViewStartAngle)     |            (speedProgressViewEndAngle)
    ///                                     |
    ///
    final speedProgressArcLength =
        ((2 * math.pi) - speedProgressViewStartAngle) +
            speedProgressViewEndAngle;

    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth = 12.0;

    ///
    /// We divide our progress arc into 12 parts each 2 parts are split by a white split
    ///
    final speedArcSinglePartLength = speedProgressArcLength / 12.0;

    ///
    /// We save our last angle so we can draw the next part
    ///
    double currentAngle = speedProgressViewStartAngle;

    ///
    /// We save our last speed so we can draw the next speed by adding 20 on it
    ///
    int currentSpeed = 0;

    ///
    /// Split length between parts
    ///
    double splitLength = 0.02;

    ///
    /// We loop 12 times to draw 12 parts with 11 splits between them
    ///
    for (int i = 0; i < 12; i++) {
      ///
      /// Last part doesn't require a split so we assign zero to `splitLength` variable
      /// `11` means last part
      ///
      switch (i) {
        case 11:
          splitLength = 0.0;
          break;
        default:
          break;
      }

      ///
      /// Draw current part
      ///
      canvas.drawArc(
        Rect.fromCircle(
          center: centerPoint,
          radius: speedProgressViewRadius,
        ),
        currentAngle,
        speedArcSinglePartLength - splitLength,
        false,
        _paint,
      );

      ///
      /// Draw current speed value text
      ///
      canvas.drawParagraph(
        (ui.ParagraphBuilder(
          ui.ParagraphStyle(
            fontSize:
                heightGreater ? ((size.width) * 0.04) : ((size.height) * 0.04),
            textAlign: TextAlign.justify,
          ),
        )
              ..pushStyle(
                ui.TextStyle(
                  color: Colors.black38,
                ),
              )
              ..addText('$currentSpeed'))
            .build()
          ..layout(
            ui.ParagraphConstraints(
              width: size.width,
            ),
          ),
        Offset(
          centerPoint.dx +
              (speedProgressViewRadius - 10.0) * math.cos(currentAngle),
          centerPoint.dy +
              (speedProgressViewRadius - 10.0) * math.sin(currentAngle),
        ),
      );

      ///
      /// We update our `currentSpeed` each time to draw the next speed text
      ///
      currentSpeed += 20;

      ///
      /// We update our `currentAngle` each time to draw in the next location
      ///
      currentAngle += speedArcSinglePartLength;
    }

    _paint.color = Colors.red;

    ///
    /// Speed progress arc
    ///
    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: speedProgressViewRadius,
      ),
      speedProgressViewStartAngle,
      speedProgressArcLength * _speedProgressValue,
      false,
      _paint,
    );

    _paint.color = Colors.black;

    ///
    /// This is speed meter circle view radius, it's responsive to different screen sizes
    /// This value is max constraints for this property
    ///
    final double speedMeterBackgroundCircleRadius =
        (heightGreater) ? size.width * 0.25 : size.height * 0.25;

    _paint.style = PaintingStyle.fill;

    canvas.drawCircle(
      centerPoint,
      speedMeterBackgroundCircleRadius,
      _paint,
    );

    ///
    /// Draw current speed meter value text
    ///
    final speedValueParagraph = (ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontSize: heightGreater ? ((size.width) * 0.1) : ((size.height) * 0.1),
        textAlign: TextAlign.justify,
      ),
    )..addText('0'))
        .build()
      ..layout(
        ui.ParagraphConstraints(
          width: size.width,
        ),
      );

    canvas.drawParagraph(
      speedValueParagraph,
      Offset(
        centerPoint.dx - ((speedValueParagraph.minIntrinsicWidth) * 0.5),
        centerPoint.dy -
            ((speedValueParagraph.height) * 0.5) -
            (heightGreater ? ((size.width) * 0.1) : ((size.height) * 0.1)),
      ),
    );

    ///
    /// Draw speed measurement unit
    ///
    final speedUnitParagraph = (ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontSize:
            heightGreater ? ((size.width) * 0.05) : ((size.height) * 0.05),
        textAlign: TextAlign.justify,
      ),
    )..addText('km/h'))
        .build()
      ..layout(
        ui.ParagraphConstraints(
          width: size.width,
        ),
      );

    canvas.drawParagraph(
      speedUnitParagraph,
      Offset(
        centerPoint.dx - ((speedValueParagraph.minIntrinsicWidth) * 0.5),
        centerPoint.dy -
            ((speedValueParagraph.height) * 0.5) +
            (heightGreater ? ((size.width) * 0.03) : ((size.height) * 0.03)),
      ),
    );

    final double fuelProgressViewRadius =
        (heightGreater) ? size.width * 0.45 : size.height * 0.45;

    ///
    /// Note that rotating is clock wise starting from (80 degrees from +ve part of x-axis) to (30 degrees from +ve part of x-axis)
    ///
    final fuelProgressViewStartAngle = (80.0 * _kToRadian);
    final fuelProgressViewEndAngle = (30.0 * _kToRadian);

    ///
    /// Fuel progress arc length is the angle from (80 degrees from +ve part of x-axis)
    /// till (30 degrees from +ve part of x-axis) in clock wise direction
    ///
    /// Here in that diagram `#` represents fuel's angle
    ///
    ///                                  (+ve y-axis)
    ///                                     |
    ///                                     |
    ///                                     |
    ///                                     |
    ///                                     |
    ///                                     |
    ///       <-----------------------------|-------------------------------> (+ve x-axis)
    ///                                     | #
    ///                                     |  ######
    ///                                     |   ###########             (fuel's angle)
    ///                                     |    ################
    ///                                     |     #####################
    ///                                     |      ##########################
    ///                                     |       ###############################
    ///                                     |        * (80 degrees)                     *  (30 degrees)
    ///
    final fuelProgressArcLength =
        fuelProgressViewStartAngle - fuelProgressViewEndAngle;

    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth = 2.0;

    ///
    /// We divide our progress arc into 2 parts each 2 parts with 3 splits as in this video:
    /// https://www.youtube.com/watch?v=QbEYhQIjlQc
    ///
    final fuelArcSinglePartLength = fuelProgressArcLength / 2.0;

    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: fuelProgressViewRadius,
      ),
      fuelProgressViewStartAngle,
      -1.0 * fuelProgressArcLength,
      false,
      _paint,
    );

    ///
    /// We save our last angle so we can draw the next split
    /// Note that we are using the same variable we used to draw speed arc
    ///
    currentAngle = fuelProgressViewStartAngle;

    ///
    /// We loop 3 times to draw 2 parts with 3 splits between them
    ///
    for (int i = 0; i < 3; i++) {
      ///
      /// Draw current split
      ///
      canvas.drawLine(
        Offset(
          centerPoint.dx + (fuelProgressViewRadius) * math.cos(currentAngle),
          centerPoint.dy + (fuelProgressViewRadius) * math.sin(currentAngle),
        ),
        Offset(
          centerPoint.dx +
              (fuelProgressViewRadius - 20.0) * math.cos(currentAngle),
          centerPoint.dy +
              (fuelProgressViewRadius - 20.0) * math.sin(currentAngle),
        ),
        _paint,
      );

      ///
      /// We update our `currentAngle` each time to draw in the next location
      ///
      currentAngle -= fuelArcSinglePartLength;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class RPMView extends CustomPainter {
  final _paint = Paint();
  final _path = Path();

  final double _rpmProgressValue;
  final double _batteryProgressValue;

  RPMView({
    required double rpmProgressValue,
    required double batteryProgressValue,
  })  : _rpmProgressValue = rpmProgressValue,
        _batteryProgressValue = batteryProgressValue;

  @override
  void paint(Canvas canvas, Size size) {
    final bool heightGreater = (size.height > size.width);

    final centerPoint = Offset(
      size.width * 0.5,
      size.height * 0.5,
    );

    ///
    /// This is rpm progress arc view radius, it's responsive to different screen sizes
    /// This value is max constraints for this property
    ///
    final double rpmProgressViewRadius =
        (heightGreater) ? size.width * 0.42 : size.height * 0.42;

    ///
    /// Note that rotating is Anti-clock wise starting from +ve part of x-axis
    ///
    final rpmProgressViewStartAngle = (180.0 * _kToRadian);
    final rpmProgressViewEndAngle = 0.0;

    ///
    /// RPM progress arc length is the angle from -ve part of x-axis till +ve part of x-axis in Anti-clock wise direction
    ///
    /// Here in that diagram `#` represents first part while `+` represents second part
    ///
    ///                                  (+ve y-axis)
    ///                                     |
    ///                                     |
    ///                                ###########
    ///                            #########|#########
    ///                          ###########|###########
    ///                        #############|#############
    ///       <----------------#############|#############--------------> (+ve x-axis)
    ///                                     |
    ///                                     |
    ///                                     |
    ///                                     |
    ///                                     |
    ///                                     |
    ///
    final rpmProgressArcLength = math.pi;

    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth = 12.0;

    ///
    /// We divide our progress arc into 8 parts each 2 parts are split by a white split
    ///
    final rpmArcSinglePartLength = rpmProgressArcLength / 8.0;

    ///
    /// We save our last angle so we can draw the next part
    ///
    double currentAngle = rpmProgressViewStartAngle;

    ///
    /// We save our last RPM so we can draw the next speed by adding 20 on it
    ///
    int currentRPM = 0;

    ///
    /// Split length between parts
    ///
    double splitLength = 0.02;

    ///
    /// We loop 8 times to draw 8 parts with 7 splits between them
    ///
    for (int i = 0; i < 8; i++) {
      ///
      /// Last part doesn't require a split so we assign zero to `splitLength` variable
      /// `7` means last part
      ///
      switch (i) {
        case 7:
          splitLength = 0.0;
          break;
        default:
          break;
      }

      ///
      /// Draw current part
      ///
      canvas.drawArc(
        Rect.fromCircle(
          center: centerPoint,
          radius: rpmProgressViewRadius,
        ),
        currentAngle,
        rpmArcSinglePartLength - splitLength,
        false,
        _paint,
      );

      ///
      /// If we are in last and before last parts then we also add a red arc (to indicate danger RPM reached)
      ///
      switch (i) {
        case 6:
        case 7:
          _paint.color = Colors.red;
          canvas.drawArc(
            Rect.fromCircle(
              center: centerPoint,
              radius: rpmProgressViewRadius - 18.0,
            ),
            currentAngle,
            rpmArcSinglePartLength - splitLength,
            false,
            _paint,
          );
          _paint.color = Colors.black;
          break;
        default:
          break;
      }

      ///
      /// Draw current speed value text
      ///
      canvas.drawParagraph(
        (ui.ParagraphBuilder(
          ui.ParagraphStyle(
            fontSize:
                heightGreater ? ((size.width) * 0.04) : ((size.height) * 0.04),
            textAlign: TextAlign.justify,
          ),
        )
              ..pushStyle(
                ui.TextStyle(
                  color: Colors.black38,
                ),
              )
              ..addText('$currentRPM'))
            .build()
          ..layout(
            ui.ParagraphConstraints(
              width: size.width,
            ),
          ),
        Offset(
          centerPoint.dx +
              (rpmProgressViewRadius - 10.0) * math.cos(currentAngle),
          centerPoint.dy +
              (rpmProgressViewRadius - 10.0) * math.sin(currentAngle),
        ),
      );

      ///
      /// We update our `currentSpeed` each time to draw the next speed text
      ///
      currentRPM += 1;

      ///
      /// We update our `currentAngle` each time to draw in the next location
      ///
      currentAngle += rpmArcSinglePartLength;
    }

    ///
    /// This is RPM meter circle view radius, it's responsive to different screen sizes
    /// This value is max constraints for this property
    ///
    final double rpmMeterBackgroundCircleRadius =
        (heightGreater) ? size.width * 0.25 : size.height * 0.25;

    _paint.style = PaintingStyle.fill;

    canvas.drawCircle(
      centerPoint,
      rpmMeterBackgroundCircleRadius,
      _paint,
    );

    ///
    /// Draw current RPM meter value text
    ///
    final speedValueParagraph = (ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontSize: heightGreater ? ((size.width) * 0.1) : ((size.height) * 0.1),
        textAlign: TextAlign.justify,
      ),
    )..addText('0'))
        .build()
      ..layout(
        ui.ParagraphConstraints(
          width: size.width,
        ),
      );

    canvas.drawParagraph(
      speedValueParagraph,
      Offset(
        centerPoint.dx - ((speedValueParagraph.minIntrinsicWidth) * 0.5),
        centerPoint.dy -
            ((speedValueParagraph.height) * 0.5) -
            (heightGreater ? ((size.width) * 0.1) : ((size.height) * 0.1)),
      ),
    );

    final double batteryLevelProgressViewRadius =
        (heightGreater) ? size.width * 0.45 : size.height * 0.45;

    ///
    /// Note that rotating is clock wise starting from (70 degrees from +ve part of x-axis) to (20 degrees from +ve part of x-axis)
    ///
    final batteryLevelProgressViewStartAngle = (70.0 * _kToRadian);
    final batteryLevelProgressViewEndAngle = (20.0 * _kToRadian);

    ///
    /// Battery level progress arc length is the angle from (70 degrees from +ve part of x-axis)
    /// till (20 degrees from +ve part of x-axis) in clock wise direction
    ///
    /// Here in that diagram `#` represents battery level's angle
    ///
    ///                                  (+ve y-axis)
    ///                                     |
    ///                                     |
    ///                                     |
    ///                                     |
    ///                                     |
    ///                                     |
    ///       <-----------------------------|-------------------------------> (+ve x-axis)
    ///                                     | #
    ///                                     |  ######
    ///                                     |   ###########             (battery level's angle)
    ///                                     |    ################
    ///                                     |     #####################
    ///                                     |      ##########################
    ///                                     |       ###############################
    ///                                     |        * (70 degrees)                     *  (20 degrees)
    ///
    final batteryLevelProgressArcLength =
        batteryLevelProgressViewStartAngle - batteryLevelProgressViewEndAngle;

    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth = 2.0;

    ///
    /// We divide our progress arc into 2 parts each 2 parts with 3 splits as in this video:
    /// https://www.youtube.com/watch?v=QbEYhQIjlQc
    ///
    final batteryLevelArcSinglePartLength = batteryLevelProgressArcLength / 2.0;

    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: batteryLevelProgressViewRadius,
      ),
      batteryLevelProgressViewStartAngle,
      -1.0 * batteryLevelProgressArcLength,
      false,
      _paint,
    );

    ///
    /// We save our last angle so we can draw the next split
    /// Note that we are using the same variable we used to draw speed arc
    ///
    currentAngle = batteryLevelProgressViewStartAngle;

    ///
    /// We save our last battery level so we can add on it
    ///
    int currentBatteryLevel = 0;

    ///
    /// We loop 3 times to draw 2 parts with 3 splits between them
    ///
    for (int i = 0; i < 3; i++) {
      ///
      /// Draw current split
      ///
      canvas.drawLine(
        Offset(
          centerPoint.dx +
              (batteryLevelProgressViewRadius) * math.cos(currentAngle),
          centerPoint.dy +
              (batteryLevelProgressViewRadius) * math.sin(currentAngle),
        ),
        Offset(
          centerPoint.dx +
              (batteryLevelProgressViewRadius - 20.0) * math.cos(currentAngle),
          centerPoint.dy +
              (batteryLevelProgressViewRadius - 20.0) * math.sin(currentAngle),
        ),
        _paint,
      );

      ///
      /// Draw battery level value text
      ///
      switch (i) {
        case 0:
        case 2:
          canvas.drawParagraph(
            (ui.ParagraphBuilder(
              ui.ParagraphStyle(
                fontSize: heightGreater
                    ? ((size.width) * 0.04)
                    : ((size.height) * 0.04),
                textAlign: TextAlign.justify,
              ),
            )
                  ..pushStyle(
                    ui.TextStyle(
                      color: Colors.black38,
                    ),
                  )
                  ..addText('$currentBatteryLevel'))
                .build()
              ..layout(
                ui.ParagraphConstraints(
                  width: size.width,
                ),
              ),
            Offset(
              centerPoint.dx +
                  (batteryLevelProgressViewRadius - 25.0) *
                      math.cos(currentAngle),
              centerPoint.dy +
                  (batteryLevelProgressViewRadius - 25.0) *
                      math.sin(currentAngle),
            ),
          );
          currentBatteryLevel += 100;
          break;
        default:
          break;
      }

      ///
      /// We update our `currentAngle` each time to draw in the next location
      ///
      currentAngle -= batteryLevelArcSinglePartLength;
    }

    final double temperatureProgressViewRadius =
        (heightGreater) ? size.width * 0.45 : size.height * 0.45;

    ///
    /// Note that rotating is clock wise starting from (110 degrees from +ve part of x-axis) to (160 degrees from +ve part of x-axis)
    ///
    final temperatureProgressViewStartAngle = (110.0 * _kToRadian);
    final temperatureProgressViewEndAngle = (160.0 * _kToRadian);

    ///
    /// Temperature progress arc length is the angle from (110 degrees from +ve part of x-axis)
    /// till (160 degrees from +ve part of x-axis) in clock wise direction
    ///
    /// Here in that diagram `#` represents temperature's angle
    ///
    ///                                  (+ve y-axis)
    ///                                     |
    ///                                     |
    ///                                     |
    ///                                     |
    ///                                     |
    ///                                     |
    ///       <-----------------------------|-------------------------------> (+ve x-axis)
    ///                                   # |
    ///                             ######  |
    ///        (160 degrees)  ###########   |
    ///                 ################    |
    ///           #####################     |
    ///     ##########################      |
    ///  ############################   (110 degrees)
    ///    (temperature's angle)            |
    ///
    final temperatureProgressArcLength =
        temperatureProgressViewStartAngle - temperatureProgressViewEndAngle;

    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth = 2.0;

    ///
    /// We divide our progress arc into 2 parts each 2 parts with 3 splits as in this video:
    /// https://www.youtube.com/watch?v=QbEYhQIjlQc
    ///
    final temperatureArcSinglePartLength = temperatureProgressArcLength / 2.0;

    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: temperatureProgressViewRadius,
      ),
      temperatureProgressViewStartAngle,
      -1.0 * temperatureProgressArcLength,
      false,
      _paint,
    );

    ///
    /// We save our last angle so we can draw the next split
    /// Note that we are using the same variable we used to draw speed arc
    ///
    currentAngle = temperatureProgressViewStartAngle;

    ///
    /// We save our last temperature so we can add on it
    ///
    int currentTemperature = 40;

    ///
    /// We loop 3 times to draw 2 parts with 3 splits between them
    ///
    for (int i = 0; i < 3; i++) {
      ///
      /// Draw current split
      ///
      canvas.drawLine(
        Offset(
          centerPoint.dx +
              (temperatureProgressViewRadius) * math.cos(currentAngle),
          centerPoint.dy +
              (temperatureProgressViewRadius) * math.sin(currentAngle),
        ),
        Offset(
          centerPoint.dx +
              (temperatureProgressViewRadius - 20.0) * math.cos(currentAngle),
          centerPoint.dy +
              (temperatureProgressViewRadius - 20.0) * math.sin(currentAngle),
        ),
        _paint,
      );

      ///
      /// Draw temperature value text
      /// Note that split length = 20.0 so we place our text more further at 25.0 (check out offset of this paragraph)
      /// Note that we add 80 on current Temperature as shown in the video: https://www.youtube.com/watch?v=QbEYhQIjlQc
      ///
      switch (i) {
        case 0:
        case 2:
          canvas.drawParagraph(
            (ui.ParagraphBuilder(
              ui.ParagraphStyle(
                fontSize: heightGreater
                    ? ((size.width) * 0.04)
                    : ((size.height) * 0.04),
                textAlign: TextAlign.justify,
              ),
            )
                  ..pushStyle(
                    ui.TextStyle(
                      color: Colors.black38,
                    ),
                  )
                  ..addText('$currentTemperature'))
                .build()
              ..layout(
                ui.ParagraphConstraints(
                  width: size.width,
                ),
              ),
            Offset(
              centerPoint.dx +
                  (batteryLevelProgressViewRadius - 25.0) *
                      math.cos(currentAngle),
              centerPoint.dy +
                  (batteryLevelProgressViewRadius - 25.0) *
                      math.sin(currentAngle),
            ),
          );
          currentTemperature += 80;
          break;
        default:
          break;
      }

      ///
      /// We update our `currentAngle` each time to draw in the next location
      ///
      currentAngle -= temperatureArcSinglePartLength;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
