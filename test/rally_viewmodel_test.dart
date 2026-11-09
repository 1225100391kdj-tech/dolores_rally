import 'dart:async';
import 'dart:math';

import 'package:dolores_rally/dominio/almacen.dart';
import 'package:dolores_rally/dominio/catalogo.dart';
import 'package:dolores_rally/dominio/excepciones.dart';
import 'package:dolores_rally/dominio/fuentes.dart';
import 'package:dolores_rally/dominio/geo.dart';
import 'package:dolores_rally/dominio/partida.dart';
import 'package:dolores_rally/dominio/radar.dart';
import 'package:dolores_rally/presentacion/rally_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

class PosicionFalsa implements FuentePosicion {
  final c =
      StreamController<Coordenada>.broadcast();

  @override
  Stream<Coordenada> get posiciones => c.stream;
}

class BrujulaFalsa implements FuenteBrujula {
  final c =
      StreamController<double>.broadcast();

  @override
  Stream<double> get rumbos => c.stream;
}

void main() {
  late PosicionFalsa gps;
  late BrujulaFalsa brujula;
  late AlmacenMemoria almacen;

  Future<RallyViewModel> crear() async {
    gps = PosicionFalsa();
    brujula = BrujulaFalsa();
    almacen = AlmacenMemoria();

    final vm = RallyViewModel(
      posicion: gps,
      brujula: brujula,
      almacen: almacen,
      personajes: personajes,
      centro: origen,
      random: Random(42),
    );

    await vm.iniciar();
    return vm;
  }

  test('espera GPS y brújula', () async {
    final vm = await crear();

    expect(vm.esperando, true);

    gps.c.add(origen);
    await pumpEventQueue();

    expect(vm.esperando, true);

    vm.dispose();
  });

  test('GPS y brújula calculan el radar', () async {
    final vm = await crear();

    gps.c.add(origen);
    brujula.c.add(0);

    await pumpEventQueue();

    expect(vm.esperando, false);
    expect(vm.temperatura, isNotNull);
    expect(vm.puntosRadar, isNotEmpty);

    vm.dispose();
  });

  test('detecta el personaje más cercano', () async {
    final vm = await crear();

    final objetivo = vm.partida.todas.first;

    gps.c.add(
      destino(
        objetivo.coordenada,
        90,
        8,
      ),
    );

    brujula.c.add(0);

    await pumpEventQueue();

    expect(
      vm.masCercano!.personaje.id,
      objetivo.personaje.id,
    );

    expect(
      vm.temperatura,
      Temperatura.ardiente,
    );

    vm.dispose();
  });

  test('capturar suma puntos y guarda progreso', () async {
    final vm = await crear();

    final objetivo = vm.partida.todas.first;

    gps.c.add(
      destino(
        objetivo.coordenada,
        0,
        5,
      ),
    );

    brujula.c.add(0);

    await pumpEventQueue();

    final correcta =
        objetivo.personaje.pregunta.correcta;

    final r = await vm.capturar(
      objetivo.personaje.id,
      correcta,
    );

    expect(r, isA<Capturado>());
    expect(vm.partida.puntos, 100);

    expect(
      await almacen.cargarCapturados(),
      {objetivo.personaje.id},
    );

    expect(
      await almacen.cargarMejorPuntaje(),
      100,
    );

    vm.dispose();
  });

  test('no permite captura desde lejos', () async {
    final vm = await crear();

    gps.c.add(origen);
    brujula.c.add(0);

    await pumpEventQueue();

    final objetivo = vm.partida.todas.first;

    await expectLater(
      vm.capturar(
        objetivo.personaje.id,
        0,
      ),
      throwsA(isA<LejosException>()),
    );

    expect(
      await almacen.cargarCapturados(),
      isEmpty,
    );

    vm.dispose();
  });

  test('restaura el progreso almacenado', () async {
    gps = PosicionFalsa();
    brujula = BrujulaFalsa();
    almacen = AlmacenMemoria();

    await almacen.guardarCapturados(
      {'hidalgo'},
    );

    final vm = RallyViewModel(
      posicion: gps,
      brujula: brujula,
      almacen: almacen,
      personajes: personajes,
      centro: origen,
      random: Random(1),
    );

    await vm.iniciar();

    expect(
      vm.partida.estaCapturado('hidalgo'),
      true,
    );

    expect(
      vm.partida.pendientes.length,
      personajes.length - 1,
    );

    vm.dispose();
  });

  test('detecta si estás lejos de Dolores', () async {
    final vm = await crear();

    gps.c.add(
      destino(origen, 0, 5000),
    );

    brujula.c.add(0);

    await pumpEventQueue();

    expect(vm.lejosDeDolores, true);

    vm.dispose();
  });

  test('muestra errores de permiso', () async {
    final vm = await crear();

    gps.c.addError(
      const PermisoUbicacionException(),
    );

    await pumpEventQueue();

    expect(
      vm.error,
      contains('permiso'),
    );

    vm.dispose();
  });

  test('protege los detalles de errores internos', () async {
    final vm = await crear();

    brujula.c.addError(
      StateError('fallo en /sensores/mag.dart'),
    );

    await pumpEventQueue();

    expect(
      vm.error,
      isNot(contains('/sensores')),
    );

    expect(
      vm.error,
      contains('inesperado'),
    );

    vm.dispose();
  });
}