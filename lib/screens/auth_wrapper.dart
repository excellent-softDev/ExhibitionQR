import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'auth_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isAutoSigningIn = false;

  @override
  void initState() {
    super.initState();
    _autoSignInAsGuest();
  }

  Future<void> _autoSignInAsGuest() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Only auto-sign in if no user is currently authenticated
    if (authService.currentUser == null && !_isAutoSigningIn) {
      setState(() {
        _isAutoSigningIn = true;
      });
      
      try {
        await authService.signInAnonymously();
      } catch (e) {
        // Handle error silently - user can still sign in manually
      } finally {
        setState(() {
          _isAutoSigningIn = false;
        });
      }
    }
  }

<<<<<<< HEAD
  Future<void> _loadUserData(dynamic user) async {
    if (user == null) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final userData = await authService.getUserData(user.uid);
      if (mounted) {
        if (userData != null) {
          userProvider.setUserData(userData);
        } else {
          userProvider.setUserData({
            'uid': user.uid,
            'isAnonymous': user.isAnonymous ?? true,
          });
        }
      }
    } catch (_) {
      // Ignore loading profile details if it fails.
    }
  }

=======
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _isAutoSigningIn) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Setting up your guest session...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          // Use WidgetsBinding to schedule the setUser call after the build phase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
<<<<<<< HEAD
              final currentUser = snapshot.data as dynamic;
              userProvider.setUser(currentUser);

              if (userProvider.userData == null || userProvider.userData?['uid'] != currentUser.uid) {
                _loadUserData(currentUser);
              }
=======
              userProvider.setUser(snapshot.data as dynamic);
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5
            }
          });
          return const HomeScreen();
        } else {
          // Use WidgetsBinding to schedule signOut call after build phase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              userProvider.signOut();
            }
          });
          return const AuthScreen();
        }
      },
    );
  }
}
