import 'dart:async';

import '../dominio/fuentes.dart';
import '../dominio/geo.dart';

class PosicionSimulada implements FuentePosicion {
  Coordenada _actual;

  final _controlador =
      StreamController<Coordenada>.broadcast();

  PosicionSimulada(this._actual);

  @override
  Stream<Coordenada> get posiciones async* {
    yield _actual;
    yield* _controlador.stream;
  }

  void avanzar(double rumbo, double metros) {
    _actual = metros >= 0
        ? destino(_actual, rumbo, metros)
        : destino(_actual, rumbo + 180, -metros);

    _controlador.add(_actual);
  }

  void cerrar() => _controlador.close();
}

class BrujulaSimulada implements FuenteBrujula {
  final _controlador =
      StreamController<double>.broadcast();

  double _ultimo = 0;

  @override
  Stream<double> get rumbos async* {
    yield _ultimo;
    yield* _controlador.stream;
  }

  void girar(double grados) {
    _ultimo = grados;
    _controlador.add(grados);
  }

  void cerrar() => _controlador.close();
}