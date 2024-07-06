class Product {
  final String barcode;
  final String productName;
  final String brand;
  final String quantity;

  Product({
    required this.barcode,
    required this.productName,
    required this.brand,
    required this.quantity,
  });
  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'productName': productName,
      'brand': brand,
      'quantity': quantity,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      barcode: json['barcode'],
      productName: json['productName'],
      brand: json['brand'],
      quantity: json['quantity'],
    );
  }
}
