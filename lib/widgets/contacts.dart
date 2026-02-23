class CompanyContact {
  // Brand Info
  static const String name = "MV Machine Shop";
  static const String legalName = "MV Precision Manufacturing, LLC";
  static const String tagline = "CNC & Precision Manufacturing";
  
  // Contact Channels
  static const String phone = "(555) 123-4567";
  static const String email = "info@mvmachineshop.com";
  static const String quoteEmail = "quotes@mvmachineshop.com";
  
  // Physical Address
  static const String street = "123 Industrial Way";
  static const String suite = "Suite 400";
  static const String city = "Los Angeles";
  static const String state = "CA";
  static const String zip = "90210";
  
  static String get fullAddress => "$street, $suite, $city, $state $zip";

  // Business Hours
  static const Map<String, String> operatingHours = {
    "Monday - Friday": "8:00 AM - 5:00 PM",
    "Saturday": "9:00 AM - 1:00 PM",
    "Sunday": "Closed",
  };

  // Web Links (For Google Maps, Social Media, etc)
  static const String googleMapsUrl = "https://maps.google.com/?q=123+Industrial+Way+Los+Angeles";
  static const String linkedinUrl = "https://linkedin.com/company/mvmachineshop";
}