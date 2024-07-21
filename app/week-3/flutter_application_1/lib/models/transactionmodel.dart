import 'package:cloud_firestore/cloud_firestore.dart';

class MyTransaction {
  final String transactionId;
  final String customerId;
  final String userId; // Add userId
  final List<Map<String, dynamic>> products;
  final double totalPrice;
  final DateTime timestamp;
  final String cashierName;
  final String? pdfUrl; // Add pdfUrl to store the PDF link

  MyTransaction({
    required this.transactionId,
    required this.customerId,
    required this.userId, // Add userId to constructor
    required this.products,
    required this.totalPrice,
    required this.timestamp,
    required this.cashierName,
    this.pdfUrl,
  });

  factory MyTransaction.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    // Handle potential null values gracefully
    String userId = data['userId'] ?? ''; // Provide a default value if null
    DateTime transactionTime = data['timestamp'] != null
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime.now(); // Use current time if timestamp is null
    String cashierName = data['cashierName'] ?? '';
    String? pdfUrl = data['pdfUrl']; // Optional field

    return MyTransaction(
      transactionId: doc.id,
      customerId: data['customerId'] ?? '',
      userId: userId,
      products: List<Map<String, dynamic>>.from(data['products'] ?? []),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      timestamp: transactionTime,
      cashierName: cashierName,
      pdfUrl: pdfUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'userId': userId,
      'products': products,
      'totalPrice': totalPrice,
      'timestamp':
          Timestamp.fromDate(timestamp), // Convert DateTime to Timestamp
      'cashierName': cashierName,
      'pdfUrl': pdfUrl, // Add pdfUrl to the map
    };
  }
}
