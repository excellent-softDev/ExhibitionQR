import 'package:flutter/material.dart';

class SimpleQRScreen extends StatefulWidget {
  const SimpleQRScreen({super.key});

  @override
  State<SimpleQRScreen> createState() => _SimpleQRScreenState();
}

class _SimpleQRScreenState extends State<SimpleQRScreen> {
  bool _isScanning = false;
  String? _scannedCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // QR Scanner placeholder
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 3),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 80,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'QR Scanner',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Simulate scan button
              ElevatedButton.icon(
                onPressed: _simulateScan,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Simulate Scan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Manual entry button
              OutlinedButton.icon(
                onPressed: _showManualEntry,
                icon: const Icon(Icons.edit),
                label: const Text('Enter Exhibit ID'),
              ),
              
              if (_scannedCode != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Scanned Code:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _scannedCode!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _confirmScan,
                          child: const Text('Confirm Visit'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _simulateScan() {
    setState(() {
      _scannedCode = 'exhibit_${DateTime.now().millisecondsSinceEpoch % 1000}';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code scanned successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showManualEntry() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Exhibit ID'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., exhibit_001',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _scannedCode = controller.text;
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmScan() {
    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
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
              'Exhibit: $_scannedCode',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Location: Demo Location'),
            const SizedBox(height: 8),
            const Text(
              'Your visit has been recorded successfully.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to home
            },
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _scannedCode = null;
              });
            },
            child: const Text('Scan Another'),
          ),
        ],
      ),
    );
  }
}
