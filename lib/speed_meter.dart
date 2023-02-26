part of 'main.dart';

class SpeedView extends CustomPainter {
  final _paint = Paint();

  final double _value;

  SpeedView({
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
    /// This is speed progress arc view radius, it's responsive to different screen sizes.
    /// This value is max constraints for this property.
    ///
    final double speedProgressArcViewMaxRadius =
        (heightGreater) ? size.width * 0.42 : size.height * 0.42;

    ///
    /// Note that rotating is Anti-clock wise starting from +ve part of x-axis.
    ///
    final speedProgressArcViewStartAngle = (120.0 * _kToRadian);
    final speedProgressArcViewEndAngle = (10.0 * _kToRadian);

    ///
    /// Speed progress arc length has two parts:
    ///  - First part: angle from `xSpeedProgressArcStartPoint` till `+ve part of x-axis` in Anti-clock wise direction.
    ///  - Second part: angle from `+ve part of x-axis` till `speedProgressArcViewEndAngle` in Anti-clock wise direction.
    ///
    /// Here in that diagram (`#` represents first part while `+` represents second part):
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
    ///   (speedProgressArcViewStartAngle)     |            (speedProgressArcViewEndAngle)
    ///                                     |
    ///
    final speedProgressParentArcLength =
        ((2 * math.pi) - speedProgressArcViewStartAngle) +
            speedProgressArcViewEndAngle;

    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth =
        heightGreater ? size.width * 0.025 : size.height * 0.025;

    ///
    /// We divide our progress arc into 12 parts each 2 parts are split by a white split.
    ///
    final speedProgressChildArcLength = speedProgressParentArcLength / 12.0;

    ///
    /// We save our last angle so we can draw the next part.
    ///
    double currentAngle = speedProgressArcViewStartAngle;

    ///
    /// Split length between parts.
    /// Note that we save our last speed so we can draw the next speed by adding 20 on it.
    ///
    double speedProgressChildSplitLength =
        heightGreater ? size.width * 0.00005 : size.height * 0.00005;

    ///
    /// We loop 12 times to draw 12 parts with 11 splits between them.
    ///
    for (int i = 0, currentSpeed = 0; i < 12; i++, currentSpeed += 20) {
      ///
      /// Last part doesn't require a split so we assign zero to `speedProgressChildSplitLength` variable.
      /// `11` means last part.
      ///
      switch (i) {
        case 11:
          speedProgressChildSplitLength = 0.0;
          break;
        default:
          break;
      }

      ///
      /// Draw current part.
      ///
      canvas.drawArc(
        Rect.fromCircle(
          center: centerPoint,
          radius: speedProgressArcViewMaxRadius,
        ),
        currentAngle,
        speedProgressChildArcLength - speedProgressChildSplitLength,
        false,
        _paint,
      );

      ///
      /// Draw current speed value text.
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
              (speedProgressArcViewMaxRadius -
                      (heightGreater
                          ? size.width * 0.02
                          : size.height * 0.02)) *
                  math.cos(currentAngle),
          centerPoint.dy +
              (speedProgressArcViewMaxRadius -
                      (heightGreater
                          ? size.width * 0.02
                          : size.height * 0.02)) *
                  math.sin(currentAngle),
        ),
      );

      ///
      /// We update our `currentAngle` each time to draw in the next location.
      ///
      currentAngle += speedProgressChildArcLength;

      ///
      /// If we are in last step, then draw last speed value text which is 240
      ///
      switch (i) {
        case 11:
          currentSpeed += 20;
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
                  ..addText('$currentSpeed'))
                .build()
              ..layout(
                ui.ParagraphConstraints(
                  width: size.width,
                ),
              ),
            Offset(
              centerPoint.dx +
                  (speedProgressArcViewMaxRadius -
                          (heightGreater
                              ? size.width * 0.02
                              : size.height * 0.02)) *
                      math.cos(currentAngle),
              centerPoint.dy +
                  (speedProgressArcViewMaxRadius -
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
    /// Speed progress arc.
    ///
    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: speedProgressArcViewMaxRadius,
      ),
      speedProgressArcViewStartAngle,
      speedProgressParentArcLength * _value,
      false,
      _paint,
    );

    _paint.color = Colors.black;

    _paint.style = PaintingStyle.fill;

    ///
    /// This is the black circle behind value of current speed.
    ///
    canvas.drawCircle(
      centerPoint,
      (heightGreater) ? size.width * 0.25 : size.height * 0.25,
      _paint,
    );

    ///
    /// Draw current speed meter value text.
    ///
    final currentCarSpeedValueParagraphView = (ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontSize: heightGreater ? ((size.width) * 0.1) : ((size.height) * 0.1),
        textAlign: TextAlign.justify,
      ),
    )..addText('${(240.0 * _value).toInt()}'))
        .build()
      ..layout(
        ui.ParagraphConstraints(
          width: size.width,
        ),
      );

    canvas.drawParagraph(
      currentCarSpeedValueParagraphView,
      Offset(
        centerPoint.dx -
            ((currentCarSpeedValueParagraphView.minIntrinsicWidth) * 0.5),
        centerPoint.dy -
            ((currentCarSpeedValueParagraphView.height) * 0.5) -
            (heightGreater ? ((size.width) * 0.1) : ((size.height) * 0.1)),
      ),
    );

    ///
    /// Draw speed measurement unit.
    ///
    final currentCarSpeedMeasurementUnitParagraphView = (ui.ParagraphBuilder(
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
      currentCarSpeedMeasurementUnitParagraphView,
      Offset(
        centerPoint.dx -
            ((currentCarSpeedValueParagraphView.minIntrinsicWidth) * 0.5),
        centerPoint.dy -
            ((currentCarSpeedValueParagraphView.height) * 0.5) +
            (heightGreater ? ((size.width) * 0.03) : ((size.height) * 0.03)),
      ),
    );

    final double fuelProgressArcViewMaxRadius =
        (heightGreater) ? size.width * 0.45 : size.height * 0.45;

    ///
    /// Note that rotating is clock wise starting from (80 degrees from +ve part of x-axis) to (30 degrees from +ve part of x-axis).
    ///
    final fuelProgressArcViewStartAngle = (80.0 * _kToRadian);
    final fuelProgressArcViewEndAngle = (30.0 * _kToRadian);

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
        fuelProgressArcViewStartAngle - fuelProgressArcViewEndAngle;

    _paint.color = Colors.blueGrey;
    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth =
        heightGreater ? size.width * 0.004 : size.height * 0.004;

    ///
    /// We divide our progress arc into 2 parts each 2 parts with 3 splits as in this video:
    /// https://www.youtube.com/watch?v=QbEYhQIjlQc
    ///
    final fuelProgressChildArcLength = fuelProgressArcLength / 2.0;

    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: fuelProgressArcViewMaxRadius,
      ),
      fuelProgressArcViewStartAngle,
      -1.0 * fuelProgressArcLength,
      false,
      _paint,
    );

    ///
    /// We save our last angle so we can draw the next split
    /// Note that we are using the same variable we used to draw speed arc
    ///
    currentAngle = fuelProgressArcViewStartAngle;

    ///
    /// We loop 3 times to draw 2 parts with 3 splits between them
    ///
    for (int i = 0; i < 3; i++) {
      ///
      /// Draw current split
      /// Note that we subtract from `fuelProgressArcViewMaxRadius` so that splits appears
      /// Here `heightGreater ? size.width * 0.05 : size.height * 0.05)` we get a value is dependent on screen size
      ///
      canvas.drawLine(
        Offset(
          centerPoint.dx +
              (fuelProgressArcViewMaxRadius) * math.cos(currentAngle),
          centerPoint.dy +
              (fuelProgressArcViewMaxRadius) * math.sin(currentAngle),
        ),
        Offset(
          centerPoint.dx +
              (fuelProgressArcViewMaxRadius -
                      (heightGreater
                          ? size.width * 0.05
                          : size.height * 0.05)) *
                  math.cos(currentAngle),
          centerPoint.dy +
              (fuelProgressArcViewMaxRadius -
                      (heightGreater
                          ? size.width * 0.05
                          : size.height * 0.05)) *
                  math.sin(currentAngle),
        ),
        _paint,
      );

      ///
      /// We update our `currentAngle` each time to draw in the next location
      ///
      currentAngle -= fuelProgressChildArcLength;
    }

    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth =
        heightGreater ? size.width * 0.025 : size.height * 0.025;

    ///
    /// This is fuel arc
    /// Stroke width of fuel progress arc is (heightGreater ? size.width * 0.025 : size.height * 0.025) so if we subtract (heightGreater ? size.width * 0.025 : size.height * 0.025)
    /// from `fuelProgressArcViewMaxRadius` to shift arc toward the center
    /// If you want to see how it looks without this subtraction just remove this value from radius assignment below ((heightGreater ? size.width * 0.025 : size.height * 0.025) / 2.0)
    ///
    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: fuelProgressArcViewMaxRadius -
            ((heightGreater ? size.width * 0.025 : size.height * 0.025) / 2.0),
      ),
      fuelProgressArcViewStartAngle,
      -1.0 * fuelProgressArcLength * _value,
      false,
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
