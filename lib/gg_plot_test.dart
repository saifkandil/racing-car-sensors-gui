part of 'main.dart';

class GGView extends CustomPainter {
  final _paint = Paint();

  final Queue<Offset> _ggQueue;

  GGView({
    required Queue<Offset> ggQueue,
  }) : _ggQueue = ggQueue;

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

    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth =
        heightGreater ? size.width * 0.001 : size.height * 0.001;

    final smallestCircleRadius =
        (heightGreater ? size.width * 0.08 : size.height * 0.08).toInt();

    ///
    /// Draw 4 circles with ascending radii
    ///
    for (int i = 0, currentRadius = smallestCircleRadius;
        i < 4;
        i++, currentRadius += smallestCircleRadius) {
      canvas.drawCircle(
        centerPoint,
        currentRadius.toDouble(),
        _paint,
      );
    }

    ///
    /// Vertical line (y-axis)
    /// Note that we multiply by 4 here so that vertical line touches outer circle (biggest circle)
    ///
    canvas.drawLine(
      Offset(
        centerPoint.dx - (smallestCircleRadius * 4.0),
        centerPoint.dy + (smallestCircleRadius * 4.0),
      ),
      Offset(
        centerPoint.dx - (smallestCircleRadius * 4.0),
        centerPoint.dy - (smallestCircleRadius * 4.0),
      ),
      _paint,
    );

    ///
    /// Horizontal line (x-axis)
    /// Note that we multiply by 4 here so that horizontal line touches outer circle (biggest circle)
    ///
    canvas.drawLine(
      Offset(
        centerPoint.dx - (smallestCircleRadius * 4.0),
        centerPoint.dy + (smallestCircleRadius * 4.0),
      ),
      Offset(
        centerPoint.dx + (smallestCircleRadius * 4.0),
        centerPoint.dy + (smallestCircleRadius * 4.0),
      ),
      _paint,
    );

    ///
    /// Draw vertical line passing by center
    /// Note that we multiply by 4 here so that vertical line touches outer circle (biggest circle)
    ///
    canvas.drawLine(
      Offset(
        centerPoint.dx,
        centerPoint.dy - (smallestCircleRadius * 4.0),
      ),
      Offset(
        centerPoint.dx,
        centerPoint.dy + (smallestCircleRadius * 4.0),
      ),
      _paint,
    );

    ///
    /// Draw Horizontal line passing by center
    /// Note that we multiply by 4 here so that horizontal line touches outer circle (biggest circle)
    ///
    canvas.drawLine(
      Offset(
        centerPoint.dx - (smallestCircleRadius * 4.0),
        centerPoint.dy,
      ),
      Offset(
        centerPoint.dx + (smallestCircleRadius * 4.0),
        centerPoint.dy,
      ),
      _paint,
    );

    _paint.style = PaintingStyle.fill;

    ///
    /// This saves previous offset so that we can draw line between previous and current offsets
    /// Note that we saved first offset so we ignore it and move to the second
    ///
    Offset previousCenter = _ggQueue.first;

    canvas.drawCircle(
      Offset(
        centerPoint.dx + (previousCenter.dx * (smallestCircleRadius * 4.0)),
        centerPoint.dy + (previousCenter.dy * (smallestCircleRadius * 4.0)),
      ),
      heightGreater ? size.width * 0.01 : size.height * 0.01,
      _paint,
    );

    ///
    /// This variable helps ignore
    ///
    bool ignore = true;

    for (var currentCenter in _ggQueue) {
      ///
      /// This ignores first offset and draw first point and move path pointer to first offset
      ///
      switch (ignore) {
        case true:
          ignore = !ignore;
          continue;
        default:
          break;
      }

      canvas.drawCircle(
        Offset(
          centerPoint.dx + (currentCenter.dx * (smallestCircleRadius * 4.0)),
          centerPoint.dy + (currentCenter.dy * (smallestCircleRadius * 4.0)),
        ),
        heightGreater ? size.width * 0.01 : size.height * 0.01,
        _paint,
      );

      ///
      /// This draws line between previous and current offset
      ///
      canvas.drawLine(
        Offset(
          centerPoint.dx + (previousCenter.dx * (smallestCircleRadius * 4.0)),
          centerPoint.dy + (previousCenter.dy * (smallestCircleRadius * 4.0)),
        ),
        Offset(
          centerPoint.dx + (currentCenter.dx * (smallestCircleRadius * 4.0)),
          centerPoint.dy + (currentCenter.dy * (smallestCircleRadius * 4.0)),
        ),
        _paint,
      );

      previousCenter = currentCenter;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
