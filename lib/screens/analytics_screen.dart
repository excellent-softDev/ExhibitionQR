import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart';
import '../providers/exhibit_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _overallAnalytics = {};
  List<Map<String, dynamic>> _mostVisited = [];
  Map<int, int> _peakHours = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final analyticsService = Provider.of<AnalyticsService>(context, listen: false);

      final results = await Future.wait([
        analyticsService.getOverallAnalytics(),
        analyticsService.getMostVisitedExhibits(limit: 5),
        analyticsService.getPeakVisitingHours(),
      ]);

      if (mounted) {
        setState(() {
          _overallAnalytics = results[0] as Map<String, dynamic>;
          _mostVisited = results[1] as List<Map<String, dynamic>>;
          _peakHours = results[2] as Map<int, int>;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading analytics: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Cards
                  _buildOverviewCards(),
                  
                  const SizedBox(height: 24),
                  
                  // Most Visited Exhibits Chart
                  _buildMostVisitedChart(),
                  
                  const SizedBox(height: 24),
                  
                  // Peak Hours Chart
                  _buildPeakHoursChart(),
                  
                  const SizedBox(height: 24),
                  
                  // Most Visited List
                  _buildMostVisitedList(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                title: 'Total Exhibits',
                value: '${_overallAnalytics['totalExhibits'] ?? 0}',
                icon: Icons.museum,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OverviewCard(
                title: 'Total Visits',
                value: '${_overallAnalytics['totalVisits'] ?? 0}',
                icon: Icons.visibility,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                title: 'Active Sessions',
                value: '${_overallAnalytics['activeSessions'] ?? 0}',
                icon: Icons.people,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OverviewCard(
                title: 'Avg Daily Visits',
                value: '${(_overallAnalytics['averageVisitsPerDay'] ?? 0).toStringAsFixed(1)}',
                icon: Icons.trending_up,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMostVisitedChart() {
    if (_mostVisited.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Most Visited Exhibits',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _mostVisited.isNotEmpty 
                      ? (_mostVisited.first['totalVisits'] as int).toDouble() * 1.2
                      : 10,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final exhibit = _mostVisited[group.x.toInt()];
                        return BarTooltipItem(
                          '${exhibit['exhibitName']}\nVisits: ${exhibit['totalVisits']}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < _mostVisited.length) {
                            final exhibit = _mostVisited[value.toInt()];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                exhibit['exhibitName'].toString().length > 8
                                    ? '${exhibit['exhibitName'].toString().substring(0, 8)}...'
                                    : exhibit['exhibitName'].toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _mostVisited.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: (entry.value['totalVisits'] as int).toDouble(),
                          color: Colors.blue,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeakHoursChart() {
    if (_peakHours.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxVisits = _peakHours.values.fold(0, (max, visits) => visits > max ? visits : max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Peak Visiting Hours',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVisits.toDouble() * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${group.x.toInt()}:00 - ${group.x.toInt() + 1}:00\nVisits: ${rod.toY.toInt()}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${value.toInt()}:00',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        interval: 3,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(24, (hour) {
                    return BarChartGroupData(
                      x: hour,
                      barRods: [
                        BarChartRodData(
                          toY: _peakHours[hour]?.toDouble() ?? 0,
                          color: Colors.orange,
                          width: 8,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMostVisitedList() {
    if (_mostVisited.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Exhibits',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: _mostVisited.asMap().entries.map((entry) {
              final index = entry.key;
              final exhibit = entry.value;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(index),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(exhibit['exhibitName'] ?? 'Unknown'),
                subtitle: Text(exhibit['exhibitLocation'] ?? 'Unknown location'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${exhibit['totalVisits']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'visits',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
