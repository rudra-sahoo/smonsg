import 'package:flutter/material.dart';
import 'package:smonsg/screens/Signup/signup_page.dart'; // Import the SignUpPage
import 'package:smonsg/screens/otp/login_otp_page.dart'; // Import the OTPPage
import 'package:smonsg/services/auth_service.dart'; // Import AuthService
import 'package:lottie/lottie.dart'; // Import Lottie package
import 'package:email_validator/email_validator.dart'; // Import email validator

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _obscureText = true;
  bool _buttonPressed = false;
  final AuthService _authService = AuthService();
  bool _loading = false;
  bool _isEmailValid = false;
  bool _isPasswordEntered = false;

  late AnimationController _controller;
  late Animation<double> _buttonWidthAnimation;
  late Animation<double> _buttonHeightAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _buttonWidthAnimation = Tween<double>(begin: 250.0, end: 250.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _buttonHeightAnimation = Tween<double>(begin: 50.0, end: 50.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _textOpacityAnimation = Tween<double>(begin: 1.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _emailController.addListener(() {
      setState(() {
        _isEmailValid = EmailValidator.validate(_emailController.text.trim());
        _updateButtonState();
      });
    });

    _passwordController.addListener(() {
      setState(() {
        _isPasswordEntered = _passwordController.text.trim().isNotEmpty;
        _updateButtonState();
      });
    });
  }

  void _updateButtonState() {
    if (_isEmailValid && _isPasswordEntered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _login() async {
    setState(() {
      _buttonPressed = true;
      _loading = true; // Show loading animation
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final result = await _authService.login(email, password);

    if (result['success']) {
      // Navigate to OTP page with user details
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => OTPPage(
            userName: result['userName'],
            userProfileImage: result['userProfileImage'],
            firstName: result['firstName'],
            lastName: result['lastName'],
            email: result['email'],
          ),
        ),
      );
    } else {
      // Show error message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _buttonPressed = false;
      _loading = false; // Hide loading animation
    });
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
            SingleChildScrollView(
              child: Column(
                children: [
                  // Spacer to push content upwards
                  const SizedBox(
                      height: 140), // Adjusted space to push content up
                  // Logo
                  Image.asset(
                    'assets/logo.png', // replace with your logo asset path
                    height: 180, // adjust the height as needed
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Login to smonsg',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.grey[800],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: _obscureText,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.grey[800],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                      height: 60), // Adjusted space to push button up
                ],
              ),
            ),
            // Loading Animation and Blur
            IgnorePointer(
              ignoring: !_loading,
              child: AnimatedOpacity(
                opacity: _loading ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  color: Colors.black
                      .withOpacity(0.7), // Increased opacity for stronger blur
                  child: Center(
                    child: Lottie.asset(
                      'assets/loading1.json', // Replace with your Lottie animation asset path
                      width: 100, // Adjust the width as needed
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SizedBox(
              width: _buttonWidthAnimation.value,
              height: _buttonHeightAnimation.value,
              child: ElevatedButton(
                onPressed:
                    (_isEmailValid && _isPasswordEntered && !_buttonPressed)
                        ? _login
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpPage()),
                            );
                          },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.black.withOpacity(0.5); // when pressed
                      }
                      return Colors.black; // default
                    },
                  ),
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                  shape: WidgetStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  elevation: WidgetStateProperty.resolveWith<double>(
                    (Set<WidgetState> states) {
                      return states.contains(WidgetState.pressed) ? 0 : 10;
                    },
                  ),
                  shadowColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      return states.contains(WidgetState.pressed)
                          ? Colors.transparent
                          : Colors.black;
                    },
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textOpacityAnimation.value,
                      child: Text(
                        style: const TextStyle(color: Colors.white),
                        (_isEmailValid && _isPasswordEntered)
                            ? 'Login'
                            : "Don't have an account? Sign Up",
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
