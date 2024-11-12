import 'package:flutter/material.dart';
import 'package:tech_tracking/screens/manager_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Role Based Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

// User credentials model
class User {
  final String username;
  final String password;
  final String role;

  User({required this.username, required this.password, required this.role});
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Hardcoded users
  final List<User> _validUsers = [
    User(username: 'manager', password: 'manager123', role: 'manager'),
    User(username: 'tech1', password: 'tech123', role: 'technician'),
    User(username: 'tech2', password: 'tech456', role: 'technician'),
  ];

  void _login() {
    final enteredUsername = _usernameController.text;
    final enteredPassword = _passwordController.text;

    final user = _validUsers.firstWhere(
      (user) =>
          user.username == enteredUsername && user.password == enteredPassword,
      orElse: () => User(username: '', password: '', role: ''),
    );

    if (user.username.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => user.role == 'manager'
              ? const ManagerDashboard()
              : const TechnicianDashboard(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid credentials!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Technician Dashboard
class TechnicianDashboard extends StatelessWidget {
  const TechnicianDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Technician Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 35),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Technician',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('My Tasks'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Schedule'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Work History'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Today\'s Tasks',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTaskCard(
            title: 'Equipment Maintenance',
            location: 'Workshop A',
            priority: 'High',
            time: '9:00 AM',
            status: 'Pending',
          ),
          _buildTaskCard(
            title: 'System Inspection',
            location: 'Building B',
            priority: 'Medium',
            time: '11:30 AM',
            status: 'In Progress',
          ),
          _buildTaskCard(
            title: 'Repair Request',
            location: 'Floor 3',
            priority: 'Low',
            time: '2:00 PM',
            status: 'Pending',
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String location,
    required String priority,
    required String time,
    required String status,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Text(location),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'Pending'
                        ? Colors.orange
                        : status == 'In Progress'
                            ? Colors.blue
                            : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priority == 'High'
                        ? Colors.red
                        : priority == 'Medium'
                            ? Colors.orange
                            : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    priority,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text(time),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
