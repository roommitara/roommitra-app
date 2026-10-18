import 'package:flutter/material.dart';
import 'data.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'strings.dart';
import 'theme.dart';

// ---------------------------------------------------------------------------
// फ़िल्टर स्क्रीन
// ---------------------------------------------------------------------------

class FilterScreen extends StatefulWidget {
  final Filters initial;
  final int Function(Filters) countFor;
  const FilterScreen({
    super.key,
    required this.initial,
    required this.countFor,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late Filters _f;
  final _localityCtrl = TextEditingController();

  static const List<int> _distances = [1, 2, 5, 10, 20];

  /// key = असली वैल्यू (listing.kind से मिलती है), value = दिखने वाला नाम
  List<MapEntry<String, String>> get _kinds => [
        const MapEntry('PG', 'PG'),
        MapEntry('फ्लैट', t('फ्लैट', 'Flat')),
        MapEntry('रूम', t('रूम', 'Room')),
        MapEntry('हॉस्टल', t('बॉयज/गर्ल्स हॉस्टल', 'Boys/Girls hostel')),
      ];

  @override
  void initState() {
    super.initState();
    _f = widget.initial;
    _localityCtrl.text = _f.locality;
  }

  @override
  void dispose() {
    _localityCtrl.dispose();
    super.dispose();
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _title(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.text),
          ),
        ),
      ],
    );
  }

  Widget _topBar() {
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
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () => showMsg(
                context,
                t('पसंदीदा कमरे नीचे के "पसंदीदा" टैब में दिखेंगे',
                    'Favourite rooms will appear in the "Favorites" tab below')),
            icon: const Icon(Icons.favorite_border, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.filter_alt, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('फ़िल्टर', 'Filter'),
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
                Text(
                  t('अपनी जरूरत के अनुसार कमरे को फ़िल्टर करें',
                      'Filter rooms as per your need'),
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.text),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _f = Filters();
                _localityCtrl.clear();
              });
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(t('सभी फ़िल्टर\nहटाएं', 'Clear all\nfilters'),
                style: const TextStyle(fontSize: 11.5, height: 1.2)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceCard() {
    final maxText = _f.maxPrice >= 25000 ? '₹25,000+' : '₹${inr(_f.maxPrice)}';
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(Icons.currency_rupee,
              t('किराया रेंज (प्रति माह)', 'Rent range (per month)')),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${inr(_f.minPrice)}',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text)),
              Text(maxText,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.tint,
              thumbColor: AppColors.primary,
              overlayColor: const Color(0x220B5D3B),
              rangeThumbShape:
                  const RoundRangeSliderThumbShape(enabledThumbRadius: 11),
            ),
            child: RangeSlider(
              values: RangeValues(
                  _f.minPrice.toDouble(), _f.maxPrice.toDouble()),
              min: 1000,
              max: 25000,
              divisions: 48,
              onChanged: (v) {
                setState(() {
                  _f.minPrice = v.start.round();
                  _f.maxPrice = v.end.round();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(Icons.location_on, t('स्थान', 'Location')),
          const SizedBox(height: 10),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _localityCtrl,
                    onChanged: (v) => setState(() => _f.locality = v),
                    style:
                        const TextStyle(fontSize: 14, color: AppColors.text),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: t('कॉलोनी, एरिया या इलाके का नाम',
                          'Colony, area or locality name'),
                      hintStyle: const TextStyle(
                          fontSize: 14, color: AppColors.muted),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _title(Icons.my_location, t('दूरी', 'Distance')),
          const SizedBox(height: 10),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _f.distanceKm,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.text),
                items: _distances
                    .map((d) => DropdownMenuItem<int>(
                        value: d,
                        child: Text(t('$d km तक', 'Up to $d km'))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _f.distanceKm = v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool sel, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sel ? AppColors.primary : AppColors.tint,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: sel ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _roomsKindCard() {
    final roomOptions = <int, String>{1: '1', 2: '2', 3: '3', 4: '4+'};
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(Icons.bed, t('कमरों की संख्या', 'Number of rooms')),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: roomOptions.entries.map((e) {
              final sel = _f.rooms == e.key;
              return _chip(e.value, sel, () {
                setState(() => _f.rooms = sel ? 0 : e.key);
              });
            }).toList(),
          ),
          const SizedBox(height: 16),
          _title(Icons.home, t('प्रकार', 'Type')),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kinds.map((k) {
              final sel = _f.kind == k.key;
              return _chip(k.value, sel, () {
                setState(() => _f.kind = sel ? null : k.key);
              });
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _amenitiesCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(Icons.star,
              t('सुविधाएँ (एक या अधिक चुनें)', 'Amenities (select one or more)')),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              const gap = 8.0;
              final w = (c.maxWidth - gap * 4) / 5;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: allAmenities.map((a) {
                  final on = _f.amenities.contains(a.id);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (on) {
                          _f.amenities.remove(a.id);
                        } else {
                          _f.amenities.add(a.id);
                        }
                      });
                    },
                    child: Container(
                      width: w,
                      height: 78,
                      decoration: BoxDecoration(
                        color: on ? AppColors.tint : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: on ? AppColors.primary : AppColors.border,
                          width: on ? 1.5 : 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Icon(
                              on
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 17,
                              color: on ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(a.icon,
                                    size: 24, color: AppColors.primary),
                                const SizedBox(height: 5),
                                Text(
                                  a.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14.5, color: AppColors.text),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Widget _optionsCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(Icons.settings, t('अन्य विकल्प', 'Other options')),
          const SizedBox(height: 6),
          _switchRow(
              t('केवल सत्यापित प्रॉपर्टी', 'Verified properties only'),
              _f.verifiedOnly,
              (v) => setState(() => _f.verifiedOnly = v)),
          _switchRow(
              t('सुरक्षित महिला प्रॉपर्टी', 'Women-safe property'),
              _f.safeWomen,
              (v) => setState(() => _f.safeWomen = v)),
          _switchRow(
              t('केवल मालिक से सीधे', 'Direct from owner only'),
              _f.directOwner,
              (v) => setState(() => _f.directOwner = v)),
          _switchRow(t('लड़कियों के लिए', 'For girls'), _f.girlsOnly,
              (v) => setState(() => _f.girlsOnly = v)),
          _switchRow(t('तुरंत उपलब्ध', 'Available immediately'), _f.immediate,
              (v) => setState(() => _f.immediate = v)),
          _switchRow(t('कमर्शियल प्रॉपर्टी', 'Commercial property'),
              _f.commercial, (v) => setState(() => _f.commercial = v)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, lang, _) {
        final count = widget.countFor(_f);
        return Scaffold(
          backgroundColor: const Color(0xFFF7FCF9),
          body: Column(
            children: [
              _topBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  children: [
                    _headerCard(),
                    _priceCard(),
                    _locationCard(),
                    _roomsKindCard(),
                    _amenitiesCard(),
                    _optionsCard(),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                    16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 10,
                        offset: Offset(0, -2)),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(_f),
                    icon: const Icon(Icons.search, size: 22),
                    label: Text(t('फ़िल्टर लागू करें ($count परिणाम)',
                        'Apply filters ($count results)')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
