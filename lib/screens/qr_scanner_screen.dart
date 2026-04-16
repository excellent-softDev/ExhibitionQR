import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../models/exhibit.dart';
import '../providers/exhibit_provider.dart';
import '../services/exhibit_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
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
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
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
        _showSuccessDialog(exhibit);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
      }
    }
  }

  void _showSuccessDialog(Exhibit exhibit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Exhibit Matched'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exhibit.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Location: ${exhibit.location ?? 'Not specified'}'),
            const SizedBox(height: 8),
            Text('QR Code: ${exhibit.qrCode}'),
            const SizedBox(height: 12),
            const Text(
              'This exhibit visit was recorded successfully. Continue scanning to track more exhibits.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Scan Another'),
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
          children: const [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Scan Error'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
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
        ],
      ),
    );
  }
}
