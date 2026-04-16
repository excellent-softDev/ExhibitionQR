import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Anonymous sign in
  Future<UserCredential> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      
      // Create user document in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'isAnonymous': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      
      return result;
    } catch (e) {
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  // Admin sign in using Firestore admin credentials
  Future<UserCredential> signInAsAdmin(String username, String password) async {
    try {
      final adminQuery = await _firestore
          .collection('admins')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (adminQuery.docs.isEmpty) {
        throw Exception('Invalid admin credentials');
      }

      final adminDoc = adminQuery.docs.first;
      final adminData = adminDoc.data();
      final storedPassword = adminData['password'] as String?;
      final email = adminData['email'] as String?;
      final displayName = adminData['displayName'] as String? ?? 'Admin';

      if (email == null || storedPassword == null || storedPassword != password) {
        throw Exception('Invalid admin credentials');
      }

      try {
        UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        await _firestore.collection('users').doc(result.user!.uid).set({
          'uid': result.user!.uid,
          'email': result.user!.email,
          'displayName': displayName,
          'isAnonymous': false,
          'isAdmin': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await _firestore.collection('admins').doc(adminDoc.id).set({
          'uid': result.user!.uid,
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return result;
      } catch (authError) {
        if (authError.toString().contains('user-not-found')) {
          UserCredential result = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          await _firestore.collection('admins').doc(result.user!.uid).set({
            'uid': result.user!.uid,
            'username': username,
            'password': password,
            'email': email,
            'displayName': displayName,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
          });

          await _firestore.collection('users').doc(result.user!.uid).set({
            'uid': result.user!.uid,
            'email': result.user!.email,
            'displayName': displayName,
            'isAnonymous': false,
            'isAdmin': true,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
          });

          return result;
        }

        if (authError.toString().contains('wrong-password')) {
          throw Exception('Invalid admin credentials');
        }

        rethrow;
      }
    } catch (e) {
      throw Exception('Failed to sign in as admin: $e');
    }
  }

  // Create admin user
  Future<void> createAdminUser({
    required String username,
    required String password,
    required String email,
    required String displayName,
  }) async {
    try {
      // Check if admin already exists
      QuerySnapshot existingAdmin = await _firestore
          .collection('admins')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (existingAdmin.docs.isNotEmpty) {
        throw Exception('Admin user already exists');
      }

      // Create Firebase Auth user
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create admin document
      await _firestore.collection('admins').doc(authResult.user!.uid).set({
        'uid': authResult.user!.uid,
        'username': username,
        'password': password, // In production, you should hash this
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      // Create user document
      await _firestore.collection('users').doc(authResult.user!.uid).set({
        'uid': authResult.user!.uid,
        'email': email,
        'displayName': displayName,
        'isAnonymous': false,
        'isAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create admin user: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }
}
