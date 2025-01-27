import 'package:flutter/material.dart';
import 'package:lifelens/screens/contactDetails.dart';
import 'package:lifelens/screens/splash_screen.dart';
import 'package:lifelens/screens/todo.dart';
import 'package:lifelens/screens/userProfile.dart';

class Dashboard extends StatefulWidget {
  static const routeName = '/dashboard';
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _AppBar(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Welcome to LifeLens',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  final items = [
                    {
                      'icon': Icons.person,
                      'label': 'User Profile',
                      'onTap': () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Userprofile()),
                        );
                      }
                    },
                    {
                      'icon': Icons.monetization_on,
                      'label': 'Financial Overview',
                      'onTap': () {
                        // Handle navigation
                      }
                    },
                    {
                      'icon': Icons.schedule,
                      'label': 'Schedule Overview',
                      'onTap': () {
                        // Handle navigation
                      }
                    },
                    {
                      'icon': Icons.check_circle,
                      'label': 'View Tasks',
                      'onTap': () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Todo()),
                        );
                      }
                    },
                    {
                      'icon': Icons.contact_phone,
                      'label': 'Contact Details',
                      'onTap': () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ContactDetails()),
                        );
                      }
                    },
                    {
                      'icon': Icons.health_and_safety,
                      'label': 'Health',
                      'onTap': () {
                        // Handle navigation
                      }
                    },
                  ];

                  final item = items[index];
                  return _DashboardItem(
                    icon: item['icon'] as IconData,
                    label: item['label'] as String,
                    onTap: item['onTap'] as VoidCallback,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SplashScreen()),
                  );
                },
                child: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'LifeLens',
        style: TextStyle(color: Colors.green),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DashboardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
