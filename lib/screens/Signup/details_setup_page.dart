import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smonsg/services/auth_service.dart';
import 'package:smonsg/screens/otp/signup_otp_page.dart';

class DetailsSetupPage extends StatefulWidget {
  final String? firstName;
  final String? lastName;
  final String? imagePath;
  final String? avatarPath;
  final String? dob;
  final String? gender;

  const DetailsSetupPage({
    super.key,
    this.firstName,
    this.lastName,
    this.imagePath,
    this.avatarPath,
    this.dob,
    this.gender,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DetailsSetupPageState createState() => _DetailsSetupPageState();
}

class _DetailsSetupPageState extends State<DetailsSetupPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _confirmEmailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _formValid = false;
  bool _isSuccess = false;
  late AnimationController _textAnimationController;
  late AnimationController _successAnimationController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _confirmEmailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _emailController.addListener(_checkFormValidity);
    _confirmEmailController.addListener(_checkFormValidity);
    _passwordController.addListener(_checkFormValidity);
    _confirmPasswordController.addListener(_checkFormValidity);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _confirmEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _textAnimationController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  void _checkFormValidity() {
    final isValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _formValid = isValid;
    });

    if (_formValid) {
      _textAnimationController.forward();
    } else {
      _textAnimationController.reverse();
    }
  }

  Future<void> _submitDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _isSuccess = false;
      });

      final email = _emailController.text;
      final password = _passwordController.text;
      final dob = widget.dob ?? '';
      final firstName = widget.firstName ?? '';
      final lastName = widget.lastName ?? '';
      final gender = widget.gender ?? '';

      final result = await _authService.signup(
        firstName,
        lastName,
        email,
        password,
        dob,
        gender,
        profileImage: widget.imagePath != null ? File(widget.imagePath!) : null,
        avatarImage:
            widget.avatarPath != null ? File(widget.avatarPath!) : null,
      );

      if (result['success'] == true) {
        setState(() {
          _isSuccess = true;
        });

        _successAnimationController.forward();

        await Future.delayed(const Duration(seconds: 2));

        final userName = result['username'] ?? '';
        final userProfileImage = result['profilePicture'] ?? '';

        // ignore: use_build_context_synchronously
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OTPPage(
              userName: userName,
              firstName: firstName,
              lastName: lastName,
              email: email,
              userProfileImage: userProfileImage,
            ),
          ),
        );

        _emailController.clear();
        _confirmEmailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();

        // Reset the success state after navigating
        setState(() {
          _isSuccess = false;
        });
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(result['message'] ?? 'Signup failed. Please try again.'),
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } else {}
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return null;
    }
    return null;
  }

  String? _validateConfirmEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value != _emailController.text) {
      return null;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length < 6) {
      return null;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value != _passwordController.text) {
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Image.asset(
                    'assets/logo.png',
                    height: 160,
                  ),
                ),
                const SizedBox(height: 50),
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmEmailController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateConfirmEmail,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        obscureText: true,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        obscureText: true,
                        validator: _validateConfirmPassword,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading || _isSuccess)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: _isSuccess
                      ? ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 2.0).animate(
                            CurvedAnimation(
                              parent: _successAnimationController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: Lottie.asset(
                            'assets/success.json',
                            width: 300,
                            height: 300,
                            onLoaded: (composition) {
                              _successAnimationController.duration =
                                  composition.duration;
                              _successAnimationController.forward();
                            },
                          ),
                        )
                      : Lottie.asset(
                          'assets/loading1.json',
                          width: 200,
                          height: 200,
                        ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedOpacity(
          opacity: _formValid ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 500),
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    _submitDetails();
                  },
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
                : const Text('Signup'),
          ),
        ),
      ),
    );
  }
}
