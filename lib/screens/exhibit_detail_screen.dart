import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exhibit.dart';
import '../services/exhibit_service.dart';
import '../providers/exhibit_provider.dart';
import 'qr_scanner_screen.dart';

class ExhibitDetailScreen extends StatefulWidget {
  final Exhibit exhibit;
  final ExhibitVisit visit;

  const ExhibitDetailScreen({
    super.key,
    required this.exhibit,
    required this.visit,
  });

  @override
  State<ExhibitDetailScreen> createState() => _ExhibitDetailScreenState();
}

class _ExhibitDetailScreenState extends State<ExhibitDetailScreen> {
  late DateTime _startTime;
  Duration _elapsedTime = Duration.zero;
  bool _isTimerRunning = true;
  final TextEditingController _commentController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startTimer();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isTimerRunning) {
        setState(() {
          _elapsedTime = DateTime.now().difference(_startTime);
        });
        _startTimer();
      }
    });
  }

  void _stopTimer() {
    setState(() {
      _isTimerRunning = false;
      _elapsedTime = DateTime.now().difference(_startTime);
    });
  }

  Future<void> _finishVisit() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final exhibitService = Provider.of<ExhibitService>(context, listen: false);
      final exhibitProvider = Provider.of<ExhibitProvider>(context, listen: false);

      // Update the visit with leave time and comment
      await exhibitService.updateExhibitVisit(
        widget.visit.id,
        leaveTime: DateTime.now(),
        comment: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
      );

      // Update the visit in provider
      final updatedVisit = ExhibitVisit(
        id: widget.visit.id,
        sessionId: widget.visit.sessionId,
        exhibitId: widget.visit.exhibitId,
        userId: widget.visit.userId,
        scanTime: widget.visit.scanTime,
        leaveTime: DateTime.now(),
        duration: _elapsedTime,
        sessionDuration: widget.visit.sessionDuration,
        comment: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
      );

      exhibitProvider.updateVisit(updatedVisit);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visit completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to scanner
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const QRScannerScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving visit: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exhibit Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exhibit Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.museum, size: 32, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.exhibit.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.exhibit.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Location: ${widget.exhibit.location ?? 'Not specified'}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.qr_code, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'QR Code: ${widget.exhibit.qrCode}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Timer Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Time Spent on Exhibit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isTimerRunning ? Colors.green[50] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isTimerRunning ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        _formatDuration(_elapsedTime),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _isTimerRunning ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isTimerRunning ? Icons.timer : Icons.timer_off,
                          color: _isTimerRunning ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isTimerRunning ? 'Timer Running' : 'Timer Stopped',
                          style: TextStyle(
                            color: _isTimerRunning ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Comment Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comments (Optional)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Share your thoughts about this exhibit...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTimerRunning ? _stopTimer : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Timer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: !_isTimerRunning && !_isSaving ? _finishVisit : null,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isSaving ? 'Saving...' : 'Done with Exhibit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Scan Next Exhibit Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const QRScannerScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Another Exhibit'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}