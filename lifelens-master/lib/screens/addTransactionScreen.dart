import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _transactionType = 'income';

  void _submitTransaction() async {
    if (_descriptionController.text.isEmpty || _amountController.text.isEmpty) {
      return;
    }

    try {
      await firestore.collection('transactions').add({
        'description': _descriptionController.text,
        'amount': double.parse(_amountController.text),
        'type': _transactionType,
        'date': Timestamp.now(),
      });

      Navigator.pop(context); // Go back to the home screen after submitting
    } catch (e) {
      print('Error adding transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Transaction',style: TextStyle(
        fontSize: 20,fontWeight: FontWeight.bold,color: Colors.green
      ),)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: _transactionType,
              onChanged: (value) {
                setState(() {
                  _transactionType = value!;
                });
              },
              items: ['income', 'expense'].map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: _submitTransaction,
              child: Text('Submit',style: TextStyle(color: Colors.white),),

            ),
          ],
        ),
      ),
    );
  }
}