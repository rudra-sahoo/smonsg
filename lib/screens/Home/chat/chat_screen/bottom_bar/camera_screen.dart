import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';

class CameraScreen extends StatefulWidget {
  final Function(XFile) onFileCaptured;

  const CameraScreen({super.key, required this.onFileCaptured});

  @override
  // ignore: library_private_types_in_public_api
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _controller = CameraController(camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      widget.onFileCaptured(image);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _startVideoRecording() async {
    if (!_controller.value.isRecordingVideo) {
      try {
        await _initializeControllerFuture;
        await _controller.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_controller.value.isRecordingVideo) {
      try {
        final video = await _controller.stopVideoRecording();
        setState(() {
          _isRecording = false;
        });
        widget.onFileCaptured(video);
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onLongPress: _startVideoRecording,
                onLongPressUp: _stopVideoRecording,
                onTap: _takePicture,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isRecording ? Icons.videocam : Icons.camera_alt,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
