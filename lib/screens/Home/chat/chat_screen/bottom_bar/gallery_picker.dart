// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:video_player/video_player.dart';

class GalleryPicker extends StatefulWidget {
  final Function(XFile) onFilePicked;

  const GalleryPicker({super.key, required this.onFilePicked});

  @override
  _GalleryPickerState createState() => _GalleryPickerState();
}

class _GalleryPickerState extends State<GalleryPicker> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _mediaFiles = [];

  Future<void> _pickMedia() async {
    // Pick images and videos
    final List<XFile?> images = await _picker.pickMultiImage();
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

    setState(() {
      _mediaFiles = [...(images.whereType<XFile>()), if (video != null) video];
    });

    // If only one file is picked, return immediately
    if (_mediaFiles.length == 1) {
      widget.onFilePicked(_mediaFiles.first);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _pickMedia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Media'),
      ),
      body: _mediaFiles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _mediaFiles.length,
              itemBuilder: (context, index) {
                final XFile file = _mediaFiles[index];
                final bool isVideo = file.path.endsWith('.mp4');

                return GestureDetector(
                  onTap: () {
                    widget.onFilePicked(file);
                    Navigator.pop(context);
                  },
                  child: isVideo
                      ? VideoPlayerWidget(file: file)
                      : Image.file(File(file.path)),
                );
              },
            ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final XFile file;

  const VideoPlayerWidget({super.key, required this.file});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.file.path))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
