class Customer {
  final String name;
  final String phoneNumber;
  final String email;
  Customer(
      {required this.name, required this.phoneNumber, required this.email});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
}
