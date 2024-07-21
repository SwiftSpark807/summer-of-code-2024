import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'home.dart';
import 'models/customermodel.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> scannedProducts;
  final Map<String, int> productCounts;

  CheckoutPage({required this.scannedProducts, required this.productCounts});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  late Map<String, int> _productCounts;

  @override
  void initState() {
    super.initState();
    _productCounts = Map.from(widget.productCounts);
  }

  Future<void> _generatePdfInvoice(String pdfFilePath) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Invoice',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Customer Name: ${_nameController.text}'),
              pw.Text('Phone Number: ${_phoneNumberController.text}'),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Name',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Brand',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Price',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Quantity',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  ...widget.scannedProducts.map((product) {
                    final barcode = product['barcode'];
                    final count = _productCounts[barcode]!;
                    final price =
                        double.tryParse(product['price'].toString()) ?? 0.0;
                    final total = count * price;
                    return pw.TableRow(
                      children: [
                        pw.Text(product['name']),
                        pw.Text(product['brand']),
                        pw.Text('\$${price.toStringAsFixed(2)}'),
                        pw.Text(count.toString()),
                        pw.Text('\$${total.toStringAsFixed(2)}'),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                  'Total Sum: \$${widget.scannedProducts.fold<double>(0.0, (sum, product) {
                final barcode = product['barcode'];
                final count = _productCounts[barcode]!;
                final price =
                    double.tryParse(product['price'].toString()) ?? 0.0;
                return sum + (count * price);
              }).toStringAsFixed(2)}'),
            ],
          );
        },
      ),
    );

    final file = File(pdfFilePath);
    await file.writeAsBytes(await pdf.save());
  }

  Future<String> _uploadPdf(String pdfFilePath) async {
    final storageRef = FirebaseStorage.instance.ref();
    final pdfRef = storageRef
        .child('invoices/${DateTime.now().millisecondsSinceEpoch}.pdf');

    await pdfRef.putFile(File(pdfFilePath));
    final pdfUrl = await pdfRef.getDownloadURL();

    return pdfUrl;
  }

  Future<void> _confirmOrder() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    String name = _nameController.text;
    String phoneNumber = _phoneNumberController.text;
    final cashierRef = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.email)
        .get();
    final cashier = cashierRef.data();
    String cashierName = cashier!['name'];

    if (name.isEmpty || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both name and phone number')),
      );
      return;
    }

    Customer customer = Customer(name: name, phoneNumber: phoneNumber);
    DocumentReference customerRef =
        FirebaseFirestore.instance.collection('Customers').doc(phoneNumber);
    await customerRef.set(customer.toMap());

    double totalSum = 0.0;
    List<Map<String, dynamic>> transactionProducts = [];

    for (var product in widget.scannedProducts) {
      String barcode = product['barcode'];
      int count = _productCounts[barcode]!;
      double price = double.tryParse(product['price'].toString()) ?? 0.0;
      totalSum += count * price;

      transactionProducts.add({
        'barcode': barcode,
        'name': product['name'],
        'brand': product['brand'],
        'price': price,
        'count': count,
        'imageUrl': product['imageUrl'],
      });
    }

    final pdfFilePath =
        (await getApplicationDocumentsDirectory()).path + '/invoice.pdf';
    await _generatePdfInvoice(pdfFilePath);
    final pdfUrl = await _uploadPdf(pdfFilePath);

    DocumentReference transactionRef =
        await FirebaseFirestore.instance.collection('Transactions').add({
      'customerId': phoneNumber,
      'userId': currentUser.email!,
      'products': transactionProducts,
      'totalPrice': totalSum,
      'timestamp': DateTime.now(),
      'cashierName': cashierName,
      'pdfUrl': pdfUrl,
    });

    await transactionRef.update({'transactionId': transactionRef.id});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order confirmed successfully and PDF generated')),
    );

    _nameController.clear();
    _phoneNumberController.clear();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  void _updateProductCount(String barcode, int change) {
    setState(() {
      _productCounts[barcode] = (_productCounts[barcode] ?? 0) + change;
      if (_productCounts[barcode]! <= 0) {
        _productCounts.remove(barcode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalSum = widget.scannedProducts.fold<double>(0.0, (sum, product) {
      final barcode = product['barcode'];
      final count = _productCounts[barcode] ?? 0;
      final price = double.tryParse(product['price'].toString()) ?? 0.0;
      return sum + (count * price);
    });

    return Scaffold(
      backgroundColor: Color.fromRGBO(16, 44, 87, 1),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 10, 28, 55),
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
                int count = _productCounts[barcode] ?? 0;
                double price =
                    double.tryParse(product['price'].toString()) ?? 0.0;
                String? imageUrl = product['imageUrl'];

                return Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.fromLTRB(18.0, 8, 12, 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255, 21, 59, 116),
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
                            "Price: ${product['price']} Rs.",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Total: ${(count * price).toStringAsFixed(2)} Rs.",
                            style: TextStyle(color: Colors.white),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove, color: Colors.white),
                                onPressed: () {
                                  if (count > 0) {
                                    _updateProductCount(barcode, -1);
                                  }
                                },
                              ),
                              Text(
                                '$count',
                                style: TextStyle(color: Colors.white),
                              ),
                              IconButton(
                                icon: Icon(Icons.add, color: Colors.white),
                                onPressed: () {
                                  _updateProductCount(barcode, 1);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (imageUrl != null)
                        Column(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
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
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total Sum: \$${totalSum.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Customer Name',
                enabledBorder: const OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 255, 255, 255), width: 0.0),
                ),
                border: const OutlineInputBorder(),
                labelStyle: new TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                enabledBorder: const OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 255, 255, 255), width: 0.0),
                ),
                border: const OutlineInputBorder(),
                labelStyle: new TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255)),
              ),
              keyboardType: TextInputType.phone,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(218, 192, 163, 1),
            ),
            onPressed: _confirmOrder,
            child: Text(
              'Confirm Order',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
