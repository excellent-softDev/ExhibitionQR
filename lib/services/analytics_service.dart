import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exhibit.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get most visited exhibits
  Future<List<Map<String, dynamic>>> getMostVisitedExhibits({int limit = 10}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('exhibitAnalytics')
          .orderBy('totalVisits', descending: true)
          .limit(limit)
          .get();

      List<Map<String, dynamic>> results = [];
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String exhibitId = data['exhibitId'];
        
        // Get exhibit details
        DocumentSnapshot exhibitDoc = await _firestore
            .collection('exhibits')
            .doc(exhibitId)
            .get();
        
        if (exhibitDoc.exists) {
          Map<String, dynamic> exhibitData = exhibitDoc.data() as Map<String, dynamic>;
          results.add({
            'exhibitId': exhibitId,
            'exhibitName': exhibitData['name'] ?? 'Unknown',
            'exhibitLocation': exhibitData['location'] ?? 'Unknown',
            'totalVisits': data['totalVisits'] ?? 0,
            'uniqueVisitors': data['uniqueVisitors'] ?? 0,
            'lastVisitAt': data['lastVisitAt'],
          });
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to get most visited exhibits: $e');
    }
  }

  // Get visit statistics for a specific exhibit
  Future<Map<String, dynamic>> getExhibitStatistics(String exhibitId) async {
    try {
      // Get analytics data
      DocumentSnapshot analyticsDoc = await _firestore
          .collection('exhibitAnalytics')
          .doc(exhibitId)
          .get();

      // Get exhibit details
      DocumentSnapshot exhibitDoc = await _firestore
          .collection('exhibits')
          .doc(exhibitId)
          .get();

      // Get visit data for time analysis
      QuerySnapshot visitsSnapshot = await _firestore
          .collection('exhibitVisits')
          .where('exhibitId', isEqualTo: exhibitId)
          .orderBy('scanTime', descending: true)
          .get();

      // Calculate average duration
      List<int> durations = [];
      for (var doc in visitsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['duration'] != null) {
          durations.add(data['duration'] as int);
        }
      }

      double averageDuration = durations.isNotEmpty 
          ? durations.reduce((a, b) => a + b) / durations.length 
          : 0.0;

      return {
        'exhibitId': exhibitId,
        'exhibitName': exhibitDoc.exists 
            ? (exhibitDoc.data() as Map<String, dynamic>)['name'] 
            : 'Unknown',
        'totalVisits': analyticsDoc.exists 
            ? (analyticsDoc.data() as Map<String, dynamic>)['totalVisits'] ?? 0 
            : 0,
        'uniqueVisitors': analyticsDoc.exists 
            ? (analyticsDoc.data() as Map<String, dynamic>)['uniqueVisitors'] ?? 0 
            : 0,
        'averageDuration': averageDuration,
        'totalVisitsData': visitsSnapshot.docs.length,
      };
    } catch (e) {
      throw Exception('Failed to get exhibit statistics: $e');
    }
  }

  // Get overall analytics
  Future<Map<String, dynamic>> getOverallAnalytics() async {
    try {
      // Get total exhibits
      QuerySnapshot exhibitsSnapshot = await _firestore
          .collection('exhibits')
          .get();

      // Get total visits
      QuerySnapshot visitsSnapshot = await _firestore
          .collection('exhibitVisits')
          .get();

      // Get total sessions
      QuerySnapshot sessionsSnapshot = await _firestore
          .collection('userSessions')
          .get();

      // Get active sessions
      QuerySnapshot activeSessionsSnapshot = await _firestore
          .collection('userSessions')
          .where('isActive', isEqualTo: true)
          .get();

      // Calculate visits per day for the last 7 days
      DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      QuerySnapshot recentVisitsSnapshot = await _firestore
          .collection('exhibitVisits')
          .where('scanTime', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .get();

      Map<String, int> visitsPerDay = {};
      for (var doc in recentVisitsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime scanTime = (data['scanTime'] as Timestamp).toDate();
        String dayKey = '${scanTime.year}-${scanTime.month.toString().padLeft(2, '0')}-${scanTime.day.toString().padLeft(2, '0')}';
        visitsPerDay[dayKey] = (visitsPerDay[dayKey] ?? 0) + 1;
      }

      return {
        'totalExhibits': exhibitsSnapshot.docs.length,
        'totalVisits': visitsSnapshot.docs.length,
        'totalSessions': sessionsSnapshot.docs.length,
        'activeSessions': activeSessionsSnapshot.docs.length,
        'visitsPerDay': visitsPerDay,
        'averageVisitsPerDay': recentVisitsSnapshot.docs.length / 7.0,
      };
    } catch (e) {
      throw Exception('Failed to get overall analytics: $e');
    }
  }

  // Get visitor flow data (exhibits visited in sequence)
  Future<List<Map<String, dynamic>>> getVisitorFlow() async {
    try {
      QuerySnapshot sessionsSnapshot = await _firestore
          .collection('userSessions')
          .where('isActive', isEqualTo: false)
          .orderBy('startTime', descending: true)
          .limit(50)
          .get();

      List<Map<String, dynamic>> flowData = [];

      for (var sessionDoc in sessionsSnapshot.docs) {
        String sessionId = sessionDoc.id;
        
        QuerySnapshot visitsSnapshot = await _firestore
            .collection('exhibitVisits')
            .where('sessionId', isEqualTo: sessionId)
            .orderBy('scanTime')
            .get();

        if (visitsSnapshot.docs.length > 1) {
          List<String> exhibitSequence = [];
          for (var visitDoc in visitsSnapshot.docs) {
            Map<String, dynamic> data = visitDoc.data() as Map<String, dynamic>;
            exhibitSequence.add(data['exhibitId'] as String);
          }
          
          flowData.add({
            'sessionId': sessionId,
            'exhibitSequence': exhibitSequence,
            'totalExhibits': exhibitSequence.length,
          });
        }
      }

      return flowData;
    } catch (e) {
      throw Exception('Failed to get visitor flow: $e');
    }
  }

  // Get peak visiting hours
  Future<Map<int, int>> getPeakVisitingHours() async {
    try {
      QuerySnapshot visitsSnapshot = await _firestore
          .collection('exhibitVisits')
          .limit(1000)
          .get();

      Map<int, int> hourlyVisits = {};
      for (int i = 0; i < 24; i++) {
        hourlyVisits[i] = 0;
      }

      for (var doc in visitsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime scanTime = (data['scanTime'] as Timestamp).toDate();
        int hour = scanTime.hour;
        hourlyVisits[hour] = (hourlyVisits[hour] ?? 0) + 1;
      }

      return hourlyVisits;
    } catch (e) {
      throw Exception('Failed to get peak visiting hours: $e');
    }
  }
}
