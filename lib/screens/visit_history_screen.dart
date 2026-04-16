import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/exhibit_provider.dart';
import '../services/exhibit_service.dart';

class VisitHistoryScreen extends StatefulWidget {
  const VisitHistoryScreen({super.key});

  @override
  State<VisitHistoryScreen> createState() => _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends State<VisitHistoryScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVisitHistory();
  }

  Future<void> _loadVisitHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final exhibitService = Provider.of<ExhibitService>(context, listen: false);
      final exhibitProvider = Provider.of<ExhibitProvider>(context, listen: false);

      final visitHistory = await exhibitService.getUserVisitHistory();
      exhibitProvider.setVisitHistory(visitHistory);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading visit history: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final exhibitProvider = Provider.of<ExhibitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit History'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVisitHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : exhibitProvider.visitHistory.isEmpty
              ? _buildEmptyState()
              : _buildVisitList(exhibitProvider.visitHistory),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No visits yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start scanning QR codes to track your exhibition journey',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Start Scanning'),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitList(List visits) {
    return RefreshIndicator(
      onRefresh: _loadVisitHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: visits.length,
        itemBuilder: (context, index) {
          final visit = visits[index];
          return _VisitCard(visit: visit);
        },
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final dynamic visit;

  const _VisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.museum,
            color: Colors.blue,
            size: 24,
          ),
        ),
        title: Text(
          'Exhibit ${visit.exhibitId}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Scanned on ${dateFormat.format(visit.scanTime)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'at ${timeFormat.format(visit.scanTime)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (visit.duration != null)
              Text(
                'Duration: ${_formatDuration(visit.duration)}',
                style: TextStyle(
                  color: Colors.green[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showVisitDetails(context, visit),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return '${duration.inSeconds}s';
    } else if (duration.inHours < 1) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
  }

  void _showVisitDetails(BuildContext context, dynamic visit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Visit Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              label: 'Exhibit ID',
              value: visit.exhibitId,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: 'Session ID',
              value: visit.sessionId,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: 'Scan Time',
              value: DateFormat('MMM dd, yyyy hh:mm a').format(visit.scanTime),
            ),
            if (visit.leaveTime != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                label: 'Leave Time',
                value: DateFormat('MMM dd, yyyy hh:mm a').format(visit.leaveTime),
              ),
            ],
            if (visit.duration != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                label: 'Duration',
                value: _formatDuration(visit.duration),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}
