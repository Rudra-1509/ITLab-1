import 'package:auth_app/auth_screens/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  void handleLogout() async {
    setState(() => _isLoading = true);

    try {
      // Tell backend to log out
      await http.post(
        Uri.parse('https://itlab-1.onrender.com/api/auth/logout'),
      );

      // Delete token using SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const GlassLoginPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout failed. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error. Check your connection.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            // ADDED: LiquidGlassLayer is required to render the shaders
            : LiquidGlassLayer(
                settings: const LiquidGlassSettings(
                  thickness: 10,
                  blur: 10,
                  glassColor: Color(0x33FFFFFF),
                ),
                child: LiquidStretch(
                  interactionScale: 1.03,
                  stretch: 0.5,
                  child: LiquidGlass(
                    shape: LiquidRoundedSuperellipse(borderRadius: 40),
                    child: ElevatedButton(
                      onPressed: handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'LOGOUT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
