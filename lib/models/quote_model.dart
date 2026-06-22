class QuoteModel {
  final String fullName;
  final String email;
  final String phone;
  final String company;
  final String details;
  final List<Map<String, dynamic>> files;

  QuoteModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.company,
    required this.details,
    this.files = const [],
  });

  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'company': company,
    'details': details,
    'files': files,
  };
}