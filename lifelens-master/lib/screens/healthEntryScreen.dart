import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthEntryScreen extends StatefulWidget {
  @override
  _HealthEntryScreenState createState() => _HealthEntryScreenState();
}

class _HealthEntryScreenState extends State<HealthEntryScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _weightController = TextEditingController();
  final _stepsController = TextEditingController();

  void _submitData() async {
    if (_weightController.text.isEmpty || _stepsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    double? weight = double.tryParse(_weightController.text);
    int? steps = int.tryParse(_stepsController.text);

    if (weight == null || steps == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    try {
      // Fetch the latest weight from Firestore
      QuerySnapshot snapshot = await firestore
          .collection('health_data')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      double? previousWeight;
      if (snapshot.docs.isNotEmpty) {
        previousWeight = snapshot.docs.first['weight'];
      }

      // Add the new data
      await firestore.collection('health_data').add({
        'weight': weight,
        'steps': steps,
        'date': Timestamp.now(),
      });

      // Compare weight and give feedback
      String feedback;
      if (previousWeight == null) {
        feedback = "First entry recorded. Keep tracking!";
      } else if (weight < previousWeight) {
        feedback = "Great! Your weight is improving. Keep it up!";
      } else if (weight > previousWeight) {
        feedback = "Your weight increased. Maintain a balanced diet.";
      } else {
        feedback = "Your weight is stable. Stay healthy!";
      }

      // Show the feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(feedback)),
      );

      _weightController.clear();
      _stepsController.clear();

      // Go back to HealthDataScreen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Enter Health Data',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
      backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(

              controller: _weightController,
              decoration: InputDecoration(labelText: 'Weight (kg)',border:OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.green),
              ),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: _stepsController,
              decoration: InputDecoration(labelText: 'Steps',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: _submitData,
              child: Text('Submit',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
