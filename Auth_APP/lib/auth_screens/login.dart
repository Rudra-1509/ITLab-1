import 'dart:convert';
import 'dart:ui'; // Required for ImageFilter.blur
import 'package:auth_app/auth_screens/register.dart';
import 'package:auth_app/home.dart';
import 'package:auth_app/model.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:http/http.dart' as http;

class GlassLoginPage extends StatefulWidget {
  const GlassLoginPage({super.key});

  @override
  State<GlassLoginPage> createState() => _GlassLoginPageState();
}

class _GlassLoginPageState extends State<GlassLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Create the user object from the text controllers
        final user = User(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Send POST request to your Node.js login endpoint
        final response = await http.post(
          // Replace '/login' with your actual endpoint route if different
          Uri.parse('https://itlab-1.onrender.com/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(user.toJson()),
        );

        if (response.statusCode == 200) {
          // Success
          print('Login successful: ${response.body}');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) =>
                false, // Returning false removes all previous routes
          );
        } else {
          // Failure (e.g., 400 Invalid credentials)
          final errorData = jsonDecode(response.body);
          print('Login failed: ${errorData['message']}');

          // Optional: Show an error SnackBar to the user
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorData['message'] ?? 'Login failed')),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Pure Black Background
          Positioned.fill(child: Container(color: Colors.black)),

          // Top-left ambient glow orb (allows glass refraction on dark background)
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.18,
            right: MediaQuery.of(context).size.width * 0.08,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.5),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          // Bottom-right ambient glow orb
          Positioned(
            top: MediaQuery.of(context).size.height * 0.18,
            left: MediaQuery.of(context).size.width * 0.08,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyan.withOpacity(0.35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.5),
                    blurRadius: 100,
                    spreadRadius: 40,
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
                    glassColor: Color(0x1AFFFFFF), // Soft specular white tint
                    refractiveIndex: 1.5,
                    lightIntensity: 1.6, // Enhanced rim lighting for dark mode
                    ambientStrength: 0.9, // Crisp glass edges
                  ),
                  child: LiquidStretch(
                    stretch: 0.7,
                    interactionScale: 1,
                    child: LiquidGlass(
                      shape: LiquidRoundedSuperellipse(borderRadius: 40),
                      child: GlassGlow(
                        glowColor: Colors.white.withOpacity(0.15),
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
                                  'Sign in to continue',
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
                                const SizedBox(height: 40),

                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 45,
                                  child: ElevatedButton(
                                    // Use an empty closure when loading so the button visual doesn't turn grey
                                    onPressed: _isLoading
                                        ? () {}
                                        : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      elevation: 13,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    // Always show text, loading is handled by the overlay now
                                    child: const Text(
                                      'SIGN IN',
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
                                              ) => const GlassSignUpPage(),
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
                                      "Sign Up",
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
          // Positioned at the very end of the Stack so it covers everything
          if (_isLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  color: Colors.black.withOpacity(
                    0.2,
                  ), // Slight darkening effect
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
