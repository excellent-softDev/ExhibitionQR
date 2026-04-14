import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/exhibit_provider.dart';
import '../services/exhibit_service.dart';
import '../services/auth_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onQRCodeDetected(String qrCode) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final exhibitService = Provider.of<ExhibitService>(context, listen: false);
      final exhibitProvider = Provider.of<ExhibitProvider>(context, listen: false);

      // Ensure user is authenticated
      if (authService.currentUser == null) {
        throw Exception('Please sign in to scan QR codes');
      }

      // Validate QR code format (should be exhibit ID)
      if (qrCode.isEmpty || !RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(qrCode)) {
        throw Exception('Invalid QR code format');
      }

      // Check if exhibit exists
      final exhibit = await exhibitService.getExhibitById(qrCode);
      if (exhibit == null) {
        throw Exception('Exhibit not found');
      }

      // Record the visit
      await exhibitService.recordExhibitVisit(qrCode);

      // Show success message
      if (mounted) {
        _showSuccessDialog(exhibit);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog(dynamic exhibit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Successfully Scanned!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exhibit: ${exhibit.name}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Location: ${exhibit.location}'),
            SizedBox(height: 8),
            Text(
              'Your visit has been recorded successfully.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Continue scanning
            },
            child: Text('Scan Another'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Scan Error'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _onQRCodeDetected(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          
          // Scanning overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          // Instructions
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Position the QR code within the frame to scan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
