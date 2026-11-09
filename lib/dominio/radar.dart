import 'dart:math' as math;

import 'geo.dart';

(double, double)? puntoEnRadar({
  required Coordenada usuario,
  required double rumbo,
  required Coordenada objetivo,
  double alcance = 500,
}) {
  final d = distanciaMetros(usuario, objetivo);

  if (d > alcance) return null;

  final dif = diferenciaAngular(
        rumboGrados(usuario, objetivo),
        rumbo,
      ) *
      math.pi /
      180;

  final f = d / alcance;

  return (
    f * math.sin(dif),
    -f * math.cos(dif),
  );
}

enum Temperatura {
  helado,
  frio,
  tibio,
  caliente,
  ardiente
}

Temperatura temperaturaPorDistancia(double metros) {
  if (metros <= 15) return Temperatura.ardiente;
  if (metros <= 50) return Temperatura.caliente;
  if (metros <= 150) return Temperatura.tibio;
  if (metros <= 400) return Temperatura.frio;
  return Temperatura.helado;
}

extension TextoTemperatura on Temperatura {
  String get texto => switch (this) {
        Temperatura.helado => '🥶 Helado',
        Temperatura.frio => '❄️ Frío',
        Temperatura.tibio => '🙂 Tibio',
        Temperatura.caliente => '🔥 Caliente',
        Temperatura.ardiente => '🌋 ¡Ardiendo! Atrápalo',
      };
}