import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addTransactionScreen.dart';
import 'dashboard.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Finance Tracker',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.green),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search by income or expense..",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              cursorColor: Colors.black,
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: firestore.collection('transactions').orderBy('date', descending: true).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No transactions available.'));
                }

                final data = snapshot.data!.docs;

                // Apply filtering based on searchQuery
                final filteredData = data.where((transaction) {
                  final description = transaction['description'].toString().toLowerCase();
                  final type = transaction['type'].toString().toLowerCase();
                  return description.contains(searchQuery) || type.contains(searchQuery);
                }).toList();

                double totalIncome = 0;
                double totalExpense = 0;

                for (var transaction in data) {
                  if (transaction['type'] == 'income') {
                    totalIncome += transaction['amount'];
                  } else {
                    totalExpense += transaction['amount'];
                  }
                }

                double savings = totalIncome - totalExpense;

                return Column(
                  children: [
                    ListTile(
                      title: Text('Total Income'),
                      subtitle: Text('\$${totalIncome.toStringAsFixed(2)}'),
                    ),
                    ListTile(
                      title: Text('Total Expenses'),
                      subtitle: Text('\$${totalExpense.toStringAsFixed(2)}'),
                    ),
                    ListTile(
                      title: Text('Savings'),
                      subtitle: Text('\$${savings.toStringAsFixed(2)}'),
                    ),
                    Expanded(
                      child: filteredData.isEmpty
                          ? Center(child: Text('No matching transactions found.'))
                          : ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          var transaction = filteredData[index];

                          return Dismissible(
                            key: Key(transaction.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Text("Confirm Deletion"),
                                  content: Text("Are you sure you want to delete this transaction?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        firestore.collection('transactions').doc(transaction.id).delete();
                                        Navigator.of(context).pop(true);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Transaction deleted')),
                                        );
                                      },
                                      child: Text("Delete", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.white,

                              shape: RoundedRectangleBorder(

                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.green),
                              ),
                              child: ListTile(
                                title: Text(transaction['description']),
                                subtitle: Text('\$${transaction['amount'].toStringAsFixed(2)}'),
                                trailing: Text(transaction['type']),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionScreen()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
