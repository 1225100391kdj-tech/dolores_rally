import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../dominio/almacen.dart';
import '../dominio/aparicion.dart';
import '../dominio/excepciones.dart';
import '../dominio/fuentes.dart';
import '../dominio/geo.dart';
import '../dominio/motor_ar.dart';
import '../dominio/partida.dart';
import '../dominio/personaje.dart';
import '../dominio/radar.dart';

class RallyViewModel extends ChangeNotifier {
  static const double limiteLejos = 3000;

  final FuentePosicion _posicion;
  final FuenteBrujula _brujula;
  final AlmacenColeccion _almacen;

  final Coordenada centro;
  final double campoVision;
  final double radioMax;

  late final Partida partida;

  RallyViewModel({
    required FuentePosicion posicion,
    required FuenteBrujula brujula,
    required AlmacenColeccion almacen,
    required List<Personaje> personajes,
    required this.centro,
    required math.Random random,
    this.campoVision = 60,
    this.radioMax = 600,
  })  : _posicion = posicion,
        _brujula = brujula,
        _almacen = almacen {
    partida = Partida(
      generarApariciones(
        centro: centro,
        personajes: personajes,
        random: random,
        radioMax: 500,
      ),
      reubicar: () => puntoAleatorio(
        centro,
        60,
        500,
        random,
      ),
    );
  }

  Coordenada? usuario;
  double? rumbo;

  List<Visible> visibles = [];
  String? error;

  StreamSubscription<Coordenada>? _subPos;
  StreamSubscription<double>? _subBru;

  bool get esperando =>
      usuario == null || rumbo == null;

  bool get lejosDeDolores =>
      usuario != null &&
      distanciaMetros(usuario!, centro) > limiteLejos;

  Aparicion? get masCercano {
    final u = usuario;

    if (u == null || partida.pendientes.isEmpty) {
      return null;
    }

    final lista = [...partida.pendientes];

    lista.sort(
      (a, b) => distanciaMetros(
        u,
        a.coordenada,
      ).compareTo(
        distanciaMetros(u, b.coordenada),
      ),
    );

    return lista.first;
  }

  double? get distanciaAlMasCercano {
    final c = masCercano;

    if (c == null || usuario == null) {
      return null;
    }

    return distanciaMetros(
      usuario!,
      c.coordenada,
    );
  }

  Temperatura? get temperatura {
    final d = distanciaAlMasCercano;
    return d == null ? null : temperaturaPorDistancia(d);
  }

  List<(double, double)> get puntosRadar {
    final u = usuario;
    final r = rumbo;

    if (u == null || r == null) {
      return const [];
    }

    return [
      for (final a in partida.pendientes)
        if (puntoEnRadar(
          usuario: u,
          rumbo: r,
          objetivo: a.coordenada,
          alcance: radioMax,
        ) case final p?)
          p,
    ];
  }

  Future<void> iniciar() async {
    partida.restaurar(
      await _almacen.cargarCapturados(),
    );

    _subPos = _posicion.posiciones.listen(
      (p) {
        usuario = p;
        _recalcular();
      },
      onError: _alFallar,
    );

    _subBru = _brujula.rumbos.listen(
      (g) {
        rumbo = rumbo == null
            ? g
            : suavizarAngulo(rumbo!, g);

        _recalcular();
      },
      onError: _alFallar,
    );

    notifyListeners();
  }

  void _alFallar(Object e) {
    error = mensajeSeguro(e);
    notifyListeners();
  }

  void _recalcular() {
    final u = usuario;
    final r = rumbo;

    if (u != null && r != null) {
      visibles = calcularVisibles(
        usuario: u,
        rumbo: r,
        apariciones: partida.pendientes,
        campoVision: campoVision,
        radioMax: radioMax,
      );
    }

    notifyListeners();
  }

  Future<ResultadoCaptura> capturar(
    String id,
    int opcion,
  ) async {
    final u = usuario;

    Aparicion? aparicion;

    for (final a in partida.todas) {
      if (a.personaje.id == id) {
        aparicion = a;
        break;
      }
    }

    final d = u == null || aparicion == null
        ? double.infinity
        : distanciaMetros(
            u,
            aparicion.coordenada,
          );

    final resultado = partida.capturar(
      id,
      opcion,
      d,
    );

    if (resultado is Capturado) {
      await _almacen.guardarCapturados(
        partida.capturados,
      );

      if (partida.puntos >
          await _almacen.cargarMejorPuntaje()) {
        await _almacen.guardarMejorPuntaje(
          partida.puntos,
        );
      }
    }

    _recalcular();
    return resultado;
  }

  @override
  void dispose() {
    _subPos?.cancel();
    _subBru?.cancel();
    super.dispose();
  }
}