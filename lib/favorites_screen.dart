import 'package:flutter/material.dart';
import 'data.dart';
import 'detail_screen.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'strings.dart';
import 'theme.dart';

class FavoritesScreen extends StatefulWidget {
  /// खाली स्क्रीन पर "कमरे खोजें" दबाने पर चलेगा
  final VoidCallback onSearchTap;
  const FavoritesScreen({super.key, required this.onSearchTap});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    appState.loadFavorites();
    if (!listingsStore.loaded && !listingsStore.loading) {
      listingsStore.load();
    }
  }

  Widget _topBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 10, 16, 12),
      child: const Row(
        children: [
          RoomMitraLogo(),
          Spacer(),
          Icon(Icons.favorite, color: Colors.white, size: 26),
        ],
      ),
    );
  }

  Widget _headerCard(int count) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('मेरे पसंदीदा कमरे', 'My favourite rooms'),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
                const SizedBox(height: 2),
                Text(
                  t('आपके द्वारा सेव किए गए सभी कमरे यहाँ दिखाई देंगे।',
                      'All the rooms you have saved will appear here.'),
                  style: const TextStyle(
                      fontSize: 12, height: 1.3, color: AppColors.text),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bookmark,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  t('कुल $count', 'Total $count'),
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
      ],
    );
  }

  List<String> _tags(Listing l) {
    final tags = <String>[l.kindLabel];
    if (l.verified) tags.add(t('सत्यापित', 'Verified'));
    if (l.immediate) tags.add(t('तुरंत उपलब्ध', 'Available now'));
    if (l.directOwner) tags.add(t('मालिक से सीधे', 'Direct from owner'));
    if (l.safeWomen) tags.add(t('सुरक्षित महिला', 'Women-safe'));
    return tags.take(3).toList();
  }

  String _amenityLine(Listing l) {
    return allAmenities
        .where((a) => l.amenities.contains(a.id))
        .map((a) => a.label)
        .take(5)
        .join(', ');
  }

  Widget _card(BuildContext context, Listing l) {
    final amen = _amenityLine(l);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DetailScreen(listing: l),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
                color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 112,
              height: 130,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ListingImage(listing: l, fit: BoxFit.cover),
                    Positioned(
                      left: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0x99000000),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_camera,
                                size: 13, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '1/${l.photos}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          l.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => appState.toggleFavorite(l.id),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.favorite,
                              size: 24, color: Color(0xFFE53935)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 15, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          l.area,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12.5, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.tint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹${inr(l.price)}${t('/माह', '/month')}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      if (l.typeLabel.isNotEmpty)
                        _stat(Icons.home_outlined, l.typeLabel),
                      if (l.sqft > 0)
                        _stat(Icons.square_foot, '${l.sqft} sq ft'),
                      if (l.floor.isNotEmpty)
                        _stat(Icons.apartment, l.floor),
                    ],
                  ),
                  if (amen.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      amen,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _tags(l)
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.tint,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        children: [
          const Icon(Icons.favorite_border, size: 72, color: AppColors.muted),
          const SizedBox(height: 14),
          Text(
            t('अभी कोई पसंदीदा कमरा नहीं है', 'No favourite rooms yet'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.text),
          ),
          const SizedBox(height: 6),
          Text(
            t('कमरे पर दिल का निशान दबाकर उसे यहाँ सेव करें।',
                'Tap the heart icon on a room to save it here.'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: widget.onSearchTap,
            icon: const Icon(Icons.search, size: 20),
            label: Text(t('कमरे खोजें', 'Search rooms')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              textStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingBox() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _errorBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        children: [
          const Icon(Icons.wifi_off, size: 56, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(
            listingsStore.error ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: listingsStore.loading ? null : listingsStore.load,
            child: Text(t('फिर कोशिश करें', 'Try again')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, lang, _) {
        return ListenableBuilder(
          listenable: Listenable.merge([appState, listingsStore]),
          builder: (context, _) {
            final loaded = listingsStore.loaded;
            final favs = loaded
                ? listingsStore.items
                    .where((l) =>
                        appState.isFav(l.id) &&
                        l.status == 'approved' &&
                        l.isAvailable)
                    .toList()
                : <Listing>[];
            return Scaffold(
              backgroundColor: const Color(0xFFF7FCF9),
              body: Column(
                children: [
                  _topBar(context),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      children: [
                        _headerCard(favs.length),
                        const SizedBox(height: 12),
                        if (!loaded && listingsStore.error == null)
                          _loadingBox()
                        else if (!loaded)
                          _errorBox()
                        else if (favs.isEmpty)
                          _empty()
                        else
                          ...favs.map((l) => _card(context, l)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
