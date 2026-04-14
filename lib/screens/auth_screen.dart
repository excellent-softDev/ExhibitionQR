import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  bool _isGuestMode = true;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                // Logo or Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                const Text(
                  'Exhibition Tracker',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Track your exhibition journey',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Login Form
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Guest/Admin toggle
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment<bool>(
                              value: true,
                              label: Text('Guest'),
                              icon: Icon(Icons.person_outline),
                            ),
                            ButtonSegment<bool>(
                              value: false,
                              label: Text('Admin'),
                              icon: Icon(Icons.admin_panel_settings),
                            ),
                          ],
                          selected: {_isGuestMode},
                          onSelectionChanged: (Set<bool> selection) {
                            setState(() {
                              _isGuestMode = selection.first;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Admin login form
                        if (!_isGuestMode) ...[
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  
                                  try {
                                    await authService.signInAsAdmin(
                                      _usernameController.text.trim(),
                                      _passwordController.text,
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                              icon: const Icon(Icons.admin_panel_settings),
                              label: const Text('Sign In as Admin'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ] else ...[
                          // Guest mode button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                
                                try {
                                  await authService.signInAnonymously();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              },
                              icon: const Icon(Icons.person_outline),
                              label: const Text('Continue as Guest'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Debug button to create admin (remove in production) - TEMPORARILY DISABLED
                // TextButton(
                //   onPressed: () async {
                //     try {
                //       // Create admin user in Firebase Auth directly
                //       await authService.createAdminUser(
                //         username: 'admin',
                //         password: 'admin123',
                //         email: 'admin@exhibition.com',
                //         displayName: 'Exhibition Admin',
                //       );
                //       if (mounted) {
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           const SnackBar(
                //             content: Text('Admin user created successfully! Try logging in now.'),
                //             backgroundColor: Colors.green,
                //           ),
                //         );
                //       }
                //     } catch (e) {
                //       if (mounted) {
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           SnackBar(
                //             content: Text('Failed to create admin: $e\n\nMake sure Email/Password auth is enabled in Firebase Console.'),
                //             backgroundColor: Colors.red,
                //           ),
                //         );
                //       }
                //     }
                //   },
                //   child: const Text(
                //     'Debug: Create Admin User',
                //     style: TextStyle(fontSize: 12, color: Colors.grey),
                //   ),
                // ),
                
                const SizedBox(height: 32),
                
                // Terms and Privacy
                const Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
