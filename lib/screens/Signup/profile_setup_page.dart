import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:lottie/lottie.dart';
import 'package:smonsg/screens/Signup/details_setup_page.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  String? _firstName;
  String? _lastName;
  DateTime? _dob;
  String? _profileImagePath;
  String? _avatarImagePath;
  String? _gender;
  VideoPlayerController? _avatarController;
  bool _isLoading = false;
  bool _isButtonPressed = false;

  Future<void> _pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'heic'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _profileImagePath = result.files.single.path!;
      });
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please select a valid image file (jpg, jpeg, png, heic).'),
        ),
      );
    }
  }

  Future<void> _pickAvatarImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gif', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _avatarImagePath = result.files.single.path!;
        if (_avatarImagePath!.endsWith('.gif')) {
          _avatarController =
              VideoPlayerController.file(File(_avatarImagePath!))
                ..initialize().then((_) {
                  _avatarController!.setLooping(true);
                  _avatarController!.play();
                  setState(() {});
                });
        }
      });
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid image or GIF file.'),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
      });
    }
  }

  bool _isAgeValid(DateTime date) {
    final currentDate = DateTime.now();
    final age = currentDate.year - date.year;
    if (age < 13) return false;
    if (age == 13) {
      if (currentDate.month < date.month) return false;
      if (currentDate.month == date.month && currentDate.day < date.day) {
        return false;
      }
    }
    return true;
  }

  Future<void> _submitProfileDetails() async {
    if (_firstName != null &&
        _lastName != null &&
        _dob != null &&
        _profileImagePath != null &&
        _avatarImagePath != null &&
        _gender != null) {
      if (!_isAgeValid(_dob!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be at least 13 years old.'),
          ),
        );
        return;
      }
      setState(() {
        _isLoading = true;
        _isButtonPressed = true;
      });
      await Future.delayed(const Duration(seconds: 2)); // Simulate loading

      // ignore: use_build_context_synchronously
      Navigator.of(context)
          .pushReplacement(
        MaterialPageRoute(
          builder: (context) => DetailsSetupPage(
            firstName: _firstName!,
            lastName: _lastName!,
            imagePath: _profileImagePath!,
            avatarPath: _avatarImagePath!,
            dob: DateFormat('yyyy-MM-dd').format(_dob!),
            gender: _gender!,
          ),
        ),
      )
          .then((result) {
        if (result != null && result is Map<String, dynamic>) {
          updateProfileDetails(
            firstName: result['firstName'],
            lastName: result['lastName'],
            dob: result['dob'],
            profileImagePath: result['profileImagePath'],
            avatarImagePath: result['avatarImagePath'],
            gender: result['gender'],
          );
        }
      });

      setState(() {
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all details and select images.'),
        ),
      );
    }
  }

  void updateProfileDetails({
    String? firstName,
    String? lastName,
    DateTime? dob,
    String? profileImagePath,
    String? avatarImagePath,
    String? gender,
  }) {
    setState(() {
      _firstName = firstName;
      _lastName = lastName;
      _dob = dob;
      _profileImagePath = profileImagePath;
      _avatarImagePath = avatarImagePath;
      _gender = gender;
    });
  }

  bool _areAllFieldsFilled() {
    return _firstName != null &&
        _lastName != null &&
        _dob != null &&
        _profileImagePath != null &&
        _avatarImagePath != null &&
        _gender != null &&
        _isAgeValid(_dob!);
  }

  void _validateAndSubmit() {
    if (_areAllFieldsFilled()) {
      setState(() {
        _isButtonPressed = true;
        _isLoading = true;
      });
      _submitProfileDetails();
    } else {
      setState(() {
        _isButtonPressed = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all details and select images.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _avatarController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Profile'),
        ),
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: AbsorbPointer(
              absorbing: _isButtonPressed,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: _pickAvatarImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _avatarImagePath != null
                            ? Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: _avatarImagePath!.endsWith('.gif')
                                ? null
                                : DecorationImage(
                              image: FileImage(
                                  File(_avatarImagePath!)),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: _avatarImagePath!.endsWith('.gif')
                              ? VideoPlayer(_avatarController!)
                              : null,
                        )
                            : Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.black,
                          child: const Center(
                            child: Text(
                              'Choose Avatar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        if (_profileImagePath == null)
                          Positioned(
                            top: 10,
                            child: GestureDetector(
                              onTap: _pickProfileImage,
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 4.0),
                                  color: Colors.grey.shade300,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.black,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        if (_profileImagePath != null)
                          Positioned(
                            top: 10,
                            child: GestureDetector(
                              onTap: _pickProfileImage,
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 4.0),
                                  image: DecorationImage(
                                    image: FileImage(File(_profileImagePath!)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                      onChanged: (value) {
                        _firstName = value.trim(); // Remove leading and trailing spaces
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                      onChanged: (value) {
                        _lastName = value.trim(); // Remove leading and trailing spaces
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                      items: ['Male', 'Female', 'None']
                          .map((label) => DropdownMenuItem(
                        value: label,
                        child: Text(label),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            hintText: 'yyyy-mm-dd',
                            border: OutlineInputBorder(),
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 10.0),
                          ),
                          controller: TextEditingController(
                            text: _dob == null
                                ? ''
                                : DateFormat('yyyy-MM-dd').format(_dob!),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading)
            IgnorePointer(
              ignoring: _isLoading,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Lottie.asset(
                      'assets/loading1.json',
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedOpacity(
          opacity: _areAllFieldsFilled() ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 500),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _validateAndSubmit,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: _isLoading ? Colors.grey : Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : const Text('Next'),
          ),
        ),
      ),
    );
  }
}
