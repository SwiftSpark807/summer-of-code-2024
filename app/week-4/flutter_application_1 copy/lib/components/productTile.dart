import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> productData;

  ProductDetailPage({required this.productData});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  File? _imageFile;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productData['name']);
    _brandController = TextEditingController(text: widget.productData['brand']);
    _quantityController =
        TextEditingController(text: widget.productData['quantity']);
    _priceController = TextEditingController(text: widget.productData['price']);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile, String productId) async {
    try {
      Reference storageReference =
          FirebaseStorage.instance.ref().child('product_images/$productId.jpg');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() => null);
      String downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isUpdating = true;
    });

    String productId = widget.productData['barcode'];

    String? imageUrl;
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!, productId);
    } else {
      imageUrl = widget.productData['imageUrl'];
    }

    await FirebaseFirestore.instance
        .collection('Products')
        .doc(productId)
        .update({
      'name': _nameController.text,
      'brand': _brandController.text,
      'quantity': _quantityController.text,
      'price': _priceController.text,
      'imageUrl': imageUrl,
    });

    setState(() {
      _isUpdating = false;
    });

    Navigator.pop(context);
  }

  Future<void> _deleteProduct() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this product?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () async {
                String productId = widget.productData['barcode'];
                await FirebaseFirestore.instance
                    .collection('Products')
                    .doc(productId)
                    .delete();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                showToast(message: "Product Deleted Successfully");
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isUpdating ? null : _saveChanges,
          )
        ],
      ),
      body: AbsorbPointer(
        absorbing: _isUpdating,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  if (_imageFile != null)
                    Image.file(_imageFile!)
                  else if (widget.productData['imageUrl'] != null)
                    Image.network(widget.productData['imageUrl']),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isUpdating ? null : _pickImage,
                    child: Text('Change Image'),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    enabled: !_isUpdating,
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _brandController,
                    decoration: InputDecoration(labelText: 'Brand'),
                    enabled: !_isUpdating,
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _quantityController,
                    decoration: InputDecoration(labelText: 'Quantity'),
                    enabled: !_isUpdating,
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    enabled: !_isUpdating,
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: _deleteProduct,
                      child: Text(
                        "Delete Product",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isUpdating)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
