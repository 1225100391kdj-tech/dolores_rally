import 'package:dolores_rally/dominio/aparicion.dart';
import 'package:dolores_rally/dominio/excepciones.dart';
import 'package:dolores_rally/dominio/geo.dart';
import 'package:dolores_rally/dominio/partida.dart';
import 'package:dolores_rally/dominio/personaje.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

const _p = Personaje(
  id: 'x',
  nombre: 'Personaje X',
  emoji: '🎯',
  bio: '',
  pregunta: Pregunta(
    '¿2+2?',
    ['3', '4', '5'],
    1,
  ),
);

const _escondite = Coordenada(21.2, -100.9);

Partida crear({
  List<Coordenada>? reubicaciones,
}) {
  final cola = [...?reubicaciones];

  return Partida(
    [
      Aparicion(_p, origen),
    ],
    reubicar: () =>
        cola.isEmpty ? _escondite : cola.removeAt(0),
  );
}

void main() {
  test('captura correcta obtiene 100 puntos', () {
    final partida = crear();

    final r = partida.capturar('x', 1, 10);

    expect(r, isA<Capturado>());
    expect((r as Capturado).puntos, 100);
    expect(partida.puntos, 100);
    expect(partida.estaCapturado('x'), true);
    expect(partida.terminada, true);
  });

  test('no captura si está lejos', () {
    final partida = crear();

    expect(
      () => partida.capturar('x', 1, 80),
      throwsA(isA<LejosException>()),
    );

    expect(partida.puntos, 0);
  });

  test('a 15 metros puede capturarse', () {
    expect(
      crear().capturar('x', 1, 15),
      isA<Capturado>(),
    );
  });

  test('respuesta incorrecta da otra oportunidad', () {
    final partida = crear();

    final r = partida.capturar('x', 0, 5);

    expect(r, isA<Fallo>());

    expect(
      (r as Fallo).intentosRestantes,
      1,
    );

    expect(partida.estaCapturado('x'), false);
  });

  test('segundo intento correcto vale 50', () {
    final partida = crear();

    partida.capturar('x', 0, 5);

    final r =
        partida.capturar('x', 1, 5) as Capturado;

    expect(r.puntos, 50);
  });

  test('dos errores hacen huir al personaje', () {
    final partida = crear(
      reubicaciones: [
        const Coordenada(21.3, -100.8),
      ],
    );

    partida.capturar('x', 0, 5);

    final r = partida.capturar('x', 2, 5);

    expect(r, isA<SeEscapo>());

    final nueva =
        (r as SeEscapo).nuevaPosicion;

    expect(nueva.lat, 21.3);

    expect(
      partida.pendientes.single.coordenada.lat,
      21.3,
    );
  });

  test('al escaparse se reinician los fallos', () {
    final partida = crear();

    partida.capturar('x', 0, 5);
    partida.capturar('x', 0, 5);

    final r = partida.capturar('x', 0, 5);

    expect(r, isA<Fallo>());
  });

  test('no se captura dos veces', () {
    final partida = crear();

    partida.capturar('x', 1, 5);

    expect(
      () => partida.capturar('x', 1, 5),
      throwsA(isA<YaCapturadoException>()),
    );

    expect(partida.puntos, 100);
  });

  test('personaje desconocido produce error', () {
    expect(
      () => crear().capturar('nadie', 0, 5),
      throwsA(
        isA<PersonajeDesconocidoException>(),
      ),
    );
  });

  test('restaurar progreso guardado', () {
    final partida = crear();

    partida.restaurar([
      'x',
      'fantasma',
    ]);

    expect(partida.capturados, {'x'});
    expect(partida.pendientes, isEmpty);
  });
}