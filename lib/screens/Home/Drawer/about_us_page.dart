import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching URLs

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  // Function to launch URL
  Future<void> _launchURL(String url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal, // Set the background color to teal
      appBar: AppBar(
        title: const Center(child: Text('About Me')),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image with Cool Animation
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/profile_image.jpg'),
            ),
          ),
          const SizedBox(height: 20),
          const AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(seconds: 2),
            child: Text(
              'Hi, I am Rudra, currently creating a beautiful app named SMONSG.',
              style: TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          const AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(seconds: 2),
            child: Text(
              'I am pursuing my BTech from Vellore Institute of Technology.',
              style: TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Follow me on social media:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.github),
                  iconSize: 24,
                  color: Colors.black,
                  onPressed: () {
                    _launchURL(
                        'https://github.com/rudra-sahoo'); // Replace with your GitHub URL
                  },
                ),
              ),
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.instagram),
                  iconSize: 24,
                  color: Colors.purple,
                  onPressed: () {
                    _launchURL(
                        'https://instagram.com/rudra.sah00'); // Replace with your Instagram URL
                  },
                ),
              ),
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.spotify),
                  iconSize: 24,
                  color: Colors.green,
                  onPressed: () {
                    _launchURL(
                        'https://open.spotify.com/user/exsjza11hdm11xgo1gzvm17gl?si=7c14c0bc589d4e12'); // Replace with your Spotify URL
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
