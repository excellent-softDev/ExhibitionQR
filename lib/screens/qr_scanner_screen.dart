import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../models/exhibit.dart';
import '../providers/exhibit_provider.dart';
import '../services/exhibit_service.dart';
import 'exhibit_detail_screen.dart';
=======
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/exhibit_provider.dart';
import '../services/exhibit_service.dart';
import '../services/auth_service.dart';
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
<<<<<<< HEAD
  final MobileScannerController _scannerController = MobileScannerController();
  final TextEditingController _manualCodeController = TextEditingController();
  bool _isProcessing = false;
  String? _statusMessage;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(String rawValue) async {
=======
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onQRCodeDetected(String qrCode) async {
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
<<<<<<< HEAD
      _statusMessage = 'Matching scanned code to an exhibit...';
    });

    try {
      final exhibitService = Provider.of<ExhibitService>(context, listen: false);
      final exhibitProvider = Provider.of<ExhibitProvider>(context, listen: false);

      Exhibit? exhibit = await exhibitService.getExhibitByQrCode(rawValue);
      exhibit ??= await exhibitService.getExhibitById(rawValue);

      if (exhibit == null) {
        throw Exception('No exhibit found for the scanned QR code. Make sure the QR code is linked to an exhibit in the database.');
      }

      final visit = await exhibitService.recordExhibitVisit(exhibit.id);
      exhibitProvider.addVisit(visit);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ExhibitDetailScreen(
              exhibit: exhibit!,
              visit: visit,
            ),
          ),
        );
=======
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
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
<<<<<<< HEAD
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
      }
    }
  }

=======
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

>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
<<<<<<< HEAD
          children: const [
=======
          children: [
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Scan Error'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
<<<<<<< HEAD
            child: const Text('OK'),
=======
            child: Text('OK'),
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text('QR Scanner'),
=======
        title: const Text('Scan QR Code'),
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
<<<<<<< HEAD
          kIsWeb ? _buildWebScanner() : _buildMobileScanner(),
          if (_isProcessing)
            Container(
              color: const Color.fromRGBO(0, 0, 0, 0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileScanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;
              final String? rawValue = barcodes.first.rawValue;
              if (rawValue != null) {
                _handleBarcode(rawValue);
              }
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Scan the exhibit QR code to verify it against the database and record a visit.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                _statusMessage ?? 'Point your camera at a valid exhibit QR code.',
                style: TextStyle(
                  color: _statusMessage == null ? Colors.grey[700] : Colors.blue[700],
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _scannerController.switchCamera(),
                icon: const Icon(Icons.cameraswitch),
                label: const Text('Switch Camera'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebScanner() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Icon(
            Icons.qr_code_scanner,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          const Text(
            'QR Scanner (Web Mode)',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Camera scanning is not available in web browsers. Please manually enter the QR code from the exhibit.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _manualCodeController,
            decoration: const InputDecoration(
              labelText: 'Enter QR Code',
              border: OutlineInputBorder(),
              hintText: 'Scan the QR code with your phone and enter the code here',
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _handleBarcode(value.trim());
              }
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final code = _manualCodeController.text.trim();
              if (code.isNotEmpty) {
                _handleBarcode(code);
              }
            },
            icon: const Icon(Icons.search),
            label: const Text('Submit Code'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _statusMessage ?? 'Enter the QR code to verify it against the database.',
            style: TextStyle(
              color: _statusMessage == null ? Colors.grey[700] : Colors.blue[700],
            ),
            textAlign: TextAlign.center,
          ),
=======
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
>>>>>>> 7ccc8a6285d662f9bcf39fa1edc311b491fd0dc5
        ],
      ),
    );
  }
}
