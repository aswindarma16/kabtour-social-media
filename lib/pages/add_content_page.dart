import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../globals.dart';
import 'preview_content_page.dart';

class AddContentPage extends StatefulWidget {
  const AddContentPage({super.key});

  @override
  State<AddContentPage> createState() => _AddContentPageState();
}

class _AddContentPageState extends State<AddContentPage> {
  late List<CameraDescription> _cameras;
  CameraController? _cameraController;
  CameraLensDirection _currentLens = CameraLensDirection.back;

  final ValueNotifier<bool> _isRecording = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    initCameras();
  }

  Future<void> initCameras() async {
    _cameras = await availableCameras();
    await _startCamera(_currentLens);
  }

  Future<void> _startCamera(CameraLensDirection direction) async {
    final camera = _cameras.firstWhere(
      (c) => c.lensDirection == direction,
      orElse: () => _cameras.first,
    );

    await _cameraController?.dispose();

    _cameraController = CameraController(camera, ResolutionPreset.high, enableAudio: true);
    await _cameraController?.initialize();
    if (!mounted) return;
    setState(() {});
  }

  void _switchCamera() {
    _currentLens = _currentLens == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    _startCamera(_currentLens);
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.media);

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path == null) return;

      final isVideo = availableVideoFormat
          .any((ext) => path.toLowerCase().endsWith(ext));

      await _cameraController?.dispose();
      _cameraController = null;

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PreviewContentPage(file: File(path), isVideo: isVideo, transformHorizontally: _currentLens == CameraLensDirection.front ? true : false),
        ),
      );

      if (mounted) {
        await _startCamera(_currentLens);
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final file = await _cameraController!.takePicture();

      await _cameraController?.pausePreview();

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PreviewContentPage(file: File(file.path), isVideo: false, transformHorizontally: _currentLens == CameraLensDirection.front ? true : false),
        ),
      );

      await _cameraController?.resumePreview();
    }
  }

  Future<void> _startVideo() async {
    if (_cameraController != null && !_cameraController!.value.isRecordingVideo) {
      await _cameraController!.startVideoRecording();
      _isRecording.value = true;
    }
  }

  Future<void> _stopVideo() async {
    if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
      final file = await _cameraController!.stopVideoRecording();
      _isRecording.value = false;

      await _cameraController?.pausePreview();

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PreviewContentPage(file: File(file.path), isVideo: true, transformHorizontally: _currentLens == CameraLensDirection.front ? true : false),
        ),
      );

      await _cameraController?.resumePreview();
    }
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget preview = CameraPreview(_cameraController!);

    return preview;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _isRecording.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          _buildCameraPreview(),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.switch_camera, color: Colors.white, size: 30),
              onPressed: _switchCamera,
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.photo_library, color: Colors.white, size: 30),
              onPressed: _pickMedia,
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _takePhoto,
              onLongPressStart: (_) => _startVideo(),
              onLongPressEnd: (_) => _stopVideo(),
              child: Center(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isRecording,
                  builder: (_, isRecording, __) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: isRecording ? Colors.red : Colors.transparent,
                      ),
                    );
                  }
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
