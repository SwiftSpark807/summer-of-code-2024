import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'components/product.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  ProfilePage({required this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Product> _storedProducts = [];
  @override
  void initState() {
    super.initState();
    _loadStoredProducts();
  }

  Future<void> _loadStoredProducts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? productList = prefs.getStringList('productList');

    if (productList != null) {
      setState(() {
        _storedProducts = productList
            .map((item) => Product.fromJson(jsonDecode(item)))
            .toList();
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SecondPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(82.0), // Set the height here
        child: AppBar(
          // Remove the leading property
          actions: [
            Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.only(right: 20, top: 15),
                child: IconButton(
                  icon: Icon(
                    Icons.menu,
                    size: 40, // Set the desired size here
                  ),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ),
            ),
          ],
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          backgroundColor: const Color.fromRGBO(16, 44, 87, 1),
          flexibleSpace: Container(
              padding: const EdgeInsets.fromLTRB(41, 0, 0, 0),
              child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text('POS  ',
                      style: TextStyle(
                          fontFamily: "JockeyOne",
                          color: Colors.white,
                          fontSize: 30)))),
          centerTitle: false,
        ),
      ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            Icon(
              Icons.account_circle_rounded,
              color: Colors.white,
              size: 300,
            ),
            SizedBox(
                child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Container(
                    width: 500,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromARGB(255, 44, 70, 110),
                    ),
                    child: Column(children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text('Full Name: ${widget.userData['fullName']}',
                          style: TextStyle(
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 30)),
                      Text('Email: ${widget.userData['email']}',
                          style: TextStyle(
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 30)),
                      Text('Phone Number: ${widget.userData['phone']}',
                          style: TextStyle(
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 30)),
                      SizedBox(height: 20),
                    ])),
              ),
            )),
            SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text('-----------------Last Scan-----------------',
                  style: TextStyle(
                      fontFamily: "JockeyOne",
                      color: Colors.white,
                      fontSize: 30)),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              width: 500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromARGB(255, 44, 70, 110),
              ),
              child: ListView.builder(
                  itemCount: _storedProducts.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    var product = _storedProducts[index];
                    return ListTile(
                      title: Text(
                        product.productName,
                        style: TextStyle(
                            fontFamily: "Inter",
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                      subtitle: Text(product.brand,
                          style: TextStyle(
                              fontFamily: "Inter",
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 15)),
                    );
                  }),
              height: 200,
            )
          ],
        ),
      ),
    );
  }
}
