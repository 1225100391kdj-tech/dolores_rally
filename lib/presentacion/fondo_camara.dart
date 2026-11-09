import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FondoCamara extends StatefulWidget {
  const FondoCamara({super.key});

  @override
  State<FondoCamara> createState() =>
      _FondoCamaraState();
}

class _FondoCamaraState extends State<FondoCamara> {
  CameraController? _controlador;
  bool _fallo = false;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    try {
      final camaras = await availableCameras();

      final trasera = camaras.firstWhere(
        (c) =>
            c.lensDirection == CameraLensDirection.back,
        orElse: () => camaras.first,
      );

      final c = CameraController(
        trasera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await c.initialize();

      if (!mounted) {
        await c.dispose();
        return;
      }

      setState(() {
        _controlador = c;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _fallo = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controlador?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controlador;

    if (c != null && c.value.isInitialized) {
      final t = c.value.previewSize!;

      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: t.height,
            height: t.width,
            child: CameraPreview(c),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1B2A49),
            Color(0xFF4A6FA5),
            Color(0xFFD9A066),
          ],
        ),
      ),
      child: _fallo
          ? const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Sin cámara: usando fondo simulado',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}