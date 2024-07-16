import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';
import 'models/customermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> scannedProducts;
  final Map<String, int> productCounts;

  CheckoutPage({required this.scannedProducts, required this.productCounts});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Future<ImageProvider> _loadImage(String imageUrl) async {
    return NetworkImage(imageUrl);
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  void _incrementCount(String barcode) {
    setState(() {
      widget.productCounts[barcode] = widget.productCounts[barcode]! + 1;
    });
  }

  void _decrementCount(String barcode) {
    setState(() {
      if (widget.productCounts[barcode]! > 1) {
        widget.productCounts[barcode] = widget.productCounts[barcode]! - 1;
      }
    });
  }

  Future<void> _confirmOrder() async {
    String name = _nameController.text;
    String phoneNumber = _phoneNumberController.text;

    if (name.isEmpty || phoneNumber.isEmpty) {
      // Show an error or handle invalid input
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both name and phone number')),
      );
      return;
    }
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle case where user is not authenticated
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    // Save customer details with phone number as ID
    Customer customer = Customer(name: name, phoneNumber: phoneNumber);
    DocumentReference customerRef = FirebaseFirestore.instance
        .collection('Customers')
        .doc(phoneNumber); // Use phone number as document ID
    await customerRef.set(customer.toMap());

    // Save transaction details
    double totalSum = 0.0;
    List<Map<String, dynamic>> transactionProducts = [];

    for (var product in widget.scannedProducts) {
      String barcode = product['barcode'];
      int count = widget.productCounts[barcode]!;
      double price = double.tryParse(product['price'].toString()) ?? 0.0;
      totalSum += count * price;

      transactionProducts.add({
        'barcode': barcode,
        'name': product['name'],
        'brand': product['brand'],
        'price': product['price'],
        'count': count,
        'imageUrl': product['imageUrl'],
      });
    }

    // Add transaction to Firestore to generate a document ID
    DocumentReference transactionRef =
        await FirebaseFirestore.instance.collection('Transactions').add({
      'customerId': phoneNumber,
      'products': transactionProducts,
      'totalPrice': totalSum,
      'timestamp': DateTime.now(),
    });

    // Update the transaction with the generated document ID
    await transactionRef.update({'transactionId': transactionRef.id});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order confirmed successfully')),
    );

    _nameController.clear();
    _phoneNumberController.clear();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    double totalSum = 0.0;

    for (var product in widget.scannedProducts) {
      String barcode = product['barcode'];
      int count = widget.productCounts[barcode]!;
      double price = double.tryParse(product['price'].toString()) ?? 0.0;
      totalSum += count * price;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.scannedProducts.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> product = widget.scannedProducts[index];
                String barcode = product['barcode'];
                int count = widget.productCounts[barcode]!;
                double price =
                    double.tryParse(product['price'].toString()) ?? 0.0;
                String? imageUrl = product['imageUrl'];

                return Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255, 94, 94, 94),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Name: ${product['name']}",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Brand: ${product['brand']}",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Price: \$${product['price']}",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Total: \$${(count * price).toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      if (imageUrl != null)
                        Column(
                          children: [
                            FutureBuilder<ImageProvider>(
                              future: _loadImage(imageUrl),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.grey[200],
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.grey[200],
                                    ),
                                    child: Center(
                                      child: Text('Error'),
                                    ),
                                  );
                                } else {
                                  return Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        image: snapshot.data!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () => _decrementCount(barcode),
                                ),
                                Text(
                                  "$count",
                                  style: TextStyle(color: Colors.white),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () => _incrementCount(barcode),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                              child: Center(
                                child: Text(
                                  "No Image",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () => _decrementCount(barcode),
                                ),
                                Text(
                                  "$count",
                                  style: TextStyle(color: Colors.white),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () => _incrementCount(barcode),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Total Sum: \$${totalSum.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Customer Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Customer Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _confirmOrder,
                  child: Text('Confirm Order'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
