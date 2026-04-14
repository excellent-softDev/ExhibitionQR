import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/exhibit.dart';

class OfflineService {
  static const String _pendingVisitsKey = 'pending_visits';
  static const String _pendingSessionsKey = 'pending_sessions';
  static const String _cachedExhibitsKey = 'cached_exhibits';
  static const String _lastSyncKey = 'last_sync';

  // Save visit for offline sync
  Future<void> savePendingVisit(ExhibitVisit visit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> pendingVisits = prefs.getStringList(_pendingVisitsKey) ?? [];
      
      pendingVisits.add(jsonEncode(visit.toMap()));
      await prefs.setStringList(_pendingVisitsKey, pendingVisits);
    } catch (e) {
      throw Exception('Failed to save pending visit: $e');
    }
  }

  // Save session for offline sync
  Future<void> savePendingSession(UserSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> pendingSessions = prefs.getStringList(_pendingSessionsKey) ?? [];
      
      pendingSessions.add(jsonEncode(session.toMap()));
      await prefs.setStringList(_pendingSessionsKey, pendingSessions);
    } catch (e) {
      throw Exception('Failed to save pending session: $e');
    }
  }

  // Get all pending visits
  Future<List<ExhibitVisit>> getPendingVisits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> pendingVisits = prefs.getStringList(_pendingVisitsKey) ?? [];
      
      return pendingVisits.map((visitJson) {
        final Map<String, dynamic> visitMap = jsonDecode(visitJson);
        return ExhibitVisit.fromMap(visitMap);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get pending visits: $e');
    }
  }

  // Get all pending sessions
  Future<List<UserSession>> getPendingSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> pendingSessions = prefs.getStringList(_pendingSessionsKey) ?? [];
      
      return pendingSessions.map((sessionJson) {
        final Map<String, dynamic> sessionMap = jsonDecode(sessionJson);
        return UserSession.fromMap(sessionMap);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get pending sessions: $e');
    }
  }

  // Clear pending visits after successful sync
  Future<void> clearPendingVisits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingVisitsKey);
    } catch (e) {
      throw Exception('Failed to clear pending visits: $e');
    }
  }

  // Clear pending sessions after successful sync
  Future<void> clearPendingSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingSessionsKey);
    } catch (e) {
      throw Exception('Failed to clear pending sessions: $e');
    }
  }

  // Cache exhibits for offline access
  Future<void> cacheExhibits(List<Exhibit> exhibits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> exhibitsJson = exhibits
          .map((exhibit) => jsonEncode(exhibit.toMap()))
          .toList();
      
      await prefs.setStringList(_cachedExhibitsKey, exhibitsJson);
      await _updateLastSyncTime();
    } catch (e) {
      throw Exception('Failed to cache exhibits: $e');
    }
  }

  // Get cached exhibits
  Future<List<Exhibit>> getCachedExhibits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> exhibitsJson = prefs.getStringList(_cachedExhibitsKey) ?? [];
      
      return exhibitsJson.map((exhibitJson) {
        final Map<String, dynamic> exhibitMap = jsonDecode(exhibitJson);
        return Exhibit.fromMap(exhibitMap);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get cached exhibits: $e');
    }
  }

  // Check if has internet connection
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncMillis = prefs.getInt(_lastSyncKey);
      return lastSyncMillis != null 
          ? DateTime.fromMillisecondsSinceEpoch(lastSyncMillis)
          : null;
    } catch (e) {
      return null;
    }
  }

  // Update last sync time
  Future<void> _updateLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Ignore error for last sync time
    }
  }

  // Get offline statistics
  Future<Map<String, dynamic>> getOfflineStats() async {
    try {
      final pendingVisits = await getPendingVisits();
      final pendingSessions = await getPendingSessions();
      final lastSync = await getLastSyncTime();
      final cachedExhibits = await getCachedExhibits();
      
      return {
        'pendingVisits': pendingVisits.length,
        'pendingSessions': pendingSessions.length,
        'lastSync': lastSync,
        'cachedExhibits': cachedExhibits.length,
        'hasData': pendingVisits.isNotEmpty || pendingSessions.isNotEmpty,
      };
    } catch (e) {
      return {
        'pendingVisits': 0,
        'pendingSessions': 0,
        'lastSync': null,
        'cachedExhibits': 0,
        'hasData': false,
      };
    }
  }

  // Monitor connectivity changes
  Stream<ConnectivityResult> get connectivityStream =>
      Connectivity().onConnectivityChanged;
}

class OfflineSyncService {
  final OfflineService _offlineService = OfflineService();
  
  // Sync pending data when online
  Future<void> syncPendingData() async {
    try {
      final hasConnection = await _offlineService.hasInternetConnection();
      if (!hasConnection) {
        return;
      }

      // Sync pending visits
      await _syncPendingVisits();
      
      // Sync pending sessions
      await _syncPendingSessions();
      
    } catch (e) {
      throw Exception('Failed to sync pending data: $e');
    }
  }

  Future<void> _syncPendingVisits() async {
    try {
      final pendingVisits = await _offlineService.getPendingVisits();
      if (pendingVisits.isEmpty) return;

      // Here you would sync with Firebase
      // For now, we'll just clear the pending visits
      // In a real implementation, you would:
      // 1. Try to upload each visit to Firestore
      // 2. Only remove from pending if successful
      // 3. Handle partial failures and retries
      
      await _offlineService.clearPendingVisits();
    } catch (e) {
      throw Exception('Failed to sync pending visits: $e');
    }
  }

  Future<void> _syncPendingSessions() async {
    try {
      final pendingSessions = await _offlineService.getPendingSessions();
      if (pendingSessions.isEmpty) return;

      // Here you would sync with Firebase
      // Similar to visits, handle partial failures
      
      await _offlineService.clearPendingSessions();
    } catch (e) {
      throw Exception('Failed to sync pending sessions: $e');
    }
  }
}
