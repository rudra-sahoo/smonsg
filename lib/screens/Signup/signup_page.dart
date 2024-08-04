import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'profile_setup_page.dart'; // Import the profile setup page

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late VideoPlayerController _controller;
  bool _videoPlayed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/welcome.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        setState(() {
          _videoPlayed = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToProfileSetupPage() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ProfileSetupPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          // Focus scope to hide keyboard when tapped outside of text fields
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Column(
              children: [
                // Logo at the top
                Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: Center(
                    child: Image.asset(
                      'assets/logo.png', // Replace with your logo asset path
                      height: 180, // Adjust the height as needed
                    ),
                  ),
                ),
                // Spacer to position video correctly
                const Spacer(),
                // Video Player in the middle
                if (_controller.value.isInitialized)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom:
                              120.0), // Increase this value to move the video up
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height *
                            0.4, // Adjust height based on your design needs
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),
                  ),
                const Spacer(), // Spacer to position button correctly
              ],
            ),
            if (_videoPlayed)
              Positioned(
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
                child: AnimatedOpacity(
                  opacity: _videoPlayed ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 500),
                  child: ElevatedButton(
                    onPressed: _navigateToProfileSetupPage,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Next'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
