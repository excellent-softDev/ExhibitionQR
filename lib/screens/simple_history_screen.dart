import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/exhibit_provider.dart';

class SimpleHistoryScreen extends StatelessWidget {
  const SimpleHistoryScreen({super.key});

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
            onPressed: () {
              // Refresh data
            },
          ),
        ],
      ),
      body: exhibitProvider.sampleVisits.isEmpty
          ? _buildEmptyState(context)
          : _buildVisitList(exhibitProvider.sampleVisits),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
      onRefresh: () async {
        // Refresh logic
      },
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
  final Map<String, dynamic> visit;

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
          visit['exhibitName'] ?? 'Unknown Exhibit',
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
              'Scanned on ${dateFormat.format(visit['scanTime'])}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'at ${timeFormat.format(visit['scanTime'])}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (visit['duration'] != null)
              Text(
                'Duration: ${_formatDuration(visit['duration'])}',
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

  void _showVisitDetails(BuildContext context, Map<String, dynamic> visit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Visit Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              label: 'Exhibit Name',
              value: visit['exhibitName'] ?? 'Unknown',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: 'Exhibit ID',
              value: visit['exhibitId'] ?? 'Unknown',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: 'Scan Time',
              value: DateFormat('MMM dd, yyyy hh:mm a').format(visit['scanTime']),
            ),
            if (visit['duration'] != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                label: 'Duration',
                value: _formatDuration(visit['duration']),
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
