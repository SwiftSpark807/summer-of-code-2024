import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'checkout.dart';
import 'addProducts.dart'; // Import your AddProduct page here

class CashierPortal extends StatefulWidget {
  @override
  _CashierPortalState createState() => _CashierPortalState();
}

class _CashierPortalState extends State<CashierPortal> {
  List<Map<String, dynamic>> scannedProducts = [];
  Map<String, int> productCounts = {};

  Future<void> scanBarcode() async {
    try {
      String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );

      if (barcode != '-1') {
        DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
            .collection('Products')
            .doc(barcode)
            .get();

        if (productSnapshot.exists) {
          Map<String, dynamic>? productData =
              productSnapshot.data() as Map<String, dynamic>?;

          if (productData != null) {
            int quantity = productData['quantity'];
            if (quantity <= 0) {
              showToast(message: "Product is unavailable.");
            } else {
              setState(() {
                if (productCounts.containsKey(barcode)) {
                  productCounts[barcode] = productCounts[barcode]! + 1;
                } else {
                  scannedProducts.add(productData);
                  productCounts[barcode] = 1;
                }
              });
            }
          } else {
            showToast(message: "Product data not found.");
          }
        } else {
          // Product not found, prompt user to add the product
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Product Not Found'),
              content: Text('Would you like to add this product?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Add Product'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddProduct()),
                    );
                  },
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      showToast(message: "Failed to get platform version.");
    }
  }

  Future<ImageProvider> _loadImage(String imageUrl) async {
    return NetworkImage(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(16, 44, 87, 1),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 10, 28, 55),
        title: Text('Cashier Portal'),
        actions: [
          if (scannedProducts.isEmpty)
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: TextButton.icon(
                onPressed: scanBarcode,
                icon: Icon(
                  Icons.camera_alt,
                  color: Colors.black,
                ),
                label: Text(
                  'Scan Products',
                  style: TextStyle(color: Colors.black),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(218, 192, 163, 1),
                ),
              ),
            ),
          if (scannedProducts.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.camera_alt,
                color: const Color.fromRGBO(218, 192, 163, 1),
              ),
              onPressed: scanBarcode,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: scannedProducts.isEmpty
                ? Center(
                    child: Text(
                      'Scan products to see info',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: scannedProducts.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> product = scannedProducts[index];
                      String barcode = product['barcode'];
                      String? imageUrl = product['imageUrl'];

                      return Container(
                        height: 120,
                        margin: const EdgeInsets.all(18.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromARGB(255, 21, 59, 116),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
                                      "Quantity: ${product['quantity']}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      "Price: ${product['price']}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      "Count: ${productCounts[barcode]}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
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
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                      );
                    },
                  ),
          ),
          if (scannedProducts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(218, 192, 163, 1),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          scannedProducts: scannedProducts,
                          productCounts: productCounts,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Proceed to Checkout",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void showToast({required String message}) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
