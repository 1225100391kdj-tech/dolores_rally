import 'dart:math' as math;

import 'geo.dart';
import 'personaje.dart';

class Aparicion {
  final Personaje personaje;
  final Coordenada coordenada;

  const Aparicion(this.personaje, this.coordenada);
}

Coordenada puntoAleatorio(
  Coordenada centro,
  double min,
  double max,
  math.Random random,
) {
  final distancia = math.sqrt(
    min * min +
        random.nextDouble() * (max * max - min * min),
  );

  return destino(
    centro,
    random.nextDouble() * 360,
    distancia,
  );
}

List<Aparicion> generarApariciones({
  required Coordenada centro,
  required List<Personaje> personajes,
  required math.Random random,
  double radioMin = 60,
  double radioMax = 500,
}) =>
    [
      for (final p in personajes)
        Aparicion(
          p,
          puntoAleatorio(
            centro,
            radioMin,
            radioMax,
            random,
          ),
        ),
    ];