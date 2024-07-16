class Customer {
  final String name;
  final String phoneNumber;

  Customer({required this.name, required this.phoneNumber});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }
}
