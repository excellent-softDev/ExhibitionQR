class AppConstants {
  // App Information
  static const String appName = 'Exhibition Tracker';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String exhibitsCollection = 'exhibits';
  static const String exhibitVisitsCollection = 'exhibitVisits';
  static const String userSessionsCollection = 'userSessions';
  static const String exhibitAnalyticsCollection = 'exhibitAnalytics';
  
  // SharedPreferences Keys
  static const String userPrefsKey = 'user_preferences';
  static const String themePrefsKey = 'theme_preferences';
  static const String firstLaunchKey = 'first_launch';
  static const String lastLoginKey = 'last_login';
  
  // QR Code Validation
  static const String qrCodePattern = r'^[a-zA-Z0-9_-]+$';
  static const int maxQrCodeLength = 50;
  
  // Session Management
  static const Duration sessionTimeout = Duration(hours: 8);
  static const Duration autoSyncInterval = Duration(minutes: 5);
  
  // Cache Settings
  static const Duration cacheExpiry = Duration(hours: 24);
  static const int maxCacheSize = 100;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double largeBorderRadius = 12.0;
  
  // Colors
  static const int primaryColorValue = 0xFF2196F3;
  static const int secondaryColorValue = 0xFF1976D2;
  static const int accentColorValue = 0xFFFF9800;
  static const int errorColorValue = 0xFFF44336;
  static const int successColorValue = 0xFF4CAF50;
  static const int warningColorValue = 0xFFFF9800;
  
  // Text Styles
  static const double headlineTextSize = 24.0;
  static const double titleTextSize = 20.0;
  static const double bodyTextSize = 16.0;
  static const double captionTextSize = 12.0;
  
  // API Limits
  static const int maxRetries = 3;
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxResultsPerPage = 20;
  
  // Analytics
  static const int defaultAnalyticsLimit = 10;
  static const int maxAnalyticsLimit = 100;
  static const Duration analyticsRefreshInterval = Duration(minutes: 1);
}

class AppStrings {
  // General
  static const String appName = 'Exhibition Tracker';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String cancel = 'Cancel';
  static const String ok = 'OK';
  static const String retry = 'Retry';
  static const String close = 'Close';
  static const String continueText = 'Continue';
  static const String done = 'Done';
  
  // Authentication
  static const String signIn = 'Sign In';
  static const String signOut = 'Sign Out';
  static const String signUp = 'Sign Up';
  static const String welcome = 'Welcome';
  static const String signInWithGoogle = 'Continue with Google';
  static const String continueAsGuest = 'Continue as Guest';
  static const String profile = 'Profile';
  
  // QR Scanning
  static const String scanQRCode = 'Scan QR Code';
  static const String scanning = 'Scanning...';
  static const String scanSuccess = 'Successfully Scanned!';
  static const String scanError = 'Scan Error';
  static const String invalidQRCode = 'Invalid QR Code format';
  static const String exhibitNotFound = 'Exhibit not found';
  static const String positionQRCode = 'Position the QR code within the frame to scan';
  static const String processing = 'Processing...';
  
  // Navigation
  static const String home = 'Home';
  static const String history = 'History';
  static const String analytics = 'Analytics';
  static const String settings = 'Settings';
  static const String about = 'About';
  
  // History
  static const String visitHistory = 'Visit History';
  static const String noVisitsYet = 'No visits yet';
  static const String startScanning = 'Start Scanning';
  static const String visitDetails = 'Visit Details';
  static const String exhibitsVisited = 'Exhibits Visited';
  static const String activeSession = 'Active Session';
  static const String scanTime = 'Scan Time';
  static const String leaveTime = 'Leave Time';
  static const String duration = 'Duration';
  static const String exhibitId = 'Exhibit ID';
  static const String sessionId = 'Session ID';
  
  // Analytics
  static const String overview = 'Overview';
  static const String totalExhibits = 'Total Exhibits';
  static const String totalVisits = 'Total Visits';
  static const String activeSessions = 'Active Sessions';
  static const String avgDailyVisits = 'Avg Daily Visits';
  static const String mostVisitedExhibits = 'Most Visited Exhibits';
  static const String peakVisitingHours = 'Peak Visiting Hours';
  static const String topExhibits = 'Top Exhibits';
  static const String visits = 'visits';
  static const String unknown = 'Unknown';
  static const String unknownLocation = 'Unknown location';
  
  // Error Messages
  static const String networkError = 'Network connection error. Please check your internet connection.';
  static const String authError = 'Authentication error. Please sign in again.';
  static const String permissionError = 'Permission denied. You don\'t have access to this resource.';
  static const String notFoundError = 'Resource not found.';
  static const String timeoutError = 'Request timed out. Please try again.';
  static const String unexpectedError = 'An unexpected error occurred. Please try again.';
  
  // Success Messages
  static const String visitRecorded = 'Your visit has been recorded successfully.';
  static const String sessionStarted = 'Session started successfully.';
  static const String sessionEnded = 'Session ended successfully.';
  static const String dataSynced = 'Data synced successfully.';
  
  // Instructions
  static const String welcomeMessage = 'Track your exhibition journey';
  static const String scanInstructions = 'Scan QR codes at exhibit stations to track your journey through the exhibition.';
  static const String noVisitsInstructions = 'Start scanning QR codes to track your exhibition journey';
  static const String termsAndPrivacy = 'By continuing, you agree to our Terms of Service and Privacy Policy';
}
