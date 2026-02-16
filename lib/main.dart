import 'package:flutter/material.dart';
import 'package:mv/screens/aboutPage.dart';
import 'package:mv/screens/capabilitiesPage.dart';
import 'package:mv/screens/galleryPage.dart';
import 'package:mv/screens/homePage.dart';
import 'package:mv/screens/servicesPage.dart';

void main() async {
  runApp(const MVWebsite());
}

class MVWebsite extends StatelessWidget {
  const MVWebsite({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MV Machine Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/services': (context) => const ServicesPage(),
        '/capabilities': (context) => const CapabilitiesPage(),
        '/about': (context) => const AboutPage(),
        '/gallery': (context) => const GalleryPage(),
      },
    );
  }
}