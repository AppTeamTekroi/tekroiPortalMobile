import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AttendanceCameraPage extends StatefulWidget {
  const AttendanceCameraPage({super.key});

  @override
  State<AttendanceCameraPage> createState() => _AttendanceCameraPageState();
}

class _AttendanceCameraPageState extends State<AttendanceCameraPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _ready = false;
  bool _taking = false;
  String? _error;
  int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openFrontCamera());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final camera = _controller;
    if (camera == null || !camera.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      camera.dispose();
      _controller = null;
      if (mounted) setState(() => _ready = false);
    } else if (state == AppLifecycleState.resumed) {
      _bindCamera();
    }
  }

  Future<void> _openFrontCamera() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (!status.isGranted) {
      setState(() {
        _error = status.isPermanentlyDenied
            ? 'Camera permission is off. Enable it in Settings.'
            : 'Camera permission is required for check-in.';
      });
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _error = 'No camera found on this device.');
        return;
      }
      _cameraIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      if (_cameraIndex < 0) _cameraIndex = 0;
      await _bindCamera();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not open camera.');
    }
  }

  Future<void> _bindCamera() async {
    if (_cameras.isEmpty) return;
    final previous = _controller;
    _controller = null;
    await previous?.dispose();

    CameraException? lastError;
    for (final preset in [ResolutionPreset.medium, ResolutionPreset.low]) {
      final next = CameraController(
        _cameras[_cameraIndex],
        preset,
        enableAudio: false,
      );
      _controller = next;
      try {
        await next.initialize();
        if (!mounted) return;
        setState(() {
          _ready = true;
          _error = null;
        });
        return;
      } on CameraException catch (e) {
        lastError = e;
        await next.dispose();
        _controller = null;
      }
    }

    if (!mounted) return;
    setState(() {
      _ready = false;
      _error = lastError?.description ?? 'Could not open camera.';
    });
  }

  Future<void> _flip() async {
    if (_cameras.length < 2 || _taking) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    setState(() => _ready = false);
    await _bindCamera();
  }

  Future<void> _capture() async {
    final camera = _controller;
    if (camera == null || !camera.value.isInitialized || _taking) return;
    setState(() => _taking = true);
    try {
      final shot = await camera.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop(File(shot.path));
    } catch (_) {
      if (mounted) setState(() => _taking = false);
    }
  }

  Future<void> _openSystemCamera() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 1280,
      );
      if (!mounted) return;
      if (picked != null) {
        Navigator.of(context).pop(File(picked.path));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not open camera.');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _preview()),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
            if (_ready)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: _flip,
                  icon: const Icon(
                    Icons.cameraswitch_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            if (_ready)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: GestureDetector(
                    onTap: _capture,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: _taking ? Colors.white38 : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _preview() {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _openSystemCamera,
              child: const Text('Use phone camera'),
            ),
            TextButton(
              onPressed: () async {
                if (await Permission.camera.isPermanentlyDenied) {
                  await openAppSettings();
                  return;
                }
                setState(() => _error = null);
                await _openFrontCamera();
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    final camera = _controller;
    if (!_ready || camera == null || !camera.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    final size = camera.value.previewSize;
    if (size == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    final isFront =
        camera.description.lensDirection == CameraLensDirection.front;
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.height,
          height: size.width,
          child: Transform.scale(
            scaleX: isFront ? -1 : 1,
            child: CameraPreview(camera),
          ),
        ),
      ),
    );
  }
}
