import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'data.dart';
import 'detail_screen.dart';
import 'location_service.dart';
import 'strings.dart';
import 'theme.dart';

/// होम पर "आपके पास के कमरे": फोन की जगह से सबसे पास के उपलब्ध कमरे।
/// सिर्फ वही कमरे आते हैं जिनमें मालिक ने मैप पिन लगाया है।
class NearbyRooms extends StatelessWidget {
  static const double _maxKm = 50;
  const NearbyRooms({super.key});

  Widget _box(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tintLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _msgBox(
      IconData icon, String text, String? btn, VoidCallback? onTap) {
    return _box(
      Column(
        children: [
          Icon(icon, size: 36, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: AppColors.text),
          ),
          if (btn != null) ...[
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(btn),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card(BuildContext context, Listing l, double km) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => DetailScreen(listing: l)),
      ),
      child: Container(
        width: 200,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ListingImage(
                  listing: l,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.near_me, size: 13, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          NearbyService.formatKm(km),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l.area,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${inr(l.price)}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 3),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text(
                          t('/माह', '/month'),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final svc = NearbyService.instance;

    switch (svc.status) {
      case NearbyStatus.denied:
        return _msgBox(
          Icons.location_off,
          t('अपने पास के कमरे देखने के लिए लोकेशन की इजाज़त दें',
              'Allow location to see rooms near you'),
          t('इजाज़त दें', 'Allow'),
          () => svc.refresh(ask: true),
        );
      case NearbyStatus.deniedForever:
        return _msgBox(
          Icons.location_off,
          t('लोकेशन की इजाज़त बंद है। फोन की सेटिंग में ऐप को इजाज़त दें',
              'Location permission is off. Allow it in phone settings'),
          t('सेटिंग खोलें', 'Open settings'),
          () => Geolocator.openAppSettings(),
        );
      case NearbyStatus.serviceOff:
        return _msgBox(
          Icons.gps_off,
          t('फोन की लोकेशन (GPS) बंद है। चालू करें',
              'Phone location (GPS) is off. Please turn it on'),
          t('लोकेशन चालू करें', 'Turn on location'),
          () async {
            await Geolocator.openLocationSettings();
            await svc.refresh(ask: true);
          },
        );
      case NearbyStatus.error:
        if (!svc.hasPosition) {
          return _msgBox(
            Icons.wifi_tethering_error,
            t('आपकी जगह नहीं मिल सकी। खुली जगह में जाकर फिर कोशिश करें',
                'Could not get your location. Try again outdoors'),
            t('फिर कोशिश करें', 'Try again'),
            () => svc.refresh(ask: true),
          );
        }
        break;
      default:
        break;
    }

    if (!svc.hasPosition) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!listingsStore.loaded) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final near = <MapEntry<Listing, double>>[];
    for (final l in listingsStore.items) {
      if (l.status != 'approved' || !l.isAvailable || !l.hasLocation) continue;
      final km = svc.distanceKm(l.lat, l.lng);
      if (km == null || km > _maxKm) continue;
      near.add(MapEntry(l, km));
    }
    near.sort((a, b) => a.value.compareTo(b.value));

    if (near.isEmpty) {
      return _msgBox(
        Icons.search_off,
        t('आपके ${_maxKm.toInt()} km के अंदर अभी कोई उपलब्ध कमरा नहीं मिला',
            'No available rooms found within ${_maxKm.toInt()} km of you'),
        null,
        null,
      );
    }

    final shown = near.take(10).toList();
    return SizedBox(
      height: 236,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 14, left: 2, right: 2),
        itemCount: shown.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) =>
            _card(context, shown[i].key, shown[i].value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([NearbyService.instance, listingsStore]),
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.near_me, color: AppColors.primary, size: 22),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    t('आपके पास के कमरे', 'Rooms near you'),
                    style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark),
                  ),
                ),
                InkWell(
                  onTap: () {
                    NearbyService.instance.refresh(ask: true);
                    listingsStore.load();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child:
                        Icon(Icons.refresh, size: 22, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _body(context),
          ],
        );
      },
    );
  }
}
