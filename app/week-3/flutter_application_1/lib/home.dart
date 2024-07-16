import 'package:flutter/material.dart';
import 'package:flutter_application_1/ProductList.dart';
import 'package:flutter_application_1/addProducts.dart';
import 'package:flutter_application_1/cashierPortal.dart';
import 'package:flutter_application_1/components/drawer.dart';
import 'package:flutter_application_1/profile.dart';
import 'package:flutter_application_1/transactions_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _scanResult = "Unknown";
  Map<String, dynamic>? _productInfo;

  Future<void> _logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SecondPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> scanBarcode(BuildContext context) async {
    print("scanBarcode function triggered");
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print("Barcode scan result: $barcodeScanRes");
      if (!mounted) return;

      setState(() {
        _scanResult =
            barcodeScanRes != '-1' ? barcodeScanRes : 'Scan Cancelled';
      });

      if (barcodeScanRes != '-1') {
        var product = await fetchProductInfo(barcodeScanRes);
        setState(() {
          _productInfo = product;
        });
      }
    } on Exception catch (e) {
      print("Exception in scanBarcode: $e");
      barcodeScanRes = 'Failed to get platform version.';
    }
  }

  Future<Map<String, dynamic>?> fetchProductInfo(String barcode) async {
    var url = Uri.parse(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json');

    print('Fetching product info for barcode: $barcode');
    print('API URL: $url');

    try {
      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        print('Decoded response: $decodedResponse');

        if (decodedResponse.containsKey('product')) {
          var product = decodedResponse['product'];
          return product;
        } else {
          print('Product not found');
          return null;
        }
      } else {
        print('Failed to load product data');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        endDrawer: Container(
          width: 250,
          child: MyDrawer(
            goToProfile: () => goToProfilePage(),
            signOut: () => _logout(context),
          ),
        ),
        backgroundColor: const Color.fromRGBO(16, 44, 87, 1),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(82.0),
          child: AppBar(
            actions: [
              Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.only(right: 20, top: 15),
                  child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      size: 40,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                ),
              ),
            ],
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            flexibleSpace: Container(
                padding: const EdgeInsets.fromLTRB(41, 0, 0, 0),
                child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text('Welcome',
                        style: TextStyle(
                            fontFamily: "JockeyOne",
                            color: Colors.white,
                            fontSize: 30)))),
            backgroundColor: const Color.fromRGBO(16, 44, 87, 1),
            centerTitle: false,
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  SizedBox(height: 30),
                  SizedBox(height: 30),
                  if (_productInfo != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromARGB(255, 44, 70, 110),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                'Product name: ${_productInfo!['product_name'] ?? 'N/A'}',
                                style: TextStyle(
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 20)),
                            SizedBox(height: 10),
                            Text('Brand: ${_productInfo!['brands'] ?? 'N/A'}',
                                style: TextStyle(
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 16)),
                            SizedBox(height: 10),
                            Text(
                                'Quantity: ${_productInfo!['quantity'] ?? 'N/A'}',
                                style: TextStyle(
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w600,
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 16)),
                            SizedBox(height: 10),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(218, 192, 163, 1),
                                ),
                                onPressed: () => {},
                                child: Text("Add to List",
                                    style: TextStyle(
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.w600,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        fontSize: 20))),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddProduct()));
                        },
                        child: Text("Add Product")),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Productlist()));
                        },
                        child: Text("See Inventory")),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CashierPortal()));
                        },
                        child: Text("Cashier Portal ")),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TransactionsPage()));
                        },
                        child: Text("Transactions")),
                  ),
                ]))));
  }
}
