import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/responsive.dart';
import 'package:url_launcher/url_launcher.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: r.footerPaddingVertical, horizontal: 24),
      color: const Color(0xFF1a1a1a),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              r.isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildSection1(r)),
                        SizedBox(width: r.spacingXL),
                        Expanded(child: _buildSection2(context, r)),
                        SizedBox(width: r.spacingXL),
                        Expanded(child: _buildSection3(r)),
                      ],
                    )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection1(r),
                      SizedBox(height: r.spacingL),
                      const Divider(color: Color(0xFF333333)),
                      SizedBox(height: r.spacingL),
                      _buildSection2(context, r),
                      SizedBox(height: r.spacingL),
                      const Divider(color: Color(0xFF333333)),
                      SizedBox(height: r.spacingL),
                      _buildSection3(r),
                    ],
                  ),
              SizedBox(height: r.spacingXL),
              const Divider(color: Color(0xFF333333)),
              SizedBox(height: r.spacingM),
              Text(
                '© ${DateTime.now().year} ${CompanyContact.name}. All rights reserved.',
                style: TextStyle(color: const Color(0xFF999999), fontSize: r.caption),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection1(Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(CompanyContact.name, style: TextStyle(color: Colors.white, fontSize: r.body + 4, fontWeight: FontWeight.bold)),
        SizedBox(height: r.spacingXS),
        Padding(
          padding: const EdgeInsets.only(left: 12), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(CompanyContact.tagline, style: TextStyle(color: const Color(0xFF0066cc), fontSize: r.caption + 1, fontWeight: FontWeight.w500)),
              SizedBox(height: r.spacingM),
              Text('Precision CNC machining and manufacturing solutions for industries worldwide.', style: TextStyle(color: const Color(0xFF999999), fontSize: r.caption + 1, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection2(BuildContext context, Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Links', style: TextStyle(color: Colors.white, fontSize: r.body, fontWeight: FontWeight.bold)),
        SizedBox(height: r.spacingM),
        Padding(
          padding: const EdgeInsets.only(left: 12),  // indent content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLink(context, r, 'Services', '/services'),
              _buildLink(context, r, 'Capabilities', '/capabilities'),
              _buildLink(context, r, 'About Us', '/about'),
              _buildLink(context, r, 'Gallery', '/gallery'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection3(Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Info', style: TextStyle(color: Colors.white, fontSize: r.body, fontWeight: FontWeight.bold)),
        SizedBox(height: r.spacingM),
        Padding(
          padding: const EdgeInsets.only(left: 12),  // indent content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfo(r, Icons.location_on_outlined, CompanyContact.fullAddress, url: CompanyContact.googleMapsUrl),
              _buildInfo(r, Icons.phone_outlined, CompanyContact.phone),
              _buildInfo(r, Icons.email_outlined, CompanyContact.email),
              _buildInfo(r, Icons.schedule_outlined, 'Mon–Fri: ${CompanyContact.operatingHours["Monday - Friday"]}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLink(BuildContext context, Responsive r, String text, String route) {
    return Padding(
      padding: EdgeInsets.only(bottom: r.spacingXS),
      child: InkWell(
        onTap: () => context.go(route),
        child: Text(text, style: TextStyle(color: const Color(0xFF999999), fontSize: r.caption + 1)),
      ),
    );
  }

  Widget _buildInfo(Responsive r, IconData icon, String text, {String? url}) {
    return Padding(
      padding: EdgeInsets.only(bottom: r.spacingXS),
      child: InkWell(
        onTap: url != null ? () => launchUrl(Uri.parse(url)) : null,
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0066cc), size: r.iconSmall),
            SizedBox(width: r.spacingXS),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: const Color(0xFF999999),
                  fontSize: r.caption + 1,
                  decoration: url != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}