part of 'main.dart';

class RPMView extends CustomPainter {
  final _paint = Paint();

  final double _value;

  RPMView({
    required double value,
  }) : _value = value;

  @override
  void paint(Canvas canvas, Size size) {
    ///
    /// This variable is `true` if the height of the screen is greater than its `width`
    /// Note that if it's `true` then we get portion of the smaller side which is the width and vice versa (if if's `false` then we portion of the smaller side which is the height)
    ///
    final bool heightGreater = (size.height > size.width);

    final centerPoint = Offset(
      size.width * 0.5,
      size.height * 0.5,
    );

    ///
    /// This is rpm progress arc view radius, it's responsive to different screen sizes
    /// This value is max constraints for this property
    ///
    final double rpmProgressArcViewMaxRadius =
        (heightGreater) ? size.width * 0.42 : size.height * 0.42;

    ///
    /// Note that rotating is Anti-clock wise starting from +ve part of x-axis
    ///
    const rpmProgressArcViewStartAngle = (180.0 * _kToRadian);
    // const rpmProgressArcViewEndAngle = 0.0;

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
    const rpmProgressParentArcLength = math.pi;

    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth =
        heightGreater ? size.width * 0.025 : size.height * 0.025;

    ///
    /// We divide our progress arc into 8 parts each 2 parts are split by a white split
    ///
    const rpmProgressChildArcLength = rpmProgressParentArcLength / 8.0;

    ///
    /// We save our last angle so we can draw the next part
    ///
    double currentAngle = rpmProgressArcViewStartAngle;

    ///
    /// Split length between parts
    ///
    double splitLength =
        heightGreater ? size.width * 0.00005 : size.height * 0.00005;

    ///
    /// We loop 8 times to draw 8 parts with 7 splits between them
    /// Note that we save our last RPM so we can draw the next speed by incrementing it
    ///
    for (int i = 0, currentRPM = 0; i < 8; i++, currentRPM++) {
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
          radius: rpmProgressArcViewMaxRadius,
        ),
        currentAngle,
        rpmProgressChildArcLength - splitLength,
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
              radius: rpmProgressArcViewMaxRadius -
                  (heightGreater ? size.width * 0.035 : size.height * 0.035),
            ),
            currentAngle,
            rpmProgressChildArcLength - splitLength,
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
      /// If you can't understand what's going on please see variable `heightGreater` above
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
              (rpmProgressArcViewMaxRadius -
                      (heightGreater
                          ? size.width * 0.02
                          : size.height * 0.02)) *
                  math.cos(currentAngle),
          centerPoint.dy +
              (rpmProgressArcViewMaxRadius -
                      (heightGreater
                          ? size.width * 0.02
                          : size.height * 0.02)) *
                  math.sin(currentAngle),
        ),
      );

      ///
      /// We update our `currentAngle` each time to draw in the next location.
      ///
      currentAngle += rpmProgressChildArcLength;

      ///
      /// If we are in last step, then draw last RPM value text which is 8.
      /// If you can't understand what's going on please see variable `heightGreater` above.
      ///
      switch (i) {
        case 7:
          currentRPM++;
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
                  ..addText('$currentRPM'))
                .build()
              ..layout(
                ui.ParagraphConstraints(
                  width: size.width,
                ),
              ),
            Offset(
              centerPoint.dx +
                  (rpmProgressArcViewMaxRadius -
                          (heightGreater
                              ? size.width * 0.02
                              : size.height * 0.02)) *
                      math.cos(currentAngle),
              centerPoint.dy +
                  (rpmProgressArcViewMaxRadius -
                          (heightGreater
                              ? size.width * 0.02
                              : size.height * 0.02)) *
                      math.sin(currentAngle),
            ),
          );
          break;
        default:
          break;
      }
    }

    _paint.color = Colors.red;

    ///
    /// RPM progress arc.
    ///
    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: rpmProgressArcViewMaxRadius,
      ),
      rpmProgressArcViewStartAngle,
      rpmProgressParentArcLength * _value,
      false,
      _paint,
    );

    _paint.color = Colors.black;

    _paint.style = PaintingStyle.fill;

    ///
    ///  This is the black circle behind value of current RPM.
    ///
    canvas.drawCircle(
      centerPoint,
      (heightGreater) ? size.width * 0.25 : size.height * 0.25,
      _paint,
    );

    ///
    /// Draw current RPM meter value text
    ///
    final currentCarEngineRPMValueParagraphView = (ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontSize: heightGreater ? ((size.width) * 0.1) : ((size.height) * 0.1),
        textAlign: TextAlign.justify,
      ),
    )..addText('${(8.0 * _value).toInt()}'))
        .build()
      ..layout(
        ui.ParagraphConstraints(
          width: size.width,
        ),
      );

    canvas.drawParagraph(
      currentCarEngineRPMValueParagraphView,
      Offset(
        centerPoint.dx -
            ((currentCarEngineRPMValueParagraphView.minIntrinsicWidth) * 0.5),
        centerPoint.dy -
            ((currentCarEngineRPMValueParagraphView.height) * 0.5) -
            (heightGreater ? ((size.width) * 0.1) : ((size.height) * 0.1)),
      ),
    );

    final double batteryLevelProgressArcViewMaxRadius =
        (heightGreater) ? size.width * 0.45 : size.height * 0.45;

    ///
    /// Note that rotating is clock wise starting from (70 degrees from +ve part of x-axis) to (20 degrees from +ve part of x-axis)
    ///
    const batteryLevelProgressArcViewStartAngle = (70.0 * _kToRadian);
    const batteryLevelProgressArcViewEndAngle = (20.0 * _kToRadian);

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
    const batteryLevelProgressArcLength =
        batteryLevelProgressArcViewStartAngle -
            batteryLevelProgressArcViewEndAngle;

    _paint.color = Colors.blueGrey;
    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth =
        heightGreater ? size.width * 0.004 : size.height * 0.004;

    ///
    /// We divide our progress arc into 2 parts each 2 parts with 3 splits as in this video:
    /// https://www.youtube.com/watch?v=QbEYhQIjlQc
    ///
    const batteryLevelProgressChildArcLength =
        batteryLevelProgressArcLength / 2.0;

    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: batteryLevelProgressArcViewMaxRadius,
      ),
      batteryLevelProgressArcViewStartAngle,
      -1.0 * batteryLevelProgressArcLength,
      false,
      _paint,
    );

    ///
    /// We save our last angle so we can draw the next split
    /// Note that we are using the same variable we used to draw speed arc
    ///
    currentAngle = batteryLevelProgressArcViewStartAngle;

    ///
    /// We loop 3 times to draw 2 parts with 3 splits between them
    /// Note that we save our last battery level so we can add on it
    /// Note that we subtract from `batteryLevelProgressArcViewMaxRadius` so that splits appears
    /// Here `heightGreater ? size.width * 0.05 : size.height * 0.05)` we get a value is dependent on screen size
    ///
    for (int i = 0, currentBatteryLevel = 0; i < 3; i++) {
      ///
      /// Draw current split
      ///
      canvas.drawLine(
        Offset(
          centerPoint.dx +
              (batteryLevelProgressArcViewMaxRadius) * math.cos(currentAngle),
          centerPoint.dy +
              (batteryLevelProgressArcViewMaxRadius) * math.sin(currentAngle),
        ),
        Offset(
          centerPoint.dx +
              (batteryLevelProgressArcViewMaxRadius -
                      (heightGreater
                          ? size.width * 0.05
                          : size.height * 0.05)) *
                  math.cos(currentAngle),
          centerPoint.dy +
              (batteryLevelProgressArcViewMaxRadius -
                      (heightGreater
                          ? size.width * 0.05
                          : size.height * 0.05)) *
                  math.sin(currentAngle),
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
                  (batteryLevelProgressArcViewMaxRadius -
                          (heightGreater
                              ? size.width * 0.06
                              : size.height * 0.06)) *
                      math.cos(currentAngle),
              centerPoint.dy +
                  (batteryLevelProgressArcViewMaxRadius -
                          (heightGreater
                              ? size.width * 0.06
                              : size.height * 0.06)) *
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
      currentAngle -= batteryLevelProgressChildArcLength;
    }

    final double temperatureProgressArcViewMaxRadius =
        (heightGreater) ? size.width * 0.45 : size.height * 0.45;

    ///
    /// Note that rotating is clock wise starting from (110 degrees from +ve part of x-axis) to (160 degrees from +ve part of x-axis)
    ///
    const temperatureProgressArcViewStartAngle = (110.0 * _kToRadian);
    const temperatureProgressArcViewEndAngle = (160.0 * _kToRadian);

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
    const temperatureProgressArcLength = temperatureProgressArcViewStartAngle -
        temperatureProgressArcViewEndAngle;

    ///
    /// We divide our progress arc into 2 parts each 2 parts with 3 splits as in this video:
    /// https://www.youtube.com/watch?v=QbEYhQIjlQc
    ///
    const temperatureProgressChildArcLength =
        temperatureProgressArcLength / 2.0;

    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: temperatureProgressArcViewMaxRadius,
      ),
      temperatureProgressArcViewStartAngle,
      -1.0 * temperatureProgressArcLength,
      false,
      _paint,
    );

    ///
    /// We save our last angle so we can draw the next split
    /// Note that we are using the same variable we used to draw speed arc
    ///
    currentAngle = temperatureProgressArcViewStartAngle;

    ///
    /// We loop 3 times to draw 2 parts with 3 splits between them
    /// Note that we save our last temperature so we can add on it
    /// Note that we subtract from `temperatureProgressArcViewMaxRadius` so that splits appears
    /// Here `heightGreater ? size.width * 0.05 : size.height * 0.05)` we get a value is dependent on screen size
    ///
    for (int i = 0, currentTemperature = 40; i < 3; i++) {
      ///
      /// Draw current split
      ///
      canvas.drawLine(
        Offset(
          centerPoint.dx +
              (temperatureProgressArcViewMaxRadius) * math.cos(currentAngle),
          centerPoint.dy +
              (temperatureProgressArcViewMaxRadius) * math.sin(currentAngle),
        ),
        Offset(
          centerPoint.dx +
              (temperatureProgressArcViewMaxRadius -
                      (heightGreater
                          ? size.width * 0.05
                          : size.height * 0.05)) *
                  math.cos(currentAngle),
          centerPoint.dy +
              (temperatureProgressArcViewMaxRadius -
                      (heightGreater
                          ? size.width * 0.05
                          : size.height * 0.05)) *
                  math.sin(currentAngle),
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
                  (batteryLevelProgressArcViewMaxRadius -
                          (heightGreater
                              ? size.width * 0.06
                              : size.height * 0.06)) *
                      math.cos(currentAngle),
              centerPoint.dy +
                  (batteryLevelProgressArcViewMaxRadius -
                          (heightGreater
                              ? size.width * 0.06
                              : size.height * 0.06)) *
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
      currentAngle -= temperatureProgressChildArcLength;
    }

    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth =
        heightGreater ? size.width * 0.025 : size.height * 0.025;

    ///
    /// This is battery level arc
    ///
    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: batteryLevelProgressArcViewMaxRadius -
            ((heightGreater ? size.width * 0.025 : size.height * 0.025) / 2.0),
      ),
      batteryLevelProgressArcViewStartAngle,
      -1.0 * batteryLevelProgressArcLength * _value,
      false,
      _paint,
    );

    ///
    /// This is temperature arc
    ///
    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: temperatureProgressArcViewMaxRadius -
            ((heightGreater ? size.width * 0.025 : size.height * 0.025) / 2.0),
      ),
      temperatureProgressArcViewStartAngle,
      -1.0 * temperatureProgressArcLength * _value,
      false,
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
