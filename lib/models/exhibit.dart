import 'package:cloud_firestore/cloud_firestore.dart';

class Exhibit {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime createdAt;

  Exhibit({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.createdAt,
  });

  factory Exhibit.fromMap(Map<String, dynamic> map) {
    return Exhibit(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class ExhibitVisit {
  final String id;
  final String sessionId;
  final String exhibitId;
  final String userId;
  final DateTime scanTime;
  final DateTime? leaveTime;
  final Duration? duration;

  ExhibitVisit({
    required this.id,
    required this.sessionId,
    required this.exhibitId,
    required this.userId,
    required this.scanTime,
    this.leaveTime,
    this.duration,
  });

  factory ExhibitVisit.fromMap(Map<String, dynamic> map) {
    return ExhibitVisit(
      id: map['id'] ?? '',
      sessionId: map['sessionId'] ?? '',
      exhibitId: map['exhibitId'] ?? '',
      userId: map['userId'] ?? '',
      scanTime: (map['scanTime'] as Timestamp).toDate(),
      leaveTime: map['leaveTime'] != null 
          ? (map['leaveTime'] as Timestamp).toDate() 
          : null,
      duration: map['duration'] != null 
          ? Duration(seconds: map['duration']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'exhibitId': exhibitId,
      'userId': userId,
      'scanTime': Timestamp.fromDate(scanTime),
      'leaveTime': leaveTime != null 
          ? Timestamp.fromDate(leaveTime!) 
          : null,
      'duration': duration?.inSeconds,
    };
  }
}

class UserSession {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;

  UserSession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.isActive,
  });

  factory UserSession.fromMap(Map<String, dynamic> map) {
    return UserSession(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null 
          ? (map['endTime'] as Timestamp).toDate() 
          : null,
      isActive: map['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null 
          ? Timestamp.fromDate(endTime!) 
          : null,
      'isActive': isActive,
    };
  }
}
