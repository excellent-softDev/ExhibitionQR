// Test script to check Firebase connection and Auth setup
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';

Future<void> main() async {
  print('Testing Firebase connection...');
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Firebase initialized successfully!');
  
  // Test Firebase Auth
  final FirebaseAuth auth = FirebaseAuth.instance;
  print('Firebase Auth instance created');
  
  // Test Firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  print('Firestore instance created');
  
  // Try to access a collection (this will test permissions)
  try {
    CollectionReference usersRef = firestore.collection('users');
    QuerySnapshot snapshot = await usersRef.limit(1).get();
    print('Firestore access: SUCCESS');
    print('Documents in users collection: ${snapshot.docs.length}');
  } catch (e) {
    print('Firestore access error: $e');
    print('Make sure Firestore rules allow read access');
  }
  
  // Test Auth state
  User? currentUser = auth.currentUser;
  if (currentUser != null) {
    print('Current user: ${currentUser.email}');
  } else {
    print('No user currently signed in');
  }
  
  print('\nFirebase connection test completed!');
  print('\nIf you see "Firebase Auth instance created" above,');
  print('then the Firebase configuration is working.');
  print('\nTo enable Authentication:');
  print('1. Go to https://console.firebase.google.com/');
  print('2. Select project: exhibitionqr-b20b2');
  print('3. Go to Authentication > Sign-in method');
  print('4. Enable Email/Password provider');
}
