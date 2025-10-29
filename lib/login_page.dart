import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:manuscan/controllers/auth_controller.dart';
import 'dart:math' as math;

class login_account extends StatefulWidget {
  const login_account({super.key});

  @override
  _login_account createState() => _login_account();
}

class _login_account extends State<login_account> {
  final AuthController authController = Get.find();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    // Validation for email format and empty fields
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter both email and password.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(20),
      );
      return;
    }
    // Validate email format
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(20),
      );
      return;
    }

    if (_emailError != null || _passwordError != null) {
      return;
    }

    await authController.login(
      _emailController.text,
      _passwordController.text,
    );

    if (authController.isLoggedIn && authController.errorMessage.isEmpty) {
      Get.snackbar(
        'Success',
        'Login Successful!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      // Improved error handling
      String displayMessage;
      Color errorColor = Colors.red;
      final String rawError = authController.errorMessage.toLowerCase();

      if (rawError.contains('device') || rawError.contains('authorized')) {
        displayMessage = 'Device not authorized. Please contact administrator.';
        errorColor = Colors.orange;
      } else if (rawError.contains('credentials')) {
        displayMessage = 'Invalid email or password.';
      } else if (rawError.contains('network') || rawError.contains('timeout')) {
        displayMessage =
            'Could not connect to server. Please check your network.';
        errorColor = Colors.blueGrey;
      } else {
        displayMessage = 'An unexpected error occurred. Please try again.';
      }

      Get.snackbar(
        'Login Failed',
        displayMessage,
        backgroundColor: errorColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(20),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: const Text("Log In"),
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(
                  color: Color.fromRGBO(88, 164, 176, 1),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/dana.png',
                      height: 40,
                    ),
                  ),
                ],
              ),
              body: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SingleChildScrollView(
                  // All content goes inside this scroll view
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildSubtitle(),
                      const SizedBox(height: 100),
                      buildFormFields(),
                      const SizedBox(height: 20), // Add some space
                      // **FIXED**: Button is now correctly placed here
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            // Get the ID from the controller
                            final deviceId =
                                await authController.getDeviceMacAddress();
                            // Show it in a dialog
                            Get.defaultDialog(
                              title: "Device ID",
                              middleText:
                                  "Please provide this ID to your administrator for access:\n\n$deviceId",
                              textConfirm: "Copy ID",
                              textCancel: "Close",
                              onConfirm: () {
                                Clipboard.setData(
                                    ClipboardData(text: deviceId));
                                Get.back(); // Close dialog
                                Get.snackbar(
                                    'Copied', 'Device ID copied to clipboard');
                              },
                            );
                          },
                          child: const Text(
                              "Device not registered? Show my Device ID"),
                        ),
                      ),
                      buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
            // Loading screen overlay remains here
            if (authController.isLoading)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color.fromRGBO(88, 164, 176, 1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Signing In...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(55, 63, 81, 1),
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Verifying your credentials',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLoadingDot(0),
                            const SizedBox(width: 4),
                            _buildLoadingDot(1),
                            const SizedBox(width: 4),
                            _buildLoadingDot(2),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ));
  }

  Widget _buildLoadingDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale:
              0.5 + (0.5 * (0.5 + 0.5 * (1 + math.cos(value * 2 * math.pi)))),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(88, 164, 176, 1),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget buildFormFields() {
    return Column(
      children: [
        buildFormField(
            'Email Address', false, Icons.email, _emailController, _emailError),
        buildFormField(
            'Password', true, Icons.lock, _passwordController, _passwordError),
      ],
    );
  }

  Widget buildFormField(String label, bool isPassword, IconData icon,
      TextEditingController controller, String? errorText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter your $label',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Color.fromRGBO(88, 164, 176, 1),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: const Color(0xFFD8DBE2),
          prefixIcon: Icon(icon, color: const Color.fromRGBO(88, 164, 176, 1)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: const Color.fromRGBO(88, 164, 176, 1),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          errorText: errorText,
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontFamily: 'DM Sans',
          ),
        ),
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 16,
        ),
        onChanged: (value) {
          setState(() {
            if (label == 'Email Address') {
              _emailError = value.isEmpty ? 'Please enter your Email' : null;
            } else if (label == 'Password') {
              _passwordError =
                  value.length < 6 ? 'Require at least 6 characters' : null;
            }
          });
        },
      ),
    );
  }

  Widget buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text.rich(
            TextSpan(
              children: [
                // Account creation links commented out as per original
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 220.0),
            child: GestureDetector(
              onTap: _login,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(55, 63, 81, 1),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F323247),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Color(0x14323247),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'LOG IN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.bold,
                      height: 1.22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSubtitle() {
    return const Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Welcome back !\n',
              style: TextStyle(
                color: Color(0xFF1B1B1E),
                fontSize: 18,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                height: 1.22,
              ),
            ),
            TextSpan(
              text: 'Please login with your credentials',
              style: TextStyle(
                color: Color(0xFF1B1B1E),
                fontSize: 18,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w300,
                height: 1.22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
