part of 'main.dart';

///
/// This function returns different color depending the passed double `value`
///
Color _getColorForValue(double value) {
  return Color.fromRGBO(
      (value * 255.0).toInt(), (255.0 - value * 255.0).toInt(), 0, 1.0);
}

class ThrottlePositionView extends CustomPainter {
  final _paint = Paint();

  final double _value;

  ThrottlePositionView({
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
    /// Draw primary splits
    ///
    for (int i = 0, currentPercentage = 0, level = -300;
        i < 6;
        i++, currentPercentage += 20, level += 100) {
      canvas.drawLine(
        Offset(
          centerPoint.dx - 10.0,
          centerPoint.dy + level,
        ),
        Offset(
          centerPoint.dx - 50.0,
          centerPoint.dy + level,
        ),
        _paint,
      );

      ///
      /// Draw percentages text
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
              ..addText('$currentPercentage'))
            .build()
          ..layout(
            ui.ParagraphConstraints(
              width: size.width,
            ),
          ),
        Offset(
          centerPoint.dx + 10.0,
          centerPoint.dy + level,
        ),
      );
    }

    ///
    /// Draw secondary splits
    ///
    for (int i = 0, level = -300; i < 20; i++, level += 10) {
      canvas.drawLine(
        Offset(
          centerPoint.dx - 10.0,
          centerPoint.dy + level,
        ),
        Offset(
          centerPoint.dx - 30.0,
          centerPoint.dy + level,
        ),
        _paint,
      );
    }

    _paint.color = _getColorForValue(1.0 - _value);
    _paint.strokeWidth = 20.0;

    ///
    /// Draw progress histogram
    ///
    canvas.drawLine(
      Offset(
        centerPoint.dx - 80.0,
        centerPoint.dy + 300.0,
      ),
      Offset(
        centerPoint.dx - 80.0,
        // (centerPoint.dy - 300.0) * _value,
        600.0 * _value,
      ),
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
