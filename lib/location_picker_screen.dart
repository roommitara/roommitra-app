import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'data.dart';
import 'theme.dart';

/// मालिक ने जो जगह चुनी, उसकी जानकारी
class LocationResult {
  final double lat;
  final double lng;
  final String address;
  final String city;
  final String locality;
  const LocationResult({
    required this.lat,
    required this.lng,
    required this.address,
    required this.city,
    required this.locality,
  });
}

class _Place {
  final String name;
  final LatLng point;
  const _Place(this.name, this.point);
}

class _Rev {
  final String address;
  final String city;
  final String locality;
  const _Rev(this.address, this.city, this.locality);
}

const Map<String, String> _headers = {
  'User-Agent': 'RoomMitraApp/1.0',
  'Accept-Language': 'hi,en',
};

class LocationPickerScreen extends StatefulWidget {
  /// एडिट करते समय पुरानी लोकेशन यहाँ आती है
  final LocationResult? initial;
  const LocationPickerScreen({super.key, this.initial});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // नक्शा खुलते समय सिर्फ देखने की शुरुआती जगह (नाहन के आसपास)।
  // यह सेव नहीं होती, मालिक को पिन खुद तय करना होगा।
  static const LatLng _defaultView = LatLng(30.5593, 77.2959);

  final MapController _map = MapController();
  final TextEditingController _search = TextEditingController();
  final TextEditingController _address = TextEditingController();

  late LatLng _pin;
  bool _chosen = false; // क्या मालिक ने जगह तय की?
  bool _addrEdited = false;
  bool _searching = false;
  bool _gpsBusy = false;
  bool _revBusy = false;
  bool _saving = false;
  List<_Place> _results = [];
  String _city = '';
  String _locality = '';
  Timer? _revTimer;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _pin = LatLng(i.lat, i.lng);
      _chosen = true;
      _address.text = i.address;
      _city = i.city;
      _locality = i.locality;
      _addrEdited = i.address.isNotEmpty;
    } else {
      _pin = _defaultView;
    }
  }

  @override
  void dispose() {
    _revTimer?.cancel();
    _search.dispose();
    _address.dispose();
    _map.dispose();
    super.dispose();
  }

  void _msg(String t) {
    if (!mounted) return;
    showMsg(context, t);
  }

  // ----------------------------- पता खोजना -----------------------------
  Future<void> _doSearch() async {
    final q = _search.text.trim();
    if (q.length < 3) {
      _msg('कम से कम 3 अक्षर लिखें');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _results = [];
    });
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': q,
        'format': 'jsonv2',
        'limit': '6',
        'countrycodes': 'in',
      });
      final r =
          await http.get(uri, headers: _headers).timeout(const Duration(seconds: 12));
      if (r.statusCode != 200) {
        _msg('खोज अभी काम नहीं कर रही, थोड़ी देर बाद कोशिश करें');
      } else {
        final list = jsonDecode(r.body) as List<dynamic>;
        final out = <_Place>[];
        for (final e in list) {
          final m = e as Map<String, dynamic>;
          final lat = double.tryParse('${m['lat']}');
          final lon = double.tryParse('${m['lon']}');
          if (lat == null || lon == null) continue;
          out.add(_Place('${m['display_name']}', LatLng(lat, lon)));
        }
        if (mounted) setState(() => _results = out);
        if (out.isEmpty) _msg('कोई जगह नहीं मिली। दूसरा नाम लिखकर देखें');
      }
    } catch (_) {
      _msg('इंटरनेट या खोज में दिक्कत है, फिर कोशिश करें');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _pickPlace(_Place p) {
    setState(() {
      _results = [];
      _pin = p.point;
      _chosen = true;
      if (!_addrEdited) _address.text = p.name;
    });
    _map.move(p.point, 17);
    _scheduleReverse();
  }

  // ----------------------------- GPS -----------------------------
  Future<void> _useGps() async {
    if (_gpsBusy) return;
    setState(() => _gpsBusy = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _msg('फोन की लोकेशन (GPS) चालू करें');
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied) {
        _msg('लोकेशन की इजाज़त नहीं मिली। आप पता खोजकर भी जगह चुन सकते हैं');
        return;
      }
      if (perm == LocationPermission.deniedForever) {
        _msg('लोकेशन की इजाज़त बंद है। फोन की सेटिंग में ऐप को इजाज़त दें');
        await Geolocator.openAppSettings();
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      final p = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        _pin = p;
        _chosen = true;
        _results = [];
      });
      _map.move(p, 18);
      _scheduleReverse();
    } on TimeoutException {
      _msg('GPS से जगह नहीं मिली। खुली जगह में जाकर फिर कोशिश करें');
    } catch (_) {
      _msg('GPS से लोकेशन नहीं मिल सकी। पता खोजकर या मैप खिसकाकर चुनें');
    } finally {
      if (mounted) setState(() => _gpsBusy = false);
    }
  }

  // ----------------------------- पता निकालना -----------------------------
  void _scheduleReverse() {
    _revTimer?.cancel();
    _revTimer = Timer(const Duration(milliseconds: 900), _reverse);
  }

  Future<_Rev?> _fetchReverse(LatLng p) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': '${p.latitude}',
        'lon': '${p.longitude}',
        'format': 'jsonv2',
        'addressdetails': '1',
        'zoom': '18',
      });
      final r =
          await http.get(uri, headers: _headers).timeout(const Duration(seconds: 12));
      if (r.statusCode != 200) return null;
      final m = jsonDecode(r.body) as Map<String, dynamic>;
      final a = (m['address'] as Map<String, dynamic>?) ?? {};
      String pick(List<String> keys) {
        for (final k in keys) {
          final v = a[k];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
        return '';
      }

      final city = pick(['city', 'town', 'village', 'municipality', 'county']);
      final locality = pick(
          ['suburb', 'neighbourhood', 'quarter', 'hamlet', 'village', 'road']);
      return _Rev('${m['display_name'] ?? ''}', city, locality);
    } catch (_) {
      return null;
    }
  }

  Future<void> _reverse() async {
    if (!_chosen || !mounted) return;
    setState(() => _revBusy = true);
    final at = _pin;
    final rev = await _fetchReverse(at);
    if (!mounted) return;
    // इस बीच पिन बदल गया हो तो पुराना जवाब छोड़ दें
    if (at != _pin) {
      setState(() => _revBusy = false);
      return;
    }
    setState(() {
      _revBusy = false;
      if (rev != null) {
        _city = rev.city;
        _locality = rev.locality;
        if (!_addrEdited) _address.text = rev.address;
      }
    });
  }

  // ----------------------------- पक्का करना -----------------------------
  Future<void> _confirm() async {
    if (!_chosen) {
      _msg('पहले जगह चुनें: पता खोजें, GPS दबाएँ या मैप खिसकाएँ');
      return;
    }
    setState(() => _saving = true);
    _revTimer?.cancel();
    if (_address.text.trim().isEmpty || _city.isEmpty) {
      final rev = await _fetchReverse(_pin);
      if (rev != null) {
        if (_city.isEmpty) _city = rev.city;
        if (_locality.isEmpty) _locality = rev.locality;
        if (_address.text.trim().isEmpty) _address.text = rev.address;
      }
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (_address.text.trim().isEmpty) {
      _msg('पता अपने आप नहीं मिला, कृपया नीचे पता खुद लिखें');
      return;
    }
    Navigator.of(context).pop(
      LocationResult(
        lat: _pin.latitude,
        lng: _pin.longitude,
        address: _address.text.trim(),
        city: _city,
        locality: _locality,
      ),
    );
  }

  // ----------------------------- स्क्रीन -----------------------------
  Widget _topBar() {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(4, top + 6, 12, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'प्रॉपर्टी की लोकेशन',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _doSearch(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'पता या इलाका खोजें (जैसे Rani Tal Nahan)',
                hintStyle: TextStyle(fontSize: 13.5, color: AppColors.muted),
              ),
            ),
          ),
          if (_searching)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _doSearch,
              child: const Text('खोजें'),
            ),
        ],
      ),
    );
  }

  Widget _resultList() {
    if (_results.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 6),
      constraints: const BoxConstraints(maxHeight: 230),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 8),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _results.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.border),
        itemBuilder: (context, i) {
          final p = _results[i];
          return ListTile(
            dense: true,
            leading:
                const Icon(Icons.location_on, color: AppColors.primary),
            title: Text(p.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13)),
            onTap: () => _pickPlace(p),
          );
        },
      ),
    );
  }

  Widget _mapArea() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: _pin,
            initialZoom: _chosen ? 17 : 13,
            minZoom: 4,
            maxZoom: 19,
            onPositionChanged: (camera, hasGesture) {
              if (hasGesture) {
                setState(() {
                  _pin = camera.center;
                  _chosen = true;
                  _results = [];
                });
                _scheduleReverse();
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.roommitra.roommitra_app',
            ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('© OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        // बीच में टिका हुआ पिन। नीचे की नोक मैप के ठीक बीच पर रहती है।
        IgnorePointer(
          child: Center(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Icon(
                Icons.location_on,
                size: 52,
                color: _chosen ? AppColors.danger : AppColors.muted,
              ),
            ),
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          top: 12,
          child: Column(
            children: [
              _searchBox(),
              _resultList(),
            ],
          ),
        ),
        Positioned(
          right: 12,
          bottom: 14,
          child: FloatingActionButton.small(
            heroTag: 'gps',
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            onPressed: _useGps,
            child: _gpsBusy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location),
          ),
        ),
        if (!_chosen)
          Positioned(
            left: 12,
            right: 64,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 6),
                ],
              ),
              child: const Text(
                'पता खोजें, GPS (दाईं तरफ का बटन) दबाएँ, या मैप को खिसकाकर पिन अपने कमरे की जगह पर रखें।',
                style: TextStyle(fontSize: 12, color: AppColors.text),
              ),
            ),
          ),
      ],
    );
  }

  Widget _bottomPanel() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          14, 12, 14, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x22000000), blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text('पूरा पता',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text)),
              const Spacer(),
              if (_revBusy)
                const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _address,
            maxLines: 2,
            minLines: 1,
            onChanged: (_) => _addrEdited = true,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'जगह चुनने पर पता यहाँ अपने आप आएगा, आप बदल भी सकते हैं',
              hintStyle:
                  const TextStyle(fontSize: 12.5, color: AppColors.muted),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          if (_chosen) ...[
            const SizedBox(height: 6),
            Text(
              'इलाका: ${_locality.isEmpty ? '-' : _locality}   शहर: ${_city.isEmpty ? '-' : _city}',
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _confirm,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle, size: 20),
              label: const Text('यही लोकेशन पक्की करें',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _topBar(),
            Expanded(child: _mapArea()),
            _bottomPanel(),
          ],
        ),
      ),
    );
  }
}
