class SimpleExhibit {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime createdAt;

  SimpleExhibit({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.createdAt,
  });

  factory SimpleExhibit.fromMap(Map<String, dynamic> map) {
    return SimpleExhibit(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      createdAt: map['createdAt'] is DateTime 
          ? map['createdAt']
          : DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class SimpleExhibitVisit {
  final String id;
  final String sessionId;
  final String exhibitId;
  final String userId;
  final DateTime scanTime;
  final DateTime? leaveTime;
  final Duration? duration;

  SimpleExhibitVisit({
    required this.id,
    required this.sessionId,
    required this.exhibitId,
    required this.userId,
    required this.scanTime,
    this.leaveTime,
    this.duration,
  });

  factory SimpleExhibitVisit.fromMap(Map<String, dynamic> map) {
    return SimpleExhibitVisit(
      id: map['id'] ?? '',
      sessionId: map['sessionId'] ?? '',
      exhibitId: map['exhibitId'] ?? '',
      userId: map['userId'] ?? '',
      scanTime: map['scanTime'] is DateTime 
          ? map['scanTime']
          : DateTime.parse(map['scanTime']),
      leaveTime: map['leaveTime'] != null 
          ? (map['leaveTime'] is DateTime 
              ? map['leaveTime']
              : DateTime.parse(map['leaveTime']))
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
      'scanTime': scanTime.toIso8601String(),
      'leaveTime': leaveTime?.toIso8601String(),
      'duration': duration?.inSeconds,
    };
  }
}

class SimpleUserSession {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;

  SimpleUserSession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.isActive,
  });

  factory SimpleUserSession.fromMap(Map<String, dynamic> map) {
    return SimpleUserSession(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      startTime: map['startTime'] is DateTime 
          ? map['startTime']
          : DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null 
          ? (map['endTime'] is DateTime 
              ? map['endTime']
              : DateTime.parse(map['endTime']))
          : null,
      isActive: map['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isActive': isActive,
    };
  }
}
