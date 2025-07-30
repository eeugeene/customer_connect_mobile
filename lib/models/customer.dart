class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String preferredContactMethod;
  final String contactHistory;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.preferredContactMethod,
    required this.contactHistory,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      preferredContactMethod: json['preferred_contact_method'],
      contactHistory: json['contact_history'],
    );
  }
}
