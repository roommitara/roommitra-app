import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum NearbyStatus {
  idle,
  loading,
  ready,
  denied,
  deniedForever,
  serviceOff,
  error,
}

/// फोन की मौजूदा जगह और "नज़दीकी कमरे" के लिए दूरी निकालना।
/// ऐप खुलते ही refresh() चलता है और इजाज़त माँगता है।
class NearbyService extends ChangeNotifier {
  NearbyService._();
  static final NearbyService instance = NearbyService._();

  NearbyStatus status = NearbyStatus.idle;
  double? lat;
  double? lng;

  bool get hasPosition => lat != null && lng != null;

  void _set(NearbyStatus s) {
    status = s;
    notifyListeners();
  }

  /// ask = true हो तो इजाज़त का डिब्बा दिखाओ
  Future<void> refresh({bool ask = true}) async {
    if (status == NearbyStatus.loading) return;
    _set(NearbyStatus.loading);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _set(NearbyStatus.serviceOff);
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied && ask) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        _set(NearbyStatus.deniedForever);
        return;
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.unableToDetermine) {
        _set(NearbyStatus.denied);
        return;
      }

      // पहले पुरानी जानी-पहचानी जगह (तेज़), फिर ताज़ा जगह
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          lat = last.latitude;
          lng = last.longitude;
          _set(NearbyStatus.ready);
        }
      } catch (_) {}

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      lat = pos.latitude;
      lng = pos.longitude;
      _set(NearbyStatus.ready);
    } on TimeoutException {
      _set(hasPosition ? NearbyStatus.ready : NearbyStatus.error);
    } catch (_) {
      _set(hasPosition ? NearbyStatus.ready : NearbyStatus.error);
    }
  }

  /// मेरी जगह से कमरे तक की दूरी (km). जगह पता न हो तो null.
  double? distanceKm(double? roomLat, double? roomLng) {
    if (!hasPosition || roomLat == null || roomLng == null) return null;
    final m = Geolocator.distanceBetween(lat!, lng!, roomLat, roomLng);
    return m / 1000.0;
  }

  /// "850 m" या "2.4 km"
  static String formatKm(double km) {
    if (km < 1) {
      final m = (km * 1000 / 10).round() * 10;
      return '${m < 10 ? 10 : m} m';
    }
    return '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';
  }
}
