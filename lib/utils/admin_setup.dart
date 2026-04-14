import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSetup {
  static Future<void> createDefaultAdmin() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Default admin credentials
    const String username = 'admin';
    const String password = 'admin123';
    const String email = 'admin@exhibition.com';
    const String displayName = 'Exhibition Admin';

    try {

      // Check if admin already exists
      QuerySnapshot existingAdmin = await _firestore
          .collection('admins')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (existingAdmin.docs.isNotEmpty) {
        print('Admin user already exists');
        return;
      }

      print('Creating default admin user...');

      // Create Firebase Auth user
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Firebase Auth user created with UID: ${authResult.user!.uid}');

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

      print('Admin document created in Firestore');

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

      print('User document created in Firestore');
      print('Default admin user created successfully');
      print('Username: $username');
      print('Password: $password');
      print('Email: $email');
      
    } catch (e) {
      print('Failed to create admin user: $e');
      print('Error details: ${e.toString()}');
      
      // If user already exists in Firebase Auth, try to create the Firestore documents
      if (e.toString().contains('email-already-in-use')) {
        print('User already exists in Firebase Auth, creating Firestore documents...');
        try {
          // Sign in with existing user
          UserCredential authResult = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          
          // Create admin document
          await _firestore.collection('admins').doc(authResult.user!.uid).set({
            'uid': authResult.user!.uid,
            'username': username,
            'password': password,
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
          
          print('Firestore documents created for existing Firebase Auth user');
        } catch (secondError) {
          print('Failed to create Firestore documents: $secondError');
        }
      }
    }
  }
}
