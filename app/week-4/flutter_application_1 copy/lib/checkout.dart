import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
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
  final TextEditingController _emailController = TextEditingController();
  late Map<String, int> _productCounts;
  late Razorpay _razorpay;
  double _totalSum = 0.0;

  @override
  void initState() {
    super.initState();
    _productCounts = Map.from(widget.productCounts);
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _calculateTotalSum();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _calculateTotalSum() {
    _totalSum = widget.scannedProducts.fold<double>(0.0, (sum, product) {
      final barcode = product['barcode'];
      final count = _productCounts[barcode] ?? 0;
      final price = double.tryParse(product['price'].toString()) ?? 0.0;
      return sum + (count * price);
    });
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

  Future<void> _confirmOrder(String paymentId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    String name = _nameController.text;
    String phoneNumber = _phoneNumberController.text;
    String email = _emailController.text;
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

    Customer customer =
        Customer(name: name, phoneNumber: phoneNumber, email: email);
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

      // Update product quantity in Firestore
      final productRef =
          FirebaseFirestore.instance.collection('Products').doc(barcode);
      await productRef.update({
        'quantity':
            FieldValue.increment(-count), // Reduce quantity by the count
      });
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final pdfFilePath = '${appDocDir.path}/invoice.pdf';

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
      'customerEmail': email,
      'paymentId': paymentId,
    });

    await transactionRef.update({'transactionId': transactionRef.id});

    final Email emailToSend = Email(
      body: 'Please find attached the invoice for your recent purchase.',
      subject: 'Your Invoice',
      recipients: [email],
      attachmentPaths: [pdfFilePath],
      isHTML: false,
    );

    await FlutterEmailSender.send(emailToSend);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Order confirmed successfully, PDF generated and email sent')),
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
    _calculateTotalSum();
  }

  void _startPayment() {
    var options = {
      'key': 'rzp_test_hMxxJrD6hgRANO',
      'amount':
          (_totalSum * 100).toInt(), // Razorpay requires the amount in paise
      'name': 'Your Company Name',
      'description': 'Payment for order',
      'prefill': {
        'contact': _phoneNumberController.text,
        'email': _emailController.text
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _confirmOrder(response.paymentId.toString());
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Payment successful')));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet selected')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Customer Name'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            Text(
              'Products:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.scannedProducts.length,
                itemBuilder: (context, index) {
                  final product = widget.scannedProducts[index];
                  final barcode = product['barcode'];
                  final count = _productCounts[barcode] ?? 0;
                  return ListTile(
                    leading: Image.network(product['imageUrl']),
                    title: Text(product['name']),
                    subtitle: Text('Brand: ${product['brand']}'),
                    trailing: Column(
                      children: [
                        Text('Price: \$${product['price']}'),
                        Text('Quantity: $count'),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Total: \$${_totalSum.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startPayment,
              child: Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
