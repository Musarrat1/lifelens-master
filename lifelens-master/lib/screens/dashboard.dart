import 'package:flutter/material.dart';
import 'package:lifelens/screens/add.dart';
import 'package:lifelens/screens/addTransactionScreen.dart';
import 'package:lifelens/screens/contactDetails.dart';
import 'package:lifelens/screens/healthDataScreen.dart';
import 'package:lifelens/screens/healthEntryScreen.dart';
import 'package:lifelens/screens/schedule.dart';
import 'package:lifelens/screens/sign_in.dart';
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
      appBar: AppBar(
         leading: IconButton(onPressed: (){

            Navigator.push(context, MaterialPageRoute(builder: (context)=>SignInScreen()));
    }, icon: Icon(Icons.arrow_back
          ),),
        backgroundColor: Colors.white,
        title: Text("LifeLens",style: TextStyle(color: Colors.green,fontSize: 20,fontWeight: FontWeight.bold),),
        elevation: 0,

      ),



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
                fontSize: 32,
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
                              builder: (context) =>  UserInfoScreen()),
                        );
                      }
                    },
                    {
                      'icon': Icons.monetization_on,
                      'label': 'Financial Overview',
                      'onTap': () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()));
                        // Handle navigation
                      }
                    },
                    {
                      'icon': Icons.schedule,
                      'label': 'Schedule Overview',
                      'onTap': () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                            builder: (context) => ScheduleScreen()));
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

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  HealthDataScreen()),
                        );
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
