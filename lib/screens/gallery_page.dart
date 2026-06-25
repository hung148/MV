import 'package:flutter/material.dart';
import 'package:mv/widgets/fade_in_section.dart';
import 'package:mv/widgets/footer.dart';
import 'package:mv/widgets/page_hero.dart';
import 'package:mv/widgets/quote_form.dart';
import 'package:mv/widgets/responsive.dart';
import 'package:mv/widgets/scroll_reveal.dart';
import 'package:mv/widgets/hover_lift.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final List<String> _images = [
    'assets/images/gallery/gallery_1.webp',
    'assets/images/gallery/gallery_2.webp',
    'assets/images/gallery/gallery_3.webp',
    'assets/images/gallery/gallery_4.webp',
    'assets/images/gallery/gallery_5.webp',
    'assets/images/gallery/gallery_6.webp',
    'assets/images/gallery/gallery_7.webp',
    'assets/images/gallery/gallery_8.webp',
    'assets/images/gallery/gallery_9.webp',
    'assets/images/gallery/gallery_10.webp',
    'assets/images/gallery/gallery_11.webp',
    'assets/images/gallery/gallery_12.webp',
    'assets/images/gallery/gallery_13.webp',
    'assets/images/gallery/gallery_14.webp',
    'assets/images/gallery/gallery_15.webp',
    'assets/images/gallery/gallery_16.webp',
    'assets/images/gallery/gallery_17.webp',
    'assets/images/gallery/gallery_18.webp',
    'assets/images/gallery/gallery_19.webp',
    'assets/images/gallery/gallery_20.webp',
    'assets/images/gallery/gallery_21.webp',
    'assets/images/gallery/gallery_22.webp',
    'assets/images/gallery/gallery_23.webp',
    'assets/images/gallery/gallery_24.webp',
    'assets/images/gallery/gallery_25.webp',
    'assets/images/gallery/gallery_26.webp',
    'assets/images/gallery/gallery_27.webp',
    'assets/images/gallery/gallery_28.webp',
    'assets/images/gallery/gallery_29.webp',
    'assets/images/gallery/gallery_30.webp',
    'assets/images/gallery/gallery_31.webp',
    'assets/images/gallery/gallery_32.webp',
    'assets/images/gallery/gallery_33.webp',
    'assets/images/gallery/gallery_34.webp',
    'assets/images/gallery/gallery_35.webp',
    'assets/images/gallery/gallery_36.webp',
    'assets/images/gallery/gallery_37.webp',
    'assets/images/gallery/gallery_38.webp',
    'assets/images/gallery/gallery_39.webp',
    'assets/images/gallery/gallery_40.webp',
    'assets/images/gallery/gallery_41.webp',
    'assets/images/gallery/gallery_42.webp',
    'assets/images/gallery/gallery_43.webp',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final path in _images) {
      precacheImage(AssetImage(path), context);
    }
  }

  void _openLightbox(BuildContext context, int startIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _LightboxDialog(images: _images, initialIndex: startIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return Column(
      children: [
        FadeInSection(
          child: PageHero(
            title: 'Our Work',
            subtitle: 'Precision machined components across industries',
          ),
        ),
        _buildGrid(context, r),
        _buildCTASection(context, r),
        const AppFooter(),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, Responsive r) {
    return Container(
      padding: r.sectionPadding,
      color: const Color(0xFFf5f5f5),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: r.galleryGridColumns,
              crossAxisSpacing: r.cardSpacing,
              mainAxisSpacing: r.cardSpacing,
              childAspectRatio: 1.0,
            ),
            itemCount: _images.length,
            itemBuilder: (context, index) {
              // Cascade left -> right within each visual row, restarting the
              // stagger on each row so a tile in the 2nd/3rd row doesn't have
              // to wait through every prior tile's delay before it can move.
                  final rowPosition = index % r.galleryGridColumns;
                  return ScrollReveal.row(
                    index: rowPosition,
                    child: HoverLift(
                      liftPx: 6,
                      addShadow: true,
                      borderRadius: r.cardRadius,
                      child: GestureDetector(
                  onTap: () => _openLightbox(context, index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(r.cardRadius),
                    child: Image.asset(
                      _images[index],
                      fit: BoxFit.cover,
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded || frame != null) return child;
                        return Container(
                          color: const Color(0xFFe0e0e0),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0066cc),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                    ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCTASection(BuildContext context, Responsive r) {
    return Container(
      padding: r.sectionPadding,
      color: const Color(0xFF0d47a1),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxNarrowWidth),
          child: ScrollReveal(
            child: Column(
              children: [
                Text('Ready to See Your Project Here?', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                SizedBox(height: r.spacingM),
                Text("Let's bring your designs to life with precision manufacturing", style: TextStyle(fontSize: r.body + 2, color: Colors.white70), textAlign: TextAlign.center),
                SizedBox(height: r.spacingL),
                HoverLift(
                  liftPx: 3,
                  addShadow: true,
                  borderRadius: 4,
                  child: ElevatedButton(
                    onPressed: () => showQuoteDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0d47a1),
                      padding: r.primaryButtonPadding,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text('Start Your Project', style: TextStyle(fontSize: r.buttonText, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Lightbox dialog with left/right navigation
class _LightboxDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _LightboxDialog({required this.images, required this.initialIndex});

  @override
  State<_LightboxDialog> createState() => _LightboxDialogState();
}

class _LightboxDialogState extends State<_LightboxDialog> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == widget.images.length - 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Image.asset(widget.images[index], fit: BoxFit.contain),
                );
              },
            ),
          ),

          if (!isFirst)
            Positioned(
              left: 8,
              child: _ArrowButton(
                icon: Icons.arrow_back_ios_rounded,
                onTap: () => _goTo(_currentIndex - 1),
              ),
            ),

          if (!isLast)
            Positioned(
              right: 8,
              child: _ArrowButton(
                icon: Icons.arrow_forward_ios_rounded,
                onTap: () => _goTo(_currentIndex + 1),
              ),
            ),

          Positioned(
            top: 8,
            right: 8,
            child: _ArrowButton(
              icon: Icons.close,
              onTap: () => Navigator.pop(context),
            ),
          ),

          Positioned(
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      liftPx: 3,
      addShadow: true,
      shadowColor: Colors.black,
      borderRadius: 50,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}