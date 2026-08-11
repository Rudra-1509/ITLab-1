import 'dart:convert';
import 'dart:ui'; // Required for ImageFilter.blur
import 'package:auth_app/auth_screens/login.dart';
import 'package:auth_app/home.dart';
import 'package:auth_app/model.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:http/http.dart' as http;

class GlassSignUpPage extends StatefulWidget {
  const GlassSignUpPage({super.key});

  @override
  State<GlassSignUpPage> createState() => _GlassSignUpPageState();
}

class _GlassSignUpPageState extends State<GlassSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = User(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Send POST request to your Node.js register endpoint
        final response = await http.post(
          // Replace '/register' with your actual endpoint route if different
          Uri.parse('https://itlab-1.onrender.com/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(user.toJson()),
        );

        if (response.statusCode == 201) {
          // Success
          print('Registration successful: ${response.body}');

          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Account created!')));
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()),
              (Route<dynamic> route) =>
                  false, // Returning false removes all previous routes
            );
          }
        } else {
          // Failure (e.g., 400 User already exists)
          final errorData = jsonDecode(response.body);
          print('Registration failed: ${errorData['message']}');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorData['message'] ?? 'Registration failed'),
              ),
            );
          }
        }
      } catch (e) {
        print('Network error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to connect to server')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Grab dynamic screen dimensions to shrink orbs when keyboard opens
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // 2. Calculate dynamic sizes based on the current visible height
    final double orbSize = screenHeight * 0.22;
    final double blurSize = orbSize * 0.55;
    final double spreadSize = orbSize * 0.22;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Pure Black Background
          Positioned.fill(child: Container(color: Colors.black)),

          // Bottom-right ambient glow orb (Purple)
          Positioned(
            bottom: screenHeight * 0.18,
            right: screenWidth * 0.08,
            child: Container(
              width: orbSize,
              height: orbSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.5),
                    blurRadius: blurSize,
                    spreadRadius: spreadSize,
                  ),
                ],
              ),
            ),
          ),

          // Top-left ambient glow orb (Cyan)
          Positioned(
            top: screenHeight * 0.18,
            left: screenWidth * 0.08,
            child: Container(
              width: orbSize,
              height: orbSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyan.withOpacity(0.35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.5),
                    blurRadius: blurSize,
                    spreadRadius: spreadSize,
                  ),
                ],
              ),
            ),
          ),

          // 2. Liquid Glass Layer
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: LiquidGlassLayer(
                  settings: const LiquidGlassSettings(
                    thickness: 20,
                    blur: 20,
                    glassColor: Color(0x1AFFFFFF),
                    refractiveIndex: 1.5,
                    lightIntensity: 1.6,
                    ambientStrength: 0.9,
                  ),
                  child: LiquidStretch(
                    stretch: 0.7,
                    interactionScale: 1,
                    child: LiquidGlass(
                      shape: LiquidRoundedSuperellipse(borderRadius: 40),
                      child: GlassGlow(
                        glowColor: Colors.white.withOpacity(0.05),
                        glowRadius: 0.65,
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Logo / Title
                                const Text(
                                  'Auth App',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Create an account',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Email Field
                                LiquidStretch(
                                  interactionScale: 1.03,
                                  stretch: 0.9,
                                  child: LiquidGlass(
                                    shape: LiquidRoundedSuperellipse(
                                      borderRadius: 15,
                                    ),
                                    child: GlassGlow(
                                      glowColor: Colors.white.withOpacity(0.15),
                                      glowRadius: 1.5,
                                      child: TextFormField(
                                        controller: _emailController,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Email',
                                          hintStyle: const TextStyle(
                                            color: Colors.white60,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.email_outlined,
                                            color: Colors.white70,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(
                                            0.08,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        validator: (value) =>
                                            value != null && value.isNotEmpty
                                            ? null
                                            : 'Required',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Password Field
                                LiquidStretch(
                                  interactionScale: 1.03,
                                  stretch: 0.3,
                                  child: LiquidGlass(
                                    shape: LiquidRoundedSuperellipse(
                                      borderRadius: 15,
                                    ),
                                    child: GlassGlow(
                                      child: TextFormField(
                                        controller: _passwordController,
                                        obscureText: !_isPasswordVisible,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Password',
                                          hintStyle: const TextStyle(
                                            color: Colors.white60,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.lock_outline,
                                            color: Colors.white70,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isPasswordVisible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.white70,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isPasswordVisible =
                                                    !_isPasswordVisible;
                                              });
                                            },
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(
                                            0.08,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        validator: (value) =>
                                            value != null && value.isNotEmpty
                                            ? null
                                            : 'Required',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Confirm Password Field
                                LiquidStretch(
                                  interactionScale: 1.03,
                                  stretch: 0.3,
                                  child: LiquidGlass(
                                    shape: LiquidRoundedSuperellipse(
                                      borderRadius: 15,
                                    ),
                                    child: GlassGlow(
                                      child: TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: !_isConfirmPasswordVisible,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Confirm Password',
                                          hintStyle: const TextStyle(
                                            color: Colors.white60,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.lock_reset,
                                            color: Colors.white70,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isConfirmPasswordVisible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.white70,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isConfirmPasswordVisible =
                                                    !_isConfirmPasswordVisible;
                                              });
                                            },
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(
                                            0.08,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Required';
                                          }
                                          if (value !=
                                              _passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Sign Up Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 45,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? () {}
                                        : _handleSignUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      elevation: 13,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: const Text(
                                      'SIGN UP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushReplacement(
                                        PageRouteBuilder(
                                          pageBuilder:
                                              (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                              ) => const GlassLoginPage(),
                                          transitionsBuilder:
                                              (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                                child,
                                              ) {
                                                final curvedAnimation =
                                                    CurvedAnimation(
                                                      parent: animation,
                                                      curve: Curves.easeInOut,
                                                    );

                                                return FadeTransition(
                                                  opacity: curvedAnimation,
                                                  child: child,
                                                );
                                              },
                                          transitionDuration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          reverseTransitionDuration:
                                              const Duration(milliseconds: 250),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Login Instead",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Loading Overlay
          if (_isLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
