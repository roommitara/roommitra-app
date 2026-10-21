import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'data.dart';
import 'strings.dart';
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
  bool _satellite = false; // सैटेलाइट नक्शा
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
      _msg(t('कम से कम 3 अक्षर लिखें',
          'Type at least 3 letters'));
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
        _msg(t('खोज अभी काम नहीं कर रही, थोड़ी देर बाद कोशिश करें',
          'Search is not working right now, try again later'));
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
        if (out.isEmpty) _msg(t('कोई जगह नहीं मिली। दूसरा नाम लिखकर देखें',
          'No place found. Try another name'));
      }
    } catch (_) {
      _msg(t('इंटरनेट या खोज में दिक्कत है, फिर कोशिश करें',
          'Internet or search problem, please try again'));
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
        _msg(t('फोन की लोकेशन (GPS) चालू करें',
          'Turn on your phone location (GPS)'));
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied) {
        _msg(t('लोकेशन की इजाज़त नहीं मिली। आप पता खोजकर भी जगह चुन सकते हैं',
          'Location permission denied. You can also search for the address'));
        return;
      }
      if (perm == LocationPermission.deniedForever) {
        _msg(t('लोकेशन की इजाज़त बंद है। फोन की सेटिंग में ऐप को इजाज़त दें',
          'Location permission is blocked. Allow it for the app in phone settings'));
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
      _msg(t('GPS से जगह नहीं मिली। खुली जगह में जाकर फिर कोशिश करें',
          'Could not get a GPS fix. Go to an open area and try again'));
    } catch (_) {
      _msg(t('GPS से लोकेशन नहीं मिल सकी। पता खोजकर या मैप खिसकाकर चुनें',
          'Could not get location from GPS. Search the address or move the map'));
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
      _msg(t('पहले जगह चुनें: पता खोजें, GPS दबाएँ या मैप खिसकाएँ',
          'Choose a place first: search an address, press GPS or move the map'));
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
      _msg(t('पता अपने आप नहीं मिला, कृपया नीचे पता खुद लिखें',
          'Address not found automatically, please type it below'));
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
      decoration: BoxDecoration(
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
          Expanded(
            child: Text(
              t('प्रॉपर्टी की लोकेशन', 'Property location'),
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
      color: AppColors.surface,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _doSearch(),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: t('पता या इलाका खोजें (जैसे Rani Tal Nahan)',
                    'Search address or area (e.g. Rani Tal Nahan)'),
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
              child: Text(t('खोजें', 'Search')),
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
        color: AppColors.surface,
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
            Divider(height: 1, color: AppColors.border),
        itemBuilder: (context, i) {
          final p = _results[i];
          return ListTile(
            dense: true,
            leading:
                Icon(Icons.location_on, color: AppColors.primary),
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

  Widget _mapBtn(String tag, IconData icon, VoidCallback onTap,
      {bool active = false}) {
    return Material(
      color: active ? AppColors.primary : AppColors.surface,
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon,
              size: 24, color: active ? Colors.white : AppColors.primary),
        ),
      ),
    );
  }

  void _zoomBy(double d) {
    final cam = _map.camera;
    final z = (cam.zoom + d).clamp(4.0, 19.0).toDouble();
    _map.move(cam.center, z);
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
            if (_satellite)
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.roommitra.roommitra_app',
                maxNativeZoom: 19,
              )
            else
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                retinaMode: RetinaMode.isHighDensity(context),
                userAgentPackageName: 'com.roommitra.roommitra_app',
                maxNativeZoom: 19,
              ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(_satellite
                    ? 'Imagery © Esri, Maxar, Earthstar Geographics'
                    : '© OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        // बीच में टिका हुआ पिन। नीचे की नोक मैप के ठीक बीच पर रहती है।
        IgnorePointer(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // ज़मीन पर पड़ने वाली छोटी परछाईं
                Container(
                  width: 14,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0x55000000),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -26),
                  child: Icon(
                    Icons.location_on,
                    size: 58,
                    color: _chosen ? AppColors.danger : AppColors.muted,
                    shadows: const [
                      Shadow(
                          color: Color(0x66000000),
                          blurRadius: 8,
                          offset: Offset(0, 3)),
                    ],
                  ),
                ),
              ],
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
        // दाईं तरफ के बटन: सैटेलाइट, ज़ूम, GPS
        Positioned(
          right: 12,
          bottom: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _mapBtn('sat', Icons.satellite_alt,
                  () => setState(() => _satellite = !_satellite),
                  active: _satellite),
              const SizedBox(height: 8),
              _mapBtn('zin', Icons.add, () => _zoomBy(1)),
              const SizedBox(height: 8),
              _mapBtn('zout', Icons.remove, () => _zoomBy(-1)),
              const SizedBox(height: 8),
              Material(
                color: AppColors.surface,
                elevation: 3,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _useGps,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: _gpsBusy
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(Icons.my_location,
                            size: 24, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!_chosen)
          Positioned(
            left: 12,
            right: 68,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 6),
                ],
              ),
              child: Text(
                t('पता खोजें, GPS (दाईं तरफ का बटन) दबाएँ, या मैप को खिसकाकर पिन अपने कमरे की जगह पर रखें।',
                    'Search an address, press GPS (button on the right), or move the map to put the pin on your room.'),
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
      decoration: BoxDecoration(
        color: AppColors.surface,
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
              Icon(Icons.place, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(t('पूरा पता', 'Full address'),
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
              hintText: t('जगह चुनने पर पता यहाँ अपने आप आएगा, आप बदल भी सकते हैं',
                  'The address will appear here after you choose a place; you can edit it'),
              hintStyle:
                  TextStyle(fontSize: 12.5, color: AppColors.muted),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          if (_chosen) ...[
            const SizedBox(height: 6),
            Text(
              '${t('इलाका', 'Area')}: ${_locality.isEmpty ? '-' : _locality}   ${t('शहर', 'City')}: ${_city.isEmpty ? '-' : _city}',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
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
              label: Text(t('यही लोकेशन पक्की करें', 'Confirm this location'),
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
        backgroundColor: AppColors.bg,
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
