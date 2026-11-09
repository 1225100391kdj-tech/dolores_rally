import 'package:dolores_rally/dominio/aparicion.dart';
import 'package:dolores_rally/dominio/geo.dart';
import 'package:dolores_rally/dominio/motor_ar.dart';
import 'package:dolores_rally/dominio/personaje.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

Aparicion en(
  String id,
  double rumbo,
  double metros,
) {
  return Aparicion(
    Personaje(
      id: id,
      nombre: id,
      emoji: '🎯',
      bio: '',
      pregunta: const Pregunta(
        '?',
        ['a', 'b'],
        0,
      ),
    ),
    destino(origen, rumbo, metros),
  );
}

void main() {
  test('personaje adelante aparece en el centro', () {
    final v = calcularVisibles(
      usuario: origen,
      rumbo: 0,
      apariciones: [
        en('a', 0, 100),
      ],
    );

    expect(v.single.x, closeTo(0.5, 0.01));

    expect(
      v.single.distancia,
      closeTo(100, 0.5),
    );
  });

  test('al girar aparece el personaje', () {
    final a = en('a', 90, 100);

    expect(
      calcularVisibles(
        usuario: origen,
        rumbo: 0,
        apariciones: [a],
      ),
      isEmpty,
    );

    expect(
      calcularVisibles(
        usuario: origen,
        rumbo: 90,
        apariciones: [a],
      ),
      hasLength(1),
    );
  });

  test('funciona al cruzar el norte', () {
    final v = calcularVisibles(
      usuario: origen,
      rumbo: 350,
      apariciones: [
        en('a', 5, 100),
      ],
    );

    expect(v, hasLength(1));
    expect(v.single.x, greaterThan(0.5));
  });

  test('personajes lejanos aparecen primero', () {
    final v = calcularVisibles(
      usuario: origen,
      rumbo: 0,
      apariciones: [
        en('cerca', 0, 40),
        en('lejos', 0, 450),
      ],
    );

    expect(
      v.map((x) => x.aparicion.personaje.id),
      ['lejos', 'cerca'],
    );

    expect(
      v.last.escala,
      greaterThan(v.first.escala),
    );
  });

  test('personaje fuera de rango se descarta', () {
    final v = calcularVisibles(
      usuario: origen,
      rumbo: 0,
      apariciones: [
        en('a', 0, 900),
      ],
      radioMax: 600,
    );

    expect(v, isEmpty);
  });
}