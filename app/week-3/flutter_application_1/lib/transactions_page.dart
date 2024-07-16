import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/transactionmodel.dart';

class TransactionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('Transactions').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No transactions found.'));
          }

          List<MyTransaction> transactions = snapshot.data!.docs
              .map((doc) => MyTransaction.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              MyTransaction transaction = transactions[index];

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer ID: ${transaction.customerId}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                        'Total Price: \$${transaction.totalPrice.toStringAsFixed(2)}'),
                    SizedBox(height: 8.0),
                    Text('Timestamp: ${transaction.timestamp.toString()}'),
                    SizedBox(height: 16.0),
                    Text(
                      'Products:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Container(
                      height: 120.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: transaction.products.length,
                        itemBuilder: (context, idx) {
                          Map<String, dynamic> product =
                              transaction.products[idx];
                          return Container(
                            margin: EdgeInsets.only(right: 8.0),
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name: ${product['name']}'),
                                SizedBox(height: 4.0),
                                Text('Quantity: ${product['count']}'),
                                SizedBox(height: 4.0),
                                // Add image display here if needed
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
