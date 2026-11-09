import 'package:flutter/material.dart';

import '../dominio/almacen.dart';
import '../dominio/personaje.dart';

class PantallaColeccion extends StatelessWidget {
  final AlmacenColeccion almacen;
  final List<Personaje> personajes;

  const PantallaColeccion({
    super.key,
    required this.almacen,
    required this.personajes,
  });

  Future<(Set<String>, int)> _cargar() async {
    return (
      await almacen.cargarCapturados(),
      await almacen.cargarMejorPuntaje(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi álbum'),
      ),
      body: FutureBuilder<(Set<String>, int)>(
        future: _cargar(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final (ids, mejor) = snap.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '🏅 ${ids.length}/${personajes.length} '
                  '· ⭐ Mejor puntaje: $mejor',
                ),
              ),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(12),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    for (final p in personajes)
                      _Carta(
                        personaje: p,
                        desbloqueado: ids.contains(p.id),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Carta extends StatelessWidget {
  final Personaje personaje;
  final bool desbloqueado;

  const _Carta({
    required this.personaje,
    required this.desbloqueado,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: desbloqueado
          ? null
          : Colors.grey.shade300,
      child: InkWell(
        onTap: desbloqueado
            ? () {
                showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(
                      '${personaje.emoji} ${personaje.nombre}',
                    ),
                    content: Text(personaje.bio),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                desbloqueado
                    ? personaje.emoji
                    : '❓',
                style: const TextStyle(
                  fontSize: 48,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                desbloqueado
                    ? personaje.nombre
                    : 'Por descubrir',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}