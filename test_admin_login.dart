// This is a standalone script to test admin login
// Run this with: dart run test_admin_login.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  print('Testing admin login...');

  try {
    // Try to sign in with default admin credentials
    UserCredential result = await auth.signInWithEmailAndPassword(
      email: 'admin@exhibition.com',
      password: 'admin123',
    );

    print('Successfully signed in as admin!');
    print('User UID: ${result.user!.uid}');
    print('User email: ${result.user!.email}');

    // Check if admin document exists
    DocumentSnapshot adminDoc = await firestore
        .collection('admins')
        .doc(result.user!.uid)
        .get();

    if (adminDoc.exists) {
      print('Admin document exists');
      Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;
      print('Admin username: ${adminData['username']}');
      print('Admin display name: ${adminData['displayName']}');
    } else {
      print('Admin document does not exist');
    }

    // Check user document
    DocumentSnapshot userDoc = await firestore
        .collection('users')
        .doc(result.user!.uid)
        .get();

    if (userDoc.exists) {
      print('User document exists');
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      print('Is admin: ${userData['isAdmin']}');
    } else {
      print('User document does not exist');
    }

    await auth.signOut();
    print('Signed out successfully');

  } catch (e) {
    print('Error during admin login test: $e');
    
    // If login fails, try to create the admin user
    if (e.toString().contains('user-not-found') || e.toString().contains('wrong-password')) {
      print('Attempting to create admin user...');
      
      try {
        UserCredential createResult = await auth.createUserWithEmailAndPassword(
          email: 'admin@exhibition.com',
          password: 'admin123',
        );

        await firestore.collection('admins').doc(createResult.user!.uid).set({
          'uid': createResult.user!.uid,
          'username': 'admin',
          'password': 'admin123',
          'email': 'admin@exhibition.com',
          'displayName': 'Exhibition Admin',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });

        await firestore.collection('users').doc(createResult.user!.uid).set({
          'uid': createResult.user!.uid,
          'email': 'admin@exhibition.com',
          'displayName': 'Exhibition Admin',
          'isAnonymous': false,
          'isAdmin': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });

        print('Admin user created successfully!');
        await auth.signOut();
      } catch (createError) {
        print('Failed to create admin user: $createError');
      }
    }
  }
}
