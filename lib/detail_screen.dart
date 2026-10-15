import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'booking_screen.dart';
import 'theme.dart';

/// किसी कमरे की सभी फोटो (डेमो में असली फोटो + नाहन की नमूना फोटो)
List<String> galleryOf(Listing l) {
  final all = <String>[
    l.image,
    'assets/nahan1.jpg',
    'assets/nahan2.jpg',
    'assets/nahan3.jpg',
    'assets/nahan4.jpg',
  ];
  final seen = <String>{};
  return all.where((p) => seen.add(p)).toList();
}

const Map<String, String> _ownerNames = {
  'n1': 'राजेश तिवारी',
  'n2': 'सुनील ठाकुर',
  'n3': 'मोहन शर्मा',
  'p1': 'रोहित शर्मा',
};

class _Cell {
  final IconData icon;
  final String text;
  const _Cell(this.icon, this.text);
}

Widget _greenBar(BuildContext context, {List<Widget> actions = const []}) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primaryDark, AppColors.primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    padding:
        EdgeInsets.fromLTRB(4, MediaQuery.of(context).padding.top + 6, 4, 10),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: RoomMitraLogo(),
            ),
          ),
        ),
        ...actions,
      ],
    ),
  );
}

class DetailScreen extends StatefulWidget {
  final Listing listing;
  const DetailScreen({super.key, required this.listing});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PageController _pc = PageController();
  int _page = 0;
  bool _expanded = false;

  Listing get l => widget.listing;
  late final List<String> _images = galleryOf(widget.listing);

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _openViewer(int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PhotoViewer(images: _images, initial: index),
      ),
    );
  }

  void _openAllPhotos() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PhotoGalleryScreen(listing: l, images: _images),
      ),
    );
  }

  Future<void> _openMaps() async {
    final q = Uri.encodeComponent(l.area);
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      showMsg(context, 'मैप नहीं खुल सका');
    }
  }

  Widget _topBar() {
    return _greenBar(
      context,
      actions: [
        ListenableBuilder(
          listenable: appState,
          builder: (context, _) {
            final fav = appState.isFav(l.id);
            return IconButton(
              onPressed: () => appState.toggleFavorite(l.id),
              icon: Icon(
                fav ? Icons.favorite : Icons.favorite_border,
                color: fav ? const Color(0xFFFF6B6B) : Colors.white,
              ),
            );
          },
        ),
        IconButton(
          onPressed: () =>
              showMsg(context, 'शेयर करने की सुविधा बाद में जुड़ेगी'),
          icon: const Icon(Icons.share, color: Colors.white),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (v) {
            if (v == 'report') {
              showMsg(context, 'रिपोर्ट वाली स्क्रीन बाद में जुड़ेगी');
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem<String>(
              value: 'report',
              child: Text('नकली लिस्टिंग रिपोर्ट करें'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _hero() {
    return SizedBox(
      height: 250,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pc,
            itemCount: _images.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => _openViewer(i),
              child: Image.asset(_images[i], fit: BoxFit.cover),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0x99000000),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_camera,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    '${_page + 1}/${_images.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          if (l.verified)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 16, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      'Verified',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _thumbs() {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _images.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == _images.length) {
            return GestureDetector(
              onTap: _openAllPhotos,
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library, color: Colors.white, size: 20),
                    SizedBox(height: 2),
                    Text('सभी फोटो',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            );
          }
          final sel = i == _page;
          return GestureDetector(
            onTap: () {
              _pc.animateToPage(i,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut);
            },
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: sel ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(_images[i], fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _titleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                l.title,
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.tint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '₹${inr(l.price)}/माह',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.location_on, size: 20, color: AppColors.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                l.area,
                style: const TextStyle(fontSize: 15, color: AppColors.text),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statsRow() {
    final cells = <_Cell>[
      _Cell(Icons.home_outlined, l.typeLabel),
      _Cell(Icons.bathtub_outlined, l.bathLabel),
      _Cell(Icons.square_foot, '${l.sqft} sq ft'),
      _Cell(Icons.apartment, l.floor),
    ];
    final children = <Widget>[];
    for (var i = 0; i < cells.length; i++) {
      if (i > 0) {
        children.add(Container(width: 1, height: 30, color: AppColors.border));
      }
      children.add(
        Expanded(
          child: Column(
            children: [
              Icon(cells[i].icon, size: 22, color: AppColors.primary),
              const SizedBox(height: 4),
              Text(
                cells[i].text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, color: AppColors.text),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: children),
    );
  }

  Widget _descBlock() {
    final long = l.desc.length > 90;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'विवरण',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text),
        ),
        const SizedBox(height: 6),
        Text(
          l.desc,
          maxLines: (_expanded || !long) ? null : 2,
          overflow: (_expanded || !long)
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 14.5, height: 1.5, color: AppColors.text),
        ),
        if (long)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _expanded ? 'कम पढ़ें' : 'और पढ़ें',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _amenitiesBlock() {
    final items =
        allAmenities.where((a) => l.amenities.contains(a.id)).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tintLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'सुविधाएँ',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.text),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              const gap = 8.0;
              final w = (c.maxWidth - gap * 3) / 4;
              return Wrap(
                spacing: gap,
                runSpacing: 12,
                children: items
                    .map((a) => SizedBox(
                          width: w,
                          child: Column(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: const BoxDecoration(
                                  color: AppColors.tint,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(a.icon,
                                    size: 24, color: AppColors.primary),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                a.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.text),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _ownerBlock() {
    final name = _ownerNames[l.id] ?? 'मकान मालिक';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.tint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 32, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('मकान मालिक',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
                if (l.verified) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.tint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified,
                            size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Verified Owner',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text('4.5 (डेमो)',
                      style: TextStyle(fontSize: 12.5, color: AppColors.text)),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.calendar_month,
                      size: 16, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text('3+ साल',
                      style: TextStyle(fontSize: 12.5, color: AppColors.text)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _locationBlock() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.map, size: 36, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('लोकेशन',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text)),
                const SizedBox(height: 2),
                Text(l.area,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.muted)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _openMaps,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.tint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Google Maps पर देखें',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _safetyNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield, color: AppColors.primary, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('सुरक्षित किराया अनुभव',
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text)),
                SizedBox(height: 2),
                Text(
                  'किराया और डिपॉजिट सीधे मालिक से तय करें। एडवांस देने से पहले कमरा ज़रूर देखें।',
                  style: TextStyle(
                      fontSize: 12.5, height: 1.4, color: AppColors.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BookingScreen(listing: l),
                ),
              ),
              icon: const Icon(Icons.calendar_month, size: 20),
              label: const Text('विज़िट का समय चुनें'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                textStyle:
                    const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => contactOwner(context, l, whatsapp: true),
                    icon: const Icon(Icons.chat, size: 20),
                    label: const Text('WhatsApp करें'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                          color: AppColors.primary, width: 1.2),
                      textStyle: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => contactOwner(context, l, whatsapp: false),
                    icon: const Icon(Icons.call, size: 20),
                    label: const Text('कॉल करें'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _topBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _hero(),
                  const SizedBox(height: 10),
                  _thumbs(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _titleBlock(),
                        const SizedBox(height: 14),
                        _statsRow(),
                        const SizedBox(height: 16),
                        _descBlock(),
                        const SizedBox(height: 16),
                        _amenitiesBlock(),
                        const SizedBox(height: 16),
                        _ownerBlock(),
                        const SizedBox(height: 16),
                        _locationBlock(),
                        const SizedBox(height: 16),
                        _safetyNote(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// फोटो गैलरी (ग्रिड)
// ---------------------------------------------------------------------------

class PhotoGalleryScreen extends StatelessWidget {
  final Listing listing;
  final List<String> images;
  const PhotoGalleryScreen(
      {super.key, required this.listing, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF9),
      body: Column(
        children: [
          _greenBar(context),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(listing.image,
                      width: 64, height: 52, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text),
                      ),
                      Text(
                        '₹${inr(listing.price)}/माह',
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.photo_library,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'फोटो गैलरी',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.tint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${images.length} तस्वीरें',
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: images.length,
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            _PhotoViewer(images: images, initial: i),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(images[i], fit: BoxFit.cover),
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0x99000000),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${i + 1}/${images.length}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => contactOwner(context, listing, whatsapp: false),
                icon: const Icon(Icons.call, size: 20),
                label: const Text('मालिक को कॉल करें'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// फुल-स्क्रीन फोटो (ज़ूम और स्वाइप)
// ---------------------------------------------------------------------------

class _PhotoViewer extends StatefulWidget {
  final List<String> images;
  final int initial;
  const _PhotoViewer({required this.images, required this.initial});

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final PageController _c;
  late int _i;

  @override
  void initState() {
    super.initState();
    _i = widget.initial;
    _c = PageController(initialPage: widget.initial);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_i + 1}/${widget.images.length}'),
      ),
      body: PageView.builder(
        controller: _c,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _i = i),
        itemBuilder: (context, i) => InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Center(
            child: Image.asset(widget.images[i], fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
