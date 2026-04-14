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

  // Admin sign in
  Future<UserCredential> signInAsAdmin(String username, String password) async {
    try {
      // For your specific admin setup, use the provided credentials
      if (username == 'admin' && password == 'admin123') {
        // Use the specific Firebase Auth user you created
        try {
          UserCredential result = await _auth.signInWithEmailAndPassword(
            email: 'admin@exhibition.com', // Your admin email
            password: 'admin123', // Your admin password
          );

          // Update user document to mark as admin
          await _firestore.collection('users').doc(result.user!.uid).set({
            'uid': result.user!.uid,
            'email': result.user!.email,
            'displayName': 'Exhibition Admin',
            'isAnonymous': false,
            'isAdmin': true,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          // Also update/create admin document
          await _firestore.collection('admins').doc(result.user!.uid).set({
            'uid': result.user!.uid,
            'username': username,
            'password': password,
            'email': 'admin@exhibition.com',
            'displayName': 'Exhibition Admin',
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          
          return result;
        } catch (authError) {
          // If user doesn't exist in Firebase Auth, create it
          if (authError.toString().contains('user-not-found') || 
              authError.toString().contains('wrong-password')) {
            UserCredential result = await _auth.createUserWithEmailAndPassword(
              email: 'admin@exhibition.com',
              password: 'admin123',
            );

            // Create admin document
            await _firestore.collection('admins').doc(result.user!.uid).set({
              'uid': result.user!.uid,
              'username': username,
              'password': password,
              'email': 'admin@exhibition.com',
              'displayName': 'Exhibition Admin',
              'createdAt': FieldValue.serverTimestamp(),
              'lastLoginAt': FieldValue.serverTimestamp(),
            });

            // Create user document
            await _firestore.collection('users').doc(result.user!.uid).set({
              'uid': result.user!.uid,
              'email': result.user!.email,
              'displayName': 'Exhibition Admin',
              'isAnonymous': false,
              'isAdmin': true,
              'createdAt': FieldValue.serverTimestamp(),
              'lastLoginAt': FieldValue.serverTimestamp(),
            });
            
            return result;
          } else {
            throw authError;
          }
        }
      } else {
        throw Exception('Invalid admin credentials');
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
