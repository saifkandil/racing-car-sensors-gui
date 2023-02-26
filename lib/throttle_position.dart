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

    _paint.strokeWidth = heightGreater ? size.width * 0.01 : size.height * 0.01;

    final differenceBetweenParentSplits =
        heightGreater ? size.width * 0.2 : size.height * 0.2;

    ///
    /// Draw primary splits
    /// Note that we multiply height by each time be `i` to draw next split in next location
    ///
    for (int i = 0, currentPercentage = 0;
        i < 6;
        i++, currentPercentage += 20) {
      canvas.drawLine(
        Offset(
          heightGreater
              ? centerPoint.dx - (size.width * 0.02)
              : centerPoint.dx - (size.height * 0.02),
          centerPoint.dy -
              (2 * differenceBetweenParentSplits) +
              (i * differenceBetweenParentSplits),
        ),
        Offset(
          heightGreater
              ? centerPoint.dx - (size.width * 0.1)
              : centerPoint.dx - (size.height * 0.1),
          centerPoint.dy -
              (2 * differenceBetweenParentSplits) +
              (i * differenceBetweenParentSplits),
        ),
        _paint,
      );

      ///
      /// Draw percentages text
      /// Note that (5 - i) to draw from bottom to top
      ///
      final currentPercentageValueParagraphView = (ui.ParagraphBuilder(
        ui.ParagraphStyle(
          fontSize:
              heightGreater ? ((size.width) * 0.08) : ((size.height) * 0.08),
          textAlign: TextAlign.justify,
        ),
      )
            ..pushStyle(
              ui.TextStyle(
                color: Colors.black,
              ),
            )
            ..addText('$currentPercentage.0'))
          .build()
        ..layout(
          ui.ParagraphConstraints(
            width: size.width,
          ),
        );

      canvas.drawParagraph(
        currentPercentageValueParagraphView,
        Offset(
          heightGreater
              ? centerPoint.dx + (size.width * 0.02)
              : centerPoint.dx + (size.height * 0.02),
          centerPoint.dy -
              (2 * differenceBetweenParentSplits) +
              ((5 - i) * differenceBetweenParentSplits) -
              (currentPercentageValueParagraphView.height * 0.5),
        ),
      );
    }

    _paint.strokeWidth =
        heightGreater ? size.width * 0.005 : size.height * 0.005;

    final differenceBetweenChildSplits = differenceBetweenParentSplits / 5.0;

    ///
    /// Draw secondary splits
    ///
    for (int i = 0; i < 25; i++) {
      switch (i) {
        case 0:
        case 5:
        case 10:
        case 15:
        case 20:
          continue;
        default:
          break;
      }

      canvas.drawLine(
        Offset(
          heightGreater
              ? centerPoint.dx - (size.width * 0.02)
              : centerPoint.dx - (size.height * 0.02),
          centerPoint.dy -
              (2 * differenceBetweenParentSplits) +
              (i * differenceBetweenChildSplits),
        ),
        Offset(
          heightGreater
              ? centerPoint.dx - (size.width * 0.06)
              : centerPoint.dx - (size.height * 0.06),
          centerPoint.dy -
              (2 * differenceBetweenParentSplits) +
              (i * differenceBetweenChildSplits),
        ),
        _paint,
      );
    }

    _paint.color = _getColorForValue(_value);
    _paint.strokeWidth = heightGreater ? size.width * 0.1 : size.height * 0.1;

    ///
    /// Draw progress histogram
    /// Note that line 164 we don't give a position because it will fail otherwise we give a maximum height
    ///
    canvas.drawLine(
      Offset(
        centerPoint.dx - (heightGreater ? size.width * 0.2 : size.height * 0.2),
        centerPoint.dy + (3 * differenceBetweenParentSplits),
      ),
      Offset(
        centerPoint.dx - (heightGreater ? size.width * 0.2 : size.height * 0.2),
        (centerPoint.dy - (2.0 * differenceBetweenParentSplits)) +
            ((5.0 * differenceBetweenParentSplits) * (1.0 - _value)),
      ),
      _paint,
    );

    ///
    /// Draw title percentage
    ///
    final titlePercentageValueParagraphView = (ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontSize: heightGreater ? ((size.width) * 0.2) : ((size.height) * 0.2),
        textAlign: TextAlign.justify,
      ),
    )
          ..pushStyle(
            ui.TextStyle(
              color: Colors.black,
            ),
          )
          ..addText('${(100.0 * _value).toStringAsFixed(1)} %'))
        .build()
      ..layout(
        ui.ParagraphConstraints(
          width: size.width,
        ),
      );

    canvas.drawParagraph(
      titlePercentageValueParagraphView,
      Offset(
        centerPoint.dx -
            (titlePercentageValueParagraphView.maxIntrinsicWidth * 0.5),
        centerPoint.dy - (3.5 * differenceBetweenParentSplits),
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
