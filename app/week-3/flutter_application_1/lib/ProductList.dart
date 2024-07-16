import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'components/productTile.dart';
import 'addProducts.dart'; // Assuming this is the file where AddProduct is defined

class Productlist extends StatefulWidget {
  @override
  State<Productlist> createState() => _ProductlistState();
}

class _ProductlistState extends State<Productlist> {
  Future<ImageProvider> _loadImage(String imageUrl) async {
    return NetworkImage(imageUrl);
  }

  void navigateToAddProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProduct()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 43, 43, 43),
      appBar: AppBar(
        backgroundColor: Colors.black38,
        foregroundColor: Colors.white,
        title: Text('Products'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Products').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No products found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic>? data =
                  document.data() as Map<String, dynamic>?;

              if (data == null) {
                return ListTile(
                  title: Text('No data available'),
                );
              }

              String? imageUrl = data['imageUrl'];

              return Padding(
                padding: const EdgeInsets.all(18.0),
                child: GestureDetector(
                  onLongPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailPage(productData: data),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromARGB(255, 94, 94, 94),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Name: ${data['name']}" ??
                                      'No name available',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  "Brand: ${data['brand']}" ??
                                      'No brand available',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  "Quantity: ${data['quantity']}" ??
                                      'No quantity available',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  "Price: ${data['price']}" ??
                                      'No price available',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            if (imageUrl != null)
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
                              )
                            else
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToAddProduct(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
