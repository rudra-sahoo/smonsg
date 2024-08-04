import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'camera_screen.dart';
import 'gallery_picker.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const MessageInput(
      {super.key, required this.controller, required this.onSend});

  @override
  // ignore: library_private_types_in_public_api
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput>
    with SingleTickerProviderStateMixin {
  bool _isSendButtonVisible = false;
  bool _isEmojiPickerVisible = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  XFile? _mediaFile;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _handleTextChange() {
    setState(() {
      _isSendButtonVisible =
          widget.controller.text.isNotEmpty || _mediaFile != null;
    });
    if (_isSendButtonVisible) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      _isEmojiPickerVisible = !_isEmojiPickerVisible;
    });
  }

  void _openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(onFileCaptured: _attachMedia),
      ),
    );
  }

  void _openGallery() {
    showModalBottomSheet(
      context: context,
      builder: (context) => GalleryPicker(onFilePicked: _attachMedia),
    );
  }

  void _attachMedia(XFile file) {
    setState(() {
      _mediaFile = file;
    });
  }

  Future<void> _sendMessage() async {
    final message = widget.controller.text.trim();
    if (message.isNotEmpty || _mediaFile != null) {
      // Handle sending message with or without media
      widget.onSend();
      // Clear media after sending
      setState(() {
        _mediaFile = null;
        widget.controller.clear();
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        elevation: 10,
        borderRadius: BorderRadius.circular(40.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(40.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_mediaFile != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: FileImage(File(_mediaFile!.path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 8.0,
                        top: 8.0,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _mediaFile = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _openCamera,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.white),
                      onTap: () {
                        setState(() {
                          _isEmojiPickerVisible = false;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic, color: Colors.white),
                    onPressed: () {
                      // Handle voice recording
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.white),
                    onPressed: _openGallery,
                  ),
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions, color: Colors.white),
                    onPressed: _toggleEmojiPicker,
                  ),
                  if (_isSendButtonVisible)
                    SizeTransition(
                      sizeFactor: _animation,
                      axis: Axis.horizontal,
                      axisAlignment: -1.0,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _isSendButtonVisible ? _sendMessage : null,
                      ),
                    ),
                ],
              ),
              if (_isEmojiPickerVisible)
                SizedBox(
                  height: 250,
                  child: GridView.count(
                    crossAxisCount: 8,
                    children: List.generate(64, (index) {
                      return IconButton(
                        onPressed: () {
                          widget.controller.text +=
                              String.fromCharCode(0x1F600 + index);
                          _toggleEmojiPicker();
                        },
                        icon: Text(String.fromCharCode(0x1F600 + index)),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
