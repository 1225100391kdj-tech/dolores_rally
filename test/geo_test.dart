import 'package:dolores_rally/dominio/geo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

void main() {
  group('destino', () {
    test('100 m al norte', () {
      final d = destino(origen, 0, 100);

      expect(
        distanciaMetros(origen, d),
        closeTo(100, 0.01),
      );

      expect(
        rumboGrados(origen, d),
        closeTo(0, 0.01),
      );
    });

    test('ida y vuelta en todas las direcciones', () {
      for (final rumbo in [
        0.0,
        45.0,
        90.0,
        135.0,
        180.0,
        225.0,
        270.0,
        315.0,
        359.0,
      ]) {
        final d = destino(origen, rumbo, 250);

        expect(
          distanciaMetros(origen, d),
          closeTo(250, 0.05),
          reason: 'rumbo $rumbo',
        );

        expect(
          diferenciaAngular(
            rumboGrados(origen, d),
            rumbo,
          ).abs(),
          lessThan(0.05),
        );
      }
    });

    test('0 metros conserva el punto', () {
      final d = destino(origen, 123, 0);

      expect(
        distanciaMetros(origen, d),
        closeTo(0, 1e-6),
      );
    });
  });

  group('funciones geográficas', () {
    test('distancia por latitud', () {
      expect(
        distanciaMetros(
          const Coordenada(0, 0),
          const Coordenada(1, 0),
        ),
        closeTo(111195, 5),
      );
    });

    test('diferenciaAngular cruza el norte', () {
      expect(diferenciaAngular(10, 350), 20);
      expect(diferenciaAngular(350, 10), -20);
    });

    test('suavizarAngulo cruza 350 a 10', () {
      expect(
        suavizarAngulo(
          350,
          10,
          alfa: 0.5,
        ),
        closeTo(0, 1e-9),
      );
    });

    test('posicionHorizontal', () {
      expect(posicionHorizontal(0), 0.5);

      expect(
        posicionHorizontal(30),
        closeTo(1.0, 1e-9),
      );

      expect(posicionHorizontal(31), isNull);
    });
  });
}