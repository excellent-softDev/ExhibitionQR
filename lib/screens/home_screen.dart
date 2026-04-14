import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/exhibit_provider.dart';
import '../services/auth_service.dart';
import '../services/exhibit_service.dart';
import 'qr_scanner_screen.dart';
import 'visit_history_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final exhibitService = Provider.of<ExhibitService>(context, listen: false);
    final exhibitProvider = Provider.of<ExhibitProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Load user data
      if (userProvider.user != null) {
        final authService = Provider.of<AuthService>(context, listen: false);
        final userData = await authService.getUserData(userProvider.user!.uid);
        userProvider.setUserData(userData);
      }

      // Load visit history
      final visitHistory = await exhibitService.getUserVisitHistory();
      exhibitProvider.setVisitHistory(visitHistory);
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exhibition Tracker'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showProfileDialog(context, userProvider),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _MainTab(),
          VisitHistoryScreen(),
          AnalyticsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userProvider.userData?['photoURL'] != null)
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(userProvider.userData!['photoURL']),
              )
            else
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
            const SizedBox(height: 16),
            Text(
              userProvider.userData?['displayName'] ?? 'Guest User',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (userProvider.userData?['email'] != null)
              Text(
                userProvider.userData!['email'],
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 8),
            Text(
              'User ID: ${userProvider.user?.uid}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _signOut();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final exhibitService = Provider.of<ExhibitService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // End current session
      await exhibitService.endUserSession();
      
      // Sign out
      await authService.signOut();
      userProvider.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _MainTab extends StatelessWidget {
  const _MainTab();

  bool _isAdmin(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    // Admin users are those with isAdmin field set to true
    return userProvider.userData?['isAdmin'] == true;
  }

  @override
  Widget build(BuildContext context) {
    final exhibitProvider = Provider.of<ExhibitProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome message
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isAdmin(context) ? 'Admin Dashboard' : 'Welcome to Exhibition Tracker',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isAdmin(context) 
                        ? 'Manage exhibition analytics and visitor data.'
                        : 'Scan QR codes at exhibit stations to track your journey through the exhibition.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Main scan button (only for guests)
          if (!_isAdmin(context))
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const QRScannerScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_scanner, size: 32),
              label: const Text(
                'Scan QR Code',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.blue[600],
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Quick stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isAdmin(context) ? 'Exhibition Statistics' : 'Your Progress',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: _isAdmin(context) ? 'Total Visitors' : 'Exhibits Visited',
                          value: _isAdmin(context) ? '0' : exhibitProvider.visitHistory.length.toString(),
                          icon: _isAdmin(context) ? Icons.people : Icons.museum,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: _isAdmin(context) ? 'Active Sessions' : 'Active Session',
                          value: _isAdmin(context) ? '0' : 'Active',
                          icon: Icons.play_circle,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick actions
          Card(
            child: Column(
              children: [
                if (!_isAdmin(context)) ...[
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Visit History'),
                    subtitle: const Text('View your scanned exhibits'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to history tab
                      DefaultTabController.of(context)?.animateTo(1);
                    },
                  ),
                  const Divider(height: 1),
                ],
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: Text(_isAdmin(context) ? 'Analytics Dashboard' : 'Analytics'),
                  subtitle: Text(_isAdmin(context) ? 'View detailed exhibition analytics' : 'View exhibition statistics'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to analytics tab
                    DefaultTabController.of(context)?.animateTo(2);
                  },
                ),
                if (_isAdmin(context)) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.manage_accounts),
                    title: const Text('Manage Exhibits'),
                    subtitle: const Text('Add or edit exhibition exhibits'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Navigate to exhibit management
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exhibit management coming soon!')),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
