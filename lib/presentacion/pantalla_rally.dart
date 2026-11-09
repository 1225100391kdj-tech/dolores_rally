import 'package:flutter/material.dart';

import '../dominio/excepciones.dart';
import '../dominio/geo.dart';
import '../dominio/motor_ar.dart';
import '../dominio/partida.dart';
import '../dominio/personaje.dart';
import '../dominio/radar.dart';

import 'fondo_camara.dart';
import 'radar_widget.dart';
import 'rally_viewmodel.dart';

class PantallaRally extends StatefulWidget {
  final RallyViewModel Function() crearVm;
  final Widget? controlesDemo;

  const PantallaRally({
    super.key,
    required this.crearVm,
    this.controlesDemo,
  });

  @override
  State<PantallaRally> createState() =>
      _PantallaRallyState();
}

class _PantallaRallyState extends State<PantallaRally> {
  late final RallyViewModel vm = widget.crearVm();

  @override
  void initState() {
    super.initState();
    vm.iniciar();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: vm,
        builder: (_, __) => Stack(
          fit: StackFit.expand,
          children: [
            const FondoCamara(),

            LayoutBuilder(
              builder: (_, caja) => Stack(
                children: [
                  for (final v in vm.visibles)
                    _personaje(v, caja),
                ],
              ),
            ),

            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _marcador(),
                ),
              ),
            ),

            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: RadarWidget(
                    puntos: vm.puntosRadar,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _panelInferior(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _marcador() {
    final texto = vm.error ??
        (vm.esperando
            ? 'Buscando GPS y brújula…'
            : vm.lejosDeDolores
                ? '📍 Estás lejos de Dolores Hidalgo: usa el modo demo'
                : '${nombreCardinal(vm.rumbo!)} '
                    '${vm.rumbo!.round()}°\n'
                    '🏅 ${vm.partida.capturados.length}/'
                    '${vm.partida.todas.length} · '
                    '⭐ ${vm.partida.puntos}\n'
                    '${vm.temperatura?.texto ?? "🎉 ¡Los atrapaste a todos!"}');

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 220,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: vm.error != null
            ? Colors.red.shade800
            : Colors.black54,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _personaje(
    Visible v,
    BoxConstraints caja,
  ) {
    const ancho = 130.0;

    final alAlcance =
        v.distancia <= Partida.radioCaptura;

    return Positioned(
      left: v.x * caja.maxWidth - ancho / 2,
      top: caja.maxHeight *
          (0.50 - 0.28 * v.profundidad),
      width: ancho,
      child: Transform.scale(
        scale: v.escala,
        child: GestureDetector(
          onTap: () => _intentar(v),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.85),
                  border: Border.all(
                    color: alAlcance
                        ? Colors.greenAccent
                        : Colors.white,
                    width: 4,
                  ),
                ),
                child: Text(
                  v.aparicion.personaje.emoji,
                  style: const TextStyle(
                    fontSize: 44,
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Text(
                  alAlcance
                      ? '¡Tócame!'
                      : formatearDistancia(v.distancia),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panelInferior() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.controlesDemo != null)
          widget.controlesDemo!,
      ],
    );
  }

  Future<void> _intentar(Visible v) async {
    final p = v.aparicion.personaje;

    if (v.distancia > Partida.radioCaptura) {
      _aviso(
        LejosException(v.distancia).toString(),
      );
      return;
    }

    final opcion = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DialogoPregunta(
        personaje: p,
      ),
    );

    if (opcion == null) return;

    try {
      final r = await vm.capturar(
        p.id,
        opcion,
      );

      switch (r) {
        case Capturado(:final puntos):
          _aviso(
            '🎉 ¡Atrapaste a ${p.nombre}! '
            '+$puntos puntos\n${p.bio}',
          );

        case Fallo(:final intentosRestantes):
          _aviso(
            '❌ Respuesta incorrecta. '
            'Te queda $intentosRestantes intento.',
          );

        case SeEscapo():
          _aviso(
            '💨 ¡${p.nombre} se escapó! '
            'Búscalo en otro lugar.',
          );
      }
    } catch (e) {
      _aviso(mensajeSeguro(e));
    }
  }

  void _aviso(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

class _DialogoPregunta extends StatelessWidget {
  final Personaje personaje;

  const _DialogoPregunta({
    required this.personaje,
  });

  @override
  Widget build(BuildContext context) {
    final q = personaje.pregunta;

    return AlertDialog(
      title: Text(
        '${personaje.emoji} ${personaje.nombre}',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            q.texto,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          for (var i = 0; i < q.opciones.length; i++)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 6,
              ),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, i);
                },
                child: Text(
                  q.opciones[i],
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}