import 'package:cloud_firestore/cloud_firestore.dart';

class MyProduct {
  final String? name;
  final String? barcode;
  final String? brand;
  final String? quantity;
  final String? price;
  final String? imageUrl;

  MyProduct({
    this.name,
    this.barcode,
    this.brand,
    this.quantity,
    this.price,
    this.imageUrl,
  });

  factory MyProduct.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return MyProduct(
      name: data?['name'],
      barcode: data?['barcode'],
      brand: data?['brand'],
      quantity: data?['quantity'],
      price: data?['price'],
      imageUrl: data?['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (barcode != null) "barcode": barcode,
      if (brand != null) "brand": brand,
      if (quantity != null) "quantity": quantity,
      if (price != null) "price": price,
      if (imageUrl != null) "imageUrl": imageUrl,
    };
  }
}
