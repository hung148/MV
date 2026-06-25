import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Updates the browser's document title and key `<meta>` tags whenever
/// the user navigates to a new route.
///
/// Call [SeoHelper.update] once per page from the GoRouter pageBuilder,
/// before returning the page widget:
///
///   pageBuilder: (context, state) {
///     SeoHelper.update(
///       title: 'CNC Milling & Precision Machining | MV Manufacturing LLC',
///       description: 'Owner-operated CNC milling …',
///       canonicalPath: '/services',
///     );
///     return _fadePage(state, const ServicesPage());
///   },
///
/// No-ops on non-web platforms (kIsWeb guard), so the call is safe to
/// leave in place for any future mobile/desktop builds.
class SeoHelper {
  SeoHelper._();

  static const String _siteUrl = 'https://www.mvmanufacturing.com';

  /// Update [document.title], the `<meta name="description">` tag, and the
  /// `<link rel="canonical">` tag.  Pass [canonicalPath] as the bare path
  /// (e.g. `'/services'`); the full URL is assembled automatically.
  static void update({
    required String title,
    required String description,
    required String canonicalPath,
  }) {
    if (!kIsWeb) return;

    // ── document.title ────────────────────────────────────────────────────
    web.document.title = title;

    // ── <meta name="description"> ─────────────────────────────────────────
    _setMeta(attr: 'name', value: 'description', content: description);

    // ── <link rel="canonical"> ────────────────────────────────────────────
    _setCanonical('$_siteUrl$canonicalPath');
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Finds the first `<meta [attr]="[value]">` tag and sets its `content`.
  /// Creates a new tag and appends it to `<head>` if one doesn't exist yet.
  static void _setMeta({
    required String attr,
    required String value,
    required String content,
  }) {
    var el = web.document.querySelector('meta[$attr="$value"]')
        as web.HTMLMetaElement?;
    if (el == null) {
      el = web.document.createElement('meta') as web.HTMLMetaElement;
      el.setAttribute(attr, value);
      web.document.head?.appendChild(el);
    }
    el.content = content;
  }

  /// Finds or creates `<link rel="canonical">` and sets its `href`.
  static void _setCanonical(String href) {
    var el = web.document.querySelector('link[rel="canonical"]')
        as web.HTMLLinkElement?;
    if (el == null) {
      el = web.document.createElement('link') as web.HTMLLinkElement;
      el.rel = 'canonical';
      web.document.head?.appendChild(el);
    }
    el.href = href;
  }
}