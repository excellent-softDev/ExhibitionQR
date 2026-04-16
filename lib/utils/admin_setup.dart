import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSetup {
  static Future<void> createDefaultAdmin() async {
<<<<<<< HEAD
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
=======
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5

    // Default admin credentials
    const String username = 'admin';
    const String password = 'admin123';
    const String email = 'admin@exhibition.com';
    const String displayName = 'Exhibition Admin';

    try {

      // Check if admin already exists
<<<<<<< HEAD
      QuerySnapshot existingAdmin = await firestore
=======
      QuerySnapshot existingAdmin = await _firestore
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5
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
<<<<<<< HEAD
      UserCredential authResult = await auth.createUserWithEmailAndPassword(
=======
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5
        email: email,
        password: password,
      );

      print('Firebase Auth user created with UID: ${authResult.user!.uid}');

      // Create admin document
<<<<<<< HEAD
      await firestore.collection('admins').doc(authResult.user!.uid).set({
=======
      await _firestore.collection('admins').doc(authResult.user!.uid).set({
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5
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
<<<<<<< HEAD
      await firestore.collection('users').doc(authResult.user!.uid).set({
=======
      await _firestore.collection('users').doc(authResult.user!.uid).set({
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5
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
<<<<<<< HEAD
          UserCredential authResult = await auth.signInWithEmailAndPassword(
=======
          UserCredential authResult = await _auth.signInWithEmailAndPassword(
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5
            email: email,
            password: password,
          );
          
          // Create admin document
<<<<<<< HEAD
          await firestore.collection('admins').doc(authResult.user!.uid).set({
=======
          await _firestore.collection('admins').doc(authResult.user!.uid).set({
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5
            'uid': authResult.user!.uid,
            'username': username,
            'password': password,
            'email': email,
            'displayName': displayName,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
          });

          // Create user document
<<<<<<< HEAD
          await firestore.collection('users').doc(authResult.user!.uid).set({
=======
          await _firestore.collection('users').doc(authResult.user!.uid).set({
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5
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
