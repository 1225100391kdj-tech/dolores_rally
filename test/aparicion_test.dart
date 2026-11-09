import 'dart:math';

import 'package:dolores_rally/dominio/aparicion.dart';
import 'package:dolores_rally/dominio/catalogo.dart';
import 'package:dolores_rally/dominio/geo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

void main() {
  test('genera una aparición por personaje', () {
    final a = generarApariciones(
      centro: origen,
      personajes: personajes,
      random: Random(1),
    );

    expect(a.length, personajes.length);

    expect(
      a.map((x) => x.personaje.id).toSet().length,
      personajes.length,
    );
  });

  test('todas están entre 60 y 500 metros', () {
    final a = generarApariciones(
      centro: origen,
      personajes: personajes,
      random: Random(7),
      radioMin: 60,
      radioMax: 500,
    );

    for (final x in a) {
      final d = distanciaMetros(
        origen,
        x.coordenada,
      );

      expect(
        d,
        inInclusiveRange(59.9, 500.1),
      );
    }
  });

  test('el mismo azar se repite con una semilla', () {
    final a = generarApariciones(
      centro: origen,
      personajes: personajes,
      random: Random(42),
    );

    final b = generarApariciones(
      centro: origen,
      personajes: personajes,
      random: Random(42),
    );

    for (var i = 0; i < a.length; i++) {
      expect(
        a[i].coordenada.lat,
        b[i].coordenada.lat,
      );

      expect(
        a[i].coordenada.lon,
        b[i].coordenada.lon,
      );
    }
  });

  test('semillas distintas generan lugares distintos', () {
    final a = generarApariciones(
      centro: origen,
      personajes: personajes,
      random: Random(1),
    );

    final b = generarApariciones(
      centro: origen,
      personajes: personajes,
      random: Random(2),
    );

    expect(
      a.first.coordenada.lat,
      isNot(b.first.coordenada.lat),
    );
  });

  test('los puntos se reparten por los cuadrantes', () {
    final r = Random(5);

    final rumbos = [
      for (var i = 0; i < 400; i++)
        rumboGrados(
          origen,
          puntoAleatorio(
            origen,
            60,
            500,
            r,
          ),
        ),
    ];

    for (final cuadrante in [0, 90, 180, 270]) {
      expect(
        rumbos.where(
          (g) =>
              g >= cuadrante &&
              g < cuadrante + 90,
        ).length,
        greaterThan(60),
      );
    }
  });
}