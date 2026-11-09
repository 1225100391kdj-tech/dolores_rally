abstract class AlmacenColeccion {
  Future<Set<String>> cargarCapturados();

  Future<void> guardarCapturados(Set<String> ids);

  Future<int> cargarMejorPuntaje();

  Future<void> guardarMejorPuntaje(int puntos);
}

class AlmacenMemoria implements AlmacenColeccion {
  Set<String> _ids = {};
  int _mejor = 0;

  @override
  Future<Set<String>> cargarCapturados() async =>
      {..._ids};

  @override
  Future<void> guardarCapturados(Set<String> ids) async {
    _ids = {...ids};
  }

  @override
  Future<int> cargarMejorPuntaje() async => _mejor;

  @override
  Future<void> guardarMejorPuntaje(int puntos) async {
    _mejor = puntos;
  }
}