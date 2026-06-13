class CompanyContact {
  // Brand Info
  static const String name = "MV Manufacturing LLC";
  static const String legalName = "MV Precision Manufacturing, LLC";
  static const String tagline = "CNC & Precision Manufacturing";
  
  // Contact Channels
  static const String phone = "(669) 243-9228";
  static const String email = "minhvu@mvmanufacturing.com";
  
  // Physical Address
  static const String street = "545 Aldo Ave";
  static const String suite = "ste 10";
  static const String city = "Santa Clara";
  static const String state = "CA";
  static const String zip = "95054";
  
  static String get fullAddress => "$street, $suite, $city, $state $zip";

  // Business Hours
  static const Map<String, String> operatingHours = {
    "Monday - Friday": "8:00 AM - 5:00 PM",
    "Saturday": "9:00 AM - 1:00 PM",
    "Sunday": "Closed",
  };

  // Web Links (For Google Maps, Social Media, etc)
  static const String googleMapsUrl = "https://www.google.com/maps/place/545+Aldo+Ave,+Santa+Clara,+CA+95054/@37.3856611,-121.9459252,17z/data=!3m1!4b1!4m6!3m5!1s0x808fc978b87b1033:0x2193400152ddda1e!8m2!3d37.3856611!4d-121.9459252!16s%2Fg%2F11b8v4q1nl?entry=ttu&g_ep=EgoyMDI2MDYxMC4wIKXMDSoASAFQAw%3D%3D";
}