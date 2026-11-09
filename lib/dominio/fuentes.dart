import 'geo.dart';

abstract class FuentePosicion {
  Stream<Coordenada> get posiciones;
}

abstract class FuenteBrujula {
  Stream<double> get rumbos;
}