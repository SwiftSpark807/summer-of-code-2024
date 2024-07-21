import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'models/transactionmodel.dart';

class TransactionsPage extends StatefulWidget {
  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String? userName;
  String? userRole;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'];
          userRole = userDoc['access'];
        });
      }
    }
  }

  Future<void> _downloadAndOpenPDF(String url, String fileName) async {
  try {
    Dio dio = Dio();

    // Get the downloads directory
    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = await getExternalStorageDirectory();
      // On Android, getExternalStorageDirectory() returns /storage/emulated/0/Android/data/com.example.yourapp/files
      // We need to go one level up to get to /storage/emulated/0/Download
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      downloadsDir = await getDownloadsDirectory();
    }

    if (downloadsDir != null) {
      String filePath = '${downloadsDir.path}/$fileName';

      await dio.download(url, filePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded to $filePath')),
      );

      await OpenFile.open(filePath);
    } else {
      throw Exception('Could not find the downloads directory');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error downloading file: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(16, 44, 87, 1),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 10, 28, 55),
        title: Text(
          'Transactions',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: userRole == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Transactions')
                  .snapshots(),
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

                if (userRole == 'cashier') {
                  transactions = transactions
                      .where(
                          (transaction) => transaction.cashierName == userName)
                      .toList();
                }

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    MyTransaction transaction = transactions[index];

                    return Container(
                      margin: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 21, 59, 116),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer ID: ${transaction.customerId}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Total Price: Rs ${transaction.totalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Timestamp: ${transaction.timestamp.toString()}',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Cashier: ${transaction.cashierName}',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Products:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              width: 150,
                              height: 167.0,
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
                                      color: Colors.white,
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255)),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      product['imageUrl']),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            SizedBox(height: 8.0),
                                            Text('Name : ${product['name']}'),
                                            Text(
                                                'Price: ${product['price'].toString()} Rs.'),
                                          ],
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                product['count'].toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 16.0),
                            if (transaction.pdfUrl != null)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(218, 192, 163, 1),
                                ),
                                onPressed: () {
                                  if (transaction.pdfUrl != null) {
                                    String fileName =
                                        'invoice_${transaction.timestamp.toIso8601String()}.pdf';
                                    _downloadAndOpenPDF(
                                        transaction.pdfUrl!, fileName);
                                  }
                                },
                                child: Text(
                                  'Download PDF Invoice',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
