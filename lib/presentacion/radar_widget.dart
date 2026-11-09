import 'package:flutter/material.dart';

class RadarWidget extends StatelessWidget {
  final List<(double, double)> puntos;
  final double tamano;

  const RadarWidget({
    super.key,
    required this.puntos,
    this.tamano = 110,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamano,
      height: tamano,
      child: CustomPaint(
        painter: _RadarPainter(puntos),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<(double, double)> puntos;

  _RadarPainter(this.puntos);

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final radio = size.width / 2;

    canvas.drawCircle(
      centro,
      radio,
      Paint()..color = Colors.black54,
    );

    final linea = Paint()
      ..color = Colors.greenAccent.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(centro, radio, linea);
    canvas.drawCircle(centro, radio / 2, linea);

    canvas.drawLine(
      Offset(centro.dx, 0),
      Offset(centro.dx, size.height),
      linea,
    );

    canvas.drawLine(
      Offset(0, centro.dy),
      Offset(size.width, centro.dy),
      linea,
    );

    final yo = Path()
      ..moveTo(centro.dx, centro.dy - 7)
      ..lineTo(centro.dx - 5, centro.dy + 5)
      ..lineTo(centro.dx + 5, centro.dy + 5)
      ..close();

    canvas.drawPath(
      yo,
      Paint()..color = Colors.white,
    );

    for (final (x, y) in puntos) {
      canvas.drawCircle(
        Offset(
          centro.dx + x * (radio - 6),
          centro.dy + y * (radio - 6),
        ),
        5,
        Paint()..color = Colors.orangeAccent,
      );
    }
  }

  @override
  bool shouldRepaint(_RadarPainter viejo) =>
      viejo.puntos != puntos;
}