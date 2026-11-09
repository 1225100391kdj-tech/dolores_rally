import 'aparicion.dart';
import 'geo.dart';

class Visible {
  final Aparicion aparicion;
  final double distancia;
  final double x;
  final double profundidad;
  final double escala;

  const Visible(
    this.aparicion,
    this.distancia,
    this.x,
    this.profundidad,
    this.escala,
  );
}

List<Visible> calcularVisibles({
  required Coordenada usuario,
  required double rumbo,
  required Iterable<Aparicion> apariciones,
  double campoVision = 60,
  double radioMax = 600,
}) {
  final res = <Visible>[];

  for (final a in apariciones) {
    final d = distanciaMetros(
      usuario,
      a.coordenada,
    );

    if (d > radioMax) continue;

    final dif = diferenciaAngular(
      rumboGrados(usuario, a.coordenada),
      rumbo,
    );

    final x = posicionHorizontal(
      dif,
      campoVision: campoVision,
    );

    if (x == null) continue;

    final prof =
        (d / radioMax).clamp(0.0, 1.0).toDouble();

    res.add(
      Visible(
        a,
        d,
        x,
        prof,
        1.2 - 0.6 * prof,
      ),
    );
  }

  res.sort(
    (a, b) => b.distancia.compareTo(a.distancia),
  );

  return res;
}