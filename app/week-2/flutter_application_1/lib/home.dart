import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'components/product.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  HomePage({required this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _scanResult = "Unknown";
  Map<String, dynamic>? _productInfo;
  List<Product> _addedProducts = [];

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

  void addToCart() async {
    if (_productInfo != null) {
      var productName = _productInfo!['product_name'] ?? 'N/A';
      var brand = _productInfo!['brands'] ?? 'N/A';
      var quantity = _productInfo!['quantity'] ?? 'N/A';

      var newProduct = Product(
        barcode: _scanResult,
        productName: productName,
        brand: brand,
        quantity: quantity,
      );

      setState(() {
        _addedProducts.add(newProduct);
      });
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> productList =
        _addedProducts.map((product) => jsonEncode(product.toJson())).toList();
    prefs.setStringList('productList', productList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        endDrawer: Container(
            width: 250,
            child: Drawer(
                elevation: 16,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(16, 44, 87, 1),
                      ),
                      child: Text('Drawer Header'),
                    ),
                    ListTile(
                      leading: Icon(Icons.account_circle),
                      title: const Text('Profile'),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage(
                                      userData: widget.userData,
                                    )));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout_rounded),
                      title: const Text('Logout'),
                      onTap: () {
                        _logout(context);
                      },
                    ),
                  ],
                ))),
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
                    child: Text('Welcome, ${widget.userData['fullName']}',
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
                  if (_productInfo == null) SizedBox(height: 40),
                  if (_productInfo == null)
                    Text("Scan a product to see its details here",
                        style: TextStyle(
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontSize: 16)),
                  SizedBox(height: 40),
                  Container(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: _addedProducts.length,
                        itemBuilder: (context, index) {
                          var product = _addedProducts[index];
                          return Container(
                            width: 200,
                            child: ListTile(
                              title: Text(
                                product.productName,
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                product.brand,
                                style: TextStyle(color: Colors.white),
                              ),
                              leading: Icon(
                                Icons.local_grocery_store_rounded,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromARGB(255, 44, 70, 110),
                    ),
                    height: 200,
                    width: 500,
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: 400,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(218, 192, 163, 1),
                        ),
                        onPressed: () => scanBarcode(context),
                        child: Text("Scan Barcode",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w600,
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontSize: 20))),
                  ),
                  SizedBox(height: 30),
                  Text("Scan Result: $_scanResult",
                      style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 20)),
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
                                    color: Colors.white,
                                    fontSize: 16)),
                            SizedBox(height: 10),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(218, 192, 163, 1),
                                ),
                                onPressed: () => {addToCart()},
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
                ]))));
  }
}
