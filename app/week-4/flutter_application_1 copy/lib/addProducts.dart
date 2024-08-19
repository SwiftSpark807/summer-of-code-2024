import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/drawer.dart';
import 'package:flutter_application_1/components/toast.dart';
import 'package:flutter_application_1/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'models/productmodel.dart';
import 'components/textLabel.dart';
import 'components/textfield.dart';
import 'login.dart';

class AddProduct extends StatefulWidget {
  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  String _scanResult = "";
  File? _imageFile;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isAddingProduct = false;

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
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );

      if (barcodeScanRes != '-1') {
        setState(() {
          _scanResult = barcodeScanRes;
        });
      } else {
        setState(() {
          _scanResult = 'Scan Cancelled';
        });
      }

      print("Barcode scan result: $_scanResult");
    } on Exception catch (e) {
      print("Exception in scanBarcode: $e");
      setState(() {
        _scanResult = 'Failed to get platform version.';
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImage(File imageFile, String productId) async {
    try {
      final storageReference =
          FirebaseStorage.instance.ref().child('product_images/$productId.jpg');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() => null);
      String downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> addNewProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isAddingProduct = true;
      });

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await uploadImage(_imageFile!, _scanResult);
      }

      final newProduct = MyProduct(
        barcode: _scanResult,
        name: nameController.text,
        brand: brandController.text,
        quantity: quantityController.text,
        price: priceController.text,
        imageUrl: imageUrl,
      );

      try {
        final docRef = FirebaseFirestore.instance
            .collection("Products")
            .doc(_scanResult)
            .withConverter(
              fromFirestore: MyProduct.fromFirestore,
              toFirestore: (MyProduct newProduct, options) =>
                  newProduct.toFirestore(),
            );

        await docRef.set(newProduct);
        showToast(message: "Added the product");
        Navigator.pop(context);
      } catch (e) {
        print("Error adding product: $e");
        showToast(message: "Failed to add the product");
      } finally {
        setState(() {
          _isAddingProduct = false;
        });
      }
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
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromRGBO(16, 44, 87, 1),
        title: Text('Add Product', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Scan a Barcode for thr Product:",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      IconButton(
                        onPressed: () => scanBarcode(context),
                        icon: Icon(
                          Icons.qr_code_2,
                          color: const Color.fromRGBO(218, 192, 163, 1),
                          size: 30,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    _scanResult,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  MyLabel(check: "Product Name"),
                  SizedBox(height: 12),
                  MyTextfield(
                    controller: nameController,
                    hintText: "Enter Product Name",
                    obscureText: false,
                  ),
                  SizedBox(height: 20),
                  MyLabel(check: "Product Brand"),
                  SizedBox(height: 12),
                  MyTextfield(
                    controller: brandController,
                    hintText: "Enter Product Brand",
                    obscureText: false,
                  ),
                  SizedBox(height: 20),
                  MyLabel(check: "Quantity"),
                  SizedBox(height: 12),
                  MyTextfield(
                    controller: quantityController,
                    hintText: "Enter Quantity",
                    obscureText: false,
                  ),
                  SizedBox(height: 20),
                  MyLabel(check: "Price"),
                  SizedBox(height: 12),
                  MyTextfield(
                    controller: priceController,
                    hintText: "Enter Price",
                    obscureText: false,
                  ),
                  SizedBox(height: 30),
                  _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        )
                      : Text(
                          'No Image Selected',
                          style: TextStyle(color: Colors.white),
                        ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(218, 192, 163, 1),
                      ),
                      onPressed: () {
                        pickImage();
                      },
                      child: Text(
                        "Pick Image",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w900,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(218, 192, 163, 1),
                      ),
                      onPressed: () {
                        addNewProduct();
                      },
                      child: Text(
                        "Add Product",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w900,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isAddingProduct)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
