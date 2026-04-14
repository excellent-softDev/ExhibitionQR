import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exhibit.dart';
import 'package:uuid/uuid.dart';

class ExhibitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  // Record exhibit visit
  Future<String> recordExhibitVisit(String exhibitId) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get or create active session
      String sessionId = await _getOrCreateActiveSession(user.uid);

      // Create exhibit visit record
      String visitId = _uuid.v4();
      ExhibitVisit visit = ExhibitVisit(
        id: visitId,
        sessionId: sessionId,
        exhibitId: exhibitId,
        userId: user.uid,
        scanTime: DateTime.now(),
      );

      await _firestore
          .collection('exhibitVisits')
          .doc(visitId)
          .set(visit.toMap());

      // Update analytics
      await _updateExhibitAnalytics(exhibitId);

      return visitId;
    } catch (e) {
      throw Exception('Failed to record exhibit visit: $e');
    }
  }

  // Get or create active session
  Future<String> _getOrCreateActiveSession(String userId) async {
    try {
      // Check for existing active session
      QuerySnapshot activeSessions = await _firestore
          .collection('userSessions')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (activeSessions.docs.isNotEmpty) {
        return activeSessions.docs.first.id;
      }

      // Create new session
      String sessionId = _uuid.v4();
      UserSession session = UserSession(
        id: sessionId,
        userId: userId,
        startTime: DateTime.now(),
        isActive: true,
      );

      await _firestore
          .collection('userSessions')
          .doc(sessionId)
          .set(session.toMap());

      return sessionId;
    } catch (e) {
      throw Exception('Failed to get or create session: $e');
    }
  }

  // End user session
  Future<void> endUserSession() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;

      QuerySnapshot activeSessions = await _firestore
          .collection('userSessions')
          .where('userId', isEqualTo: user.uid)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (activeSessions.docs.isNotEmpty) {
        String sessionId = activeSessions.docs.first.id;
        await _firestore.collection('userSessions').doc(sessionId).update({
          'isActive': false,
          'endTime': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to end session: $e');
    }
  }

  // Update exhibit analytics
  Future<void> _updateExhibitAnalytics(String exhibitId) async {
    try {
      DocumentReference analyticsRef = _firestore
          .collection('exhibitAnalytics')
          .doc(exhibitId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(analyticsRef);
        
        if (snapshot.exists) {
          transaction.update(analyticsRef, {
            'totalVisits': FieldValue.increment(1),
            'lastVisitAt': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(analyticsRef, {
            'exhibitId': exhibitId,
            'totalVisits': 1,
            'uniqueVisitors': 1,
            'lastVisitAt': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to update analytics: $e');
    }
  }

  // Get all exhibits
  Future<List<Exhibit>> getAllExhibits() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('exhibits')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Exhibit.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get exhibits: $e');
    }
  }

  // Get exhibit by ID
  Future<Exhibit?> getExhibitById(String exhibitId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('exhibits')
          .doc(exhibitId)
          .get();

      if (!doc.exists) return null;

      return Exhibit.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get exhibit: $e');
    }
  }

  // Get user's visit history
  Future<List<ExhibitVisit>> getUserVisitHistory() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return [];

      QuerySnapshot snapshot = await _firestore
          .collection('exhibitVisits')
          .where('userId', isEqualTo: user.uid)
          .orderBy('scanTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ExhibitVisit.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get visit history: $e');
    }
  }

  // Create sample exhibit (for testing)
  Future<void> createSampleExhibit(String id, String name, String description, String location) async {
    try {
      Exhibit exhibit = Exhibit(
        id: id,
        name: name,
        description: description,
        location: location,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('exhibits')
          .doc(id)
          .set(exhibit.toMap());
    } catch (e) {
      throw Exception('Failed to create sample exhibit: $e');
    }
  }
}
