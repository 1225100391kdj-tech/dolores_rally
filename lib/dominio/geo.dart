
import 'dart:math' as math;

class Coordenada {
  final double lat;
  final double lon;

  const Coordenada(this.lat, this.lon);

  @override
  String toString() =>
      '(${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)})';
}

const double _radioTierra = 6371000.0;

double _rad(double grados) => grados * math.pi / 180;

double _grados(double rad) => rad * 180 / math.pi;

// Calcula la distancia entre dos coordenadas GPS.
double distanciaMetros(Coordenada a, Coordenada b) {
  final dLat = _rad(b.lat - a.lat);
  final dLon = _rad(b.lon - a.lon);

  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(a.lat)) *
          math.cos(_rad(b.lat)) *
          math.pow(math.sin(dLon / 2), 2);

  return 2 *
      _radioTierra *
      math.asin(
        math.sqrt(h.clamp(0.0, 1.0).toDouble()),
      );
}

// Calcula el rumbo entre dos coordenadas.
double rumboGrados(Coordenada a, Coordenada b) {
  final dLon = _rad(b.lon - a.lon);
  final lat1 = _rad(a.lat);
  final lat2 = _rad(b.lat);

  final y = math.sin(dLon) * math.cos(lat2);

  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) *
          math.cos(lat2) *
          math.cos(dLon);

  return normalizar360(
    _grados(math.atan2(y, x)),
  );
}

// Normaliza los ángulos entre 0° y 360°.
// Corrige pequeños errores de precisión decimal.
double normalizar360(double g) {
  final resultado = ((g % 360) + 360) % 360;

  if (resultado > 359.999999) {
    return 0.0;
  }

  return resultado;
}

// Calcula la diferencia angular más corta.
double diferenciaAngular(
  double objetivo,
  double actual,
) {
  var d = normalizar360(objetivo - actual);

  if (d > 180) {
    d -= 360;
  }

  return d;
}

// Suaviza los cambios de dirección de la brújula.
double suavizarAngulo(
  double anterior,
  double nuevo, {
  double alfa = 0.2,
}) {
  return normalizar360(
    anterior +
        alfa * diferenciaAngular(
          nuevo,
          anterior,
        ),
  );
}

// Calcula la posición horizontal en pantalla.
double? posicionHorizontal(
  double diferencia, {
  double campoVision = 60,
}) {
  if (diferencia.abs() > campoVision / 2) {
    return null;
  }

  return 0.5 + diferencia / campoVision;
}

// Convierte distancias a metros o kilómetros.
String formatearDistancia(double metros) {
  if (metros < 1000) {
    return '${metros.round()} m';
  }

  return '${(metros / 1000).toStringAsFixed(1)} km';
}

// Obtiene el punto cardinal correspondiente.
String nombreCardinal(double grados) {
  const puntos = [
    'N',
    'NE',
    'E',
    'SE',
    'S',
    'SO',
    'O',
    'NO',
  ];

  return puntos[
      ((normalizar360(grados) + 22.5) ~/ 45) % 8];
}

// Calcula la coordenada de destino al caminar
// una distancia en una dirección determinada.
Coordenada destino(
  Coordenada origen,
  double rumbo,
  double metros,
) {
  final d = metros / _radioTierra;
  final br = _rad(rumbo);

  final lat1 = _rad(origen.lat);
  final lon1 = _rad(origen.lon);

  final lat2 = math.asin(
    math.sin(lat1) * math.cos(d) +
        math.cos(lat1) *
            math.sin(d) *
            math.cos(br),
  );

  final lon2 = lon1 +
      math.atan2(
        math.sin(br) *
            math.sin(d) *
            math.cos(lat1),
        math.cos(d) -
            math.sin(lat1) *
                math.sin(lat2),
      );

  return Coordenada(
    _grados(lat2),
    ((_grados(lon2) + 540) % 360) - 180,
  );
}
