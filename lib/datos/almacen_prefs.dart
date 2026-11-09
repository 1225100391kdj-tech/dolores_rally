import 'package:shared_preferences/shared_preferences.dart';

import '../dominio/almacen.dart';

class AlmacenPrefs implements AlmacenColeccion {
  static const _claveIds = 'capturados';
  static const _claveMejor = 'mejor_puntaje';

  @override
  Future<Set<String>> cargarCapturados() async {
    final p = await SharedPreferences.getInstance();

    return (p.getStringList(_claveIds) ??
            const <String>[])
        .toSet();
  }

  @override
  Future<void> guardarCapturados(
    Set<String> ids,
  ) async {
    final p = await SharedPreferences.getInstance();

    await p.setStringList(
      _claveIds,
      ids.toList(),
    );
  }

  @override
  Future<int> cargarMejorPuntaje() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_claveMejor) ?? 0;
  }

  @override
  Future<void> guardarMejorPuntaje(
    int puntos,
  ) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_claveMejor, puntos);
  }
}