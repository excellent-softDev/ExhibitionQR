import 'package:flutter/material.dart';
import '../models/exhibit.dart';

class ExhibitProvider with ChangeNotifier {
  List<Exhibit> _exhibits = [];
  List<ExhibitVisit> _visitHistory = [];
  Map<String, dynamic> _analytics = {};
  bool _isLoading = false;
  String? _error;

  List<Exhibit> get exhibits => _exhibits;
  List<ExhibitVisit> get visitHistory => _visitHistory;
  Map<String, dynamic> get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setExhibits(List<Exhibit> exhibits) {
    _exhibits = exhibits;
    notifyListeners();
  }

  void setVisitHistory(List<ExhibitVisit> visitHistory) {
    _visitHistory = visitHistory;
    notifyListeners();
  }

  void setAnalytics(Map<String, dynamic> analytics) {
    _analytics = analytics;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void addVisit(ExhibitVisit visit) {
    _visitHistory.insert(0, visit);
    notifyListeners();
  }

  void updateExhibit(Exhibit updatedExhibit) {
    int index = _exhibits.indexWhere((exhibit) => exhibit.id == updatedExhibit.id);
    if (index != -1) {
      _exhibits[index] = updatedExhibit;
      notifyListeners();
    }
  }

  // Sample data for demo mode
  List<Map<String, dynamic>> _sampleVisits = [];
  List<Map<String, dynamic>> get sampleVisits => _sampleVisits;

  void setSampleData(List<Map<String, dynamic>> sampleData) {
    _sampleVisits = sampleData;
    notifyListeners();
  }

  void addSampleVisit(Map<String, dynamic> visit) {
    _sampleVisits.insert(0, visit);
    notifyListeners();
  }
}
