import 'package:flutter/material.dart';

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class AuthException extends AppException {
  AuthException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class ValidationException extends AppException {
  ValidationException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class DatabaseException extends AppException {
  DatabaseException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class ErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    String message = 'An unexpected error occurred';
    String title = 'Error';
    Color backgroundColor = Colors.red;

    if (error is AppException) {
      message = error.message;
      
      if (error is NetworkException) {
        title = 'Network Error';
        backgroundColor = Colors.orange;
      } else if (error is AuthException) {
        title = 'Authentication Error';
        backgroundColor = Colors.red;
      } else if (error is ValidationException) {
        title = 'Validation Error';
        backgroundColor = Colors.amber;
      } else if (error is DatabaseException) {
        title = 'Database Error';
        backgroundColor = Colors.red;
      }
    } else {
      // Handle common Firebase errors
      if (error.toString().contains('network')) {
        title = 'Network Error';
        message = 'Please check your internet connection and try again.';
        backgroundColor = Colors.orange;
      } else if (error.toString().contains('permission')) {
        title = 'Permission Error';
        message = 'You don\'t have permission to perform this action.';
        backgroundColor = Colors.red;
      } else if (error.toString().contains('not-found')) {
        title = 'Not Found';
        message = 'The requested resource was not found.';
        backgroundColor = Colors.amber;
      } else {
        message = error.toString();
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    
    final errorString = error.toString();
    
    if (errorString.contains('network')) {
      return 'Network connection error. Please check your internet connection.';
    } else if (errorString.contains('permission')) {
      return 'Permission denied. You don\'t have access to this resource.';
    } else if (errorString.contains('not-found')) {
      return 'Resource not found.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('cancelled')) {
      return 'Operation was cancelled.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static void showErrorDialog(BuildContext context, dynamic error) {
    String title = 'Error';
    String message = getErrorMessage(error);

    if (error is AppException) {
      if (error is NetworkException) {
        title = 'Network Error';
      } else if (error is AuthException) {
        title = 'Authentication Error';
      } else if (error is ValidationException) {
        title = 'Validation Error';
      } else if (error is DatabaseException) {
        title = 'Database Error';
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Utility class for safe operations
class SafeOperation {
  static Future<T?> safeAsyncOperation<T>(
    Future<T> Function() operation, {
    T? defaultValue,
    void Function(dynamic error)? onError,
  }) async {
    try {
      return await operation();
    } catch (error) {
      onError?.call(error);
      return defaultValue;
    }
  }

  static T? safeOperation<T>(
    T Function() operation, {
    T? defaultValue,
    void Function(dynamic error)? onError,
  }) {
    try {
      return operation();
    } catch (error) {
      onError?.call(error);
      return defaultValue;
    }
  }
}
