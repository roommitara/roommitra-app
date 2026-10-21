import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'data.dart';
import 'guide_video.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'listing_service.dart';
import 'listing_success_screen.dart';
import 'location_picker_screen.dart';
import 'strings.dart';
import 'theme.dart';

// फॉर्म के 6 स्टेप add_listing_steps.dart में हैं (यह उसी फ़ाइल का हिस्सा है)
part 'add_listing_steps.dart';

class AddListingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const AddListingScreen({super.key, required this.onDone});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  static const int _lastStep = 6;

  // steps फ़ाइल (extension) में static नहीं दिखते, इसलिए ये getter हैं
  int get _minPhotos => 8;
  int get _maxPhotos => 12;

  List<String> get _stepLabels => [
        t('जानकारी', 'Details'),
        t('किराया', 'Rent'),
        t('फोटो', 'Photos'),
        t('सुविधाएँ', 'Amenities'),
        t('पता', 'Address'),
        t('मैप पिन', 'Map pin'),
        t('समाप्त', 'Finish'),
      ];

  List<String> get _photoLabels => [
        t('कमरे की मुख्य फोटो', 'Main room photo'),
        t('दूसरी एंगल', 'Second angle'),
        t('किचन', 'Kitchen'),
        t('बाथरूम', 'Bathroom'),
        t('बालकनी / खिड़की', 'Balcony / window'),
        t('दरवाज़ा', 'Door'),
        t('बाहर से बिल्डिंग', 'Building outside'),
        t('आसपास का रास्ता', 'Road nearby'),
      ];

  final ScrollController _scroll = ScrollController();
  final ImagePicker _picker = ImagePicker();

  int _step = 0;
  String _category = 'single_room';
  String _gender = 'male';
  String _city = 'Nahan';
  int _rooms = 1;
  bool _submitting = false;
  LocationResult? _loc; // मैप पर लगाया गया पिन

  final _title = TextEditingController();
  final _area = TextEditingController();
  final _desc = TextEditingController();
  final _rent = TextEditingController();
  final _deposit = TextEditingController();
  final _sqft = TextEditingController();
  final _floor = TextEditingController();
  final _address = TextEditingController();
  final _landmark = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();

  final List<XFile> _photos = [];
  final Set<String> _amen = <String>{};

  List<TextEditingController> get _controllers => [
        _title,
        _area,
        _desc,
        _rent,
        _deposit,
        _sqft,
        _floor,
        _address,
        _landmark,
        _name,
        _phone,
        _whatsapp,
      ];

  // steps फ़ाइल (extension) से setState चलाने के लिए
  void _set(VoidCallback f) => setState(f);

  @override
  void dispose() {
    _scroll.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ------------------------------------------------------------ स्टेप चलाना

  void _goStep(int s) {
    setState(() => _step = s);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  String? _validate(int s) {
    if (s == 0) {
      final needsGender = _category == 'sharing' || _category == 'girls_boys';
      if (needsGender && _gender != 'male' && _gender != 'female') {
        return t('किनके लिए है, यह चुनें', 'Choose who it is for');
      }
      if (_title.text.trim().length < 3) {
        return t('लिस्टिंग का शीर्षक लिखें', 'Enter the listing title');
      }
      if (_area.text.trim().isEmpty) {
        return t('इलाका/एरिया लिखें', 'Enter the area/locality');
      }
      if (_desc.text.trim().length < 10) {
        return t('विवरण कम से कम 10 अक्षर का लिखें',
            'Write a description of at least 10 characters');
      }
    } else if (s == 1) {
      final rent = int.tryParse(_rent.text.trim()) ?? 0;
      if (rent < 500) {
        return t('सही किराया लिखें (कम से कम ₹500)',
            'Enter a valid rent (at least ₹500)');
      }
    } else if (s == 2) {
      if (_photos.length < _minPhotos) {
        return t('कम से कम $_minPhotos फोटो जोड़ें (अभी ${_photos.length})',
            'Add at least $_minPhotos photos (now ${_photos.length})');
      }
    } else if (s == 3) {
      if (_name.text.trim().length < 2) {
        return t('अपना नाम लिखें', 'Enter your name');
      }
      if (_phone.text.trim().length != 10) {
        return t('मोबाइल नंबर 10 अंकों का होना चाहिए',
            'Mobile number must be 10 digits');
      }
      final w = _whatsapp.text.trim();
      if (w.isNotEmpty && w.length != 10) {
        return t('WhatsApp नंबर 10 अंकों का होना चाहिए',
            'WhatsApp number must be 10 digits');
      }
    } else if (s == 4) {
      if (_address.text.trim().length < 5) {
        return t('पूरा पता लिखें', 'Enter the full address');
      }
    } else if (s == 5) {
      if (_loc == null) {
        return t('नक्शे पर अपनी प्रॉपर्टी का पिन लगाएँ',
            'Place your property pin on the map');
      }
    }
    return null;
  }

  void _next() {
    if (_submitting) return;
    final err = _validate(_step);
    if (err != null) {
      showMsg(context, err);
      return;
    }
    if (_step < _lastStep) {
      _goStep(_step + 1);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_submitting) return;
    if (_step > 0) {
      _goStep(_step - 1);
    } else {
      widget.onDone();
    }
  }

  String _errorText(Object e) {
    final code = e is ListingError ? e.code : 'save';
    switch (code) {
      case 'login':
        return t('पहले लॉगिन करें, फिर लिस्टिंग डालें',
            'Please log in first, then add your listing');
      case 'upload':
        return t('फोटो अपलोड नहीं हो सकीं। इंटरनेट जाँचकर दोबारा कोशिश करें',
            'Photos could not be uploaded. Check your internet and try again');
      case 'limit':
        return t('आप अधिकतम 10 लिस्टिंग रख सकते हैं',
            'You can keep a maximum of 10 listings');
      default:
        return t('लिस्टिंग सेव नहीं हो सकी, दोबारा कोशिश करें',
            'Could not save the listing, please try again');
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    // सभी स्टेप दोबारा जाँचो, कोई गड़बड़ हो तो उसी स्टेप पर ले जाओ
    for (var s = 0; s <= 5; s++) {
      final err = _validate(s);
      if (err != null) {
        _goStep(s);
        showMsg(context, err);
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      final needsGender = _category == 'sharing' || _category == 'girls_boys';
      final landmark = _landmark.text.trim();
      final address = landmark.isEmpty
          ? _address.text.trim()
          : '${_address.text.trim()}\nLandmark: $landmark';

      await ListingService.submit(
        category: _category,
        roomType: roomTypeFor(_category, _rooms),
        title: _title.text.trim(),
        description: _desc.text.trim(),
        city: _city,
        locality: _area.text.trim(),
        rooms: _rooms,
        monthlyRent: int.tryParse(_rent.text.trim()) ?? 0,
        securityDeposit: int.tryParse(_deposit.text.trim()) ?? 0,
        sqft: int.tryParse(_sqft.text.trim()),
        floorLabel: _floor.text.trim(),
        amenities: _amen.toList(),
        suitableFor: needsGender ? <String>[_gender] : <String>[],
        girlsOnly: _category == 'girls_boys' && _gender == 'female',
        commercial: _category == 'shop',
        fullAddress: address,
        lat: _loc!.lat,
        lng: _loc!.lng,
        ownerName: _name.text.trim(),
        phone: _phone.text.trim(),
        whatsapp: _whatsapp.text.trim(),
        photos: List<XFile>.from(_photos),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showMsg(context, _errorText(e));
      return;
    }

    if (!mounted) return;
    setState(() => _submitting = false);
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const ListingSuccessScreen()),
    );
    if (!mounted) return;
    _resetForm();
    widget.onDone();
  }

  void _resetForm() {
    for (final c in _controllers) {
      c.clear();
    }
    setState(() {
      _photos.clear();
      _amen.clear();
      _category = 'single_room';
      _gender = 'male';
      _city = 'Nahan';
      _rooms = 1;
      _loc = null;
      _step = 0;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  // ------------------------------------------------------------ फोटो चुनना

  Future<void> _pick(ImageSource src) async {
    if (_photos.length >= _maxPhotos) {
      showMsg(
          context,
          t('अधिकतम $_maxPhotos फोटो ही जोड़ सकते हैं',
              'You can add a maximum of $_maxPhotos photos'));
      return;
    }
    try {
      List<XFile> picked;
      if (src == ImageSource.gallery) {
        picked = await _picker.pickMultiImage(imageQuality: 85);
      } else {
        final x = await _picker.pickImage(source: src, imageQuality: 85);
        picked = x == null ? <XFile>[] : <XFile>[x];
      }
      var skipped = 0;
      for (final f in picked) {
        if (_photos.length >= _maxPhotos) {
          skipped++;
          continue;
        }
        final size = await f.length();
        if (size > 5 * 1024 * 1024) {
          skipped++;
          continue;
        }
        _photos.add(f);
      }
      if (!mounted) return;
      setState(() {});
      if (skipped > 0) {
        showMsg(
            context,
            t('$skipped फोटो छोड़ी गईं (5MB से बड़ी या सीमा पूरी)',
                '$skipped photos were skipped (larger than 5MB or limit reached)'));
      }
    } catch (e) {
      if (!mounted) return;
      showMsg(
          context,
          t('फोटो नहीं चुन सके, दोबारा कोशिश करें',
              'Could not pick photos, please try again'));
    }
  }

  // ------------------------------------------------------------ छोटे विजेट

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
          EdgeInsets.fromLTRB(4, MediaQuery.of(context).padding.top + 6, 12, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: _back,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: RoomMitraLogo(),
              ),
            ),
          ),
          const Icon(Icons.help_outline, color: Colors.white),
        ],
      ),
    );
  }

  Widget _stepper() {
    final labels = _stepLabels;
    final items = <Widget>[];
    for (var i = 0; i < labels.length; i++) {
      final done = i < _step;
      final cur = i == _step;
      const lineColor = AppColors.primary;
      items.add(
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i == 0
                          ? Colors.transparent
                          : (i <= _step ? lineColor : AppColors.border),
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: (done || cur) ? AppColors.primary : AppColors.tint,
                      shape: BoxShape.circle,
                    ),
                    child: done
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: cur ? Colors.white : AppColors.muted,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i == labels.length - 1
                          ? Colors.transparent
                          : (i < _step ? lineColor : AppColors.border),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.2,
                  fontWeight: cur ? FontWeight.w800 : FontWeight.w500,
                  color: (done || cur) ? AppColors.text : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: items),
    );
  }

  Widget _headerCard(IconData icon, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text)),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 12.5, height: 1.3, color: AppColors.text)),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: text,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text),
            ),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.danger, fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _deco(String hint, {IconData? icon}) {
    OutlineInputBorder b(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: AppColors.muted),
      prefixIcon:
          icon == null ? null : Icon(icon, color: AppColors.primary, size: 22),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: b(AppColors.border),
      focusedBorder: b(AppColors.primary),
      border: b(AppColors.border),
    );
  }

  Widget _field(
    String label,
    TextEditingController c, {
    String hint = '',
    bool required = false,
    IconData? icon,
    TextInputType? keyboard,
    int? maxLength,
    int maxLines = 1,
    bool digitsOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required: required),
        TextField(
          controller: c,
          keyboardType: keyboard,
          maxLength: maxLength,
          maxLines: maxLines,
          inputFormatters:
              digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 15, color: AppColors.text),
          decoration: _deco(hint, icon: icon),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _dropdown<T>(
    String label,
    T value,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T?> onChanged, {
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required: required),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.text),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // ------------------------------------------------------------ मैप पिन

  Future<void> _pickLocation() async {
    final r = await Navigator.of(context).push<LocationResult>(
      MaterialPageRoute<LocationResult>(
        builder: (_) => LocationPickerScreen(initial: _loc),
      ),
    );
    if (r == null || !mounted) return;
    setState(() {
      _loc = r;
      // खाली फ़ील्ड मैप के पते से अपने आप भर दो (मालिक बाद में बदल सकता है)
      if (_address.text.trim().isEmpty) _address.text = r.address;
      if (_area.text.trim().isEmpty && r.locality.isNotEmpty) {
        _area.text = r.locality;
      }
      if (allCities.contains(r.city)) _city = r.city;
    });
  }

  Widget _stepPin() {
    final loc = _loc;
    return Column(
      children: [
        _headerCard(
            Icons.pin_drop,
            t('प्रॉपर्टी का मैप पिन', 'Property map pin'),
            t('नक्शे पर ठीक वही जगह चुनें जहाँ आपकी प्रॉपर्टी है',
                'Choose the exact spot of your property on the map')),
        _card(
          loc == null
              ? Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        color: AppColors.tint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_location_alt,
                          size: 44, color: AppColors.primary),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      t('अभी पिन नहीं लगा है', 'No pin placed yet'),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t('GPS से अपनी मौजूदा जगह लें, पता खोजें या नक्शा खिसकाकर पिन लगाएँ।',
                          'Use GPS, search an address or move the map to place the pin.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13, height: 1.4, color: AppColors.muted),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _pickLocation,
                        icon: const Icon(Icons.map, size: 22),
                        label: Text(t('नक्शे पर पिन लगाएँ', 'Place pin on map')),
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
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.primary, size: 26),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t('पिन लग गया है', 'Pin placed'),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.tintLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on,
                                  size: 20, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  loc.address,
                                  style: const TextStyle(
                                      fontSize: 13.5,
                                      height: 1.4,
                                      color: AppColors.text),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${loc.lat.toStringAsFixed(5)}, ${loc.lng.toStringAsFixed(5)}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _pickLocation,
                        icon: const Icon(Icons.edit_location_alt, size: 20),
                        label: Text(t('पिन बदलें', 'Change pin')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                              color: AppColors.primary, width: 1.2),
                          textStyle: const TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w700),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.tint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t(
                    'यह पिन नज़दीकी कमरे दिखाने और किरायेदार को Google Maps में रास्ता दिखाने के काम आएगा।',
                    'This pin is used to show nearby rooms and to give tenants directions in Google Maps.',
                  ),
                  style: const TextStyle(
                      fontSize: 12.5, height: 1.4, color: AppColors.text),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ बॉडी / बटन

  Widget _body() {
    switch (_step) {
      case 0:
        return Column(
          children: [
            const GuideVideo(
              asset: 'assets/guide_category.mp4',
              hi: 'यहाँ अपने कमरे का प्रकार चुनिए, फिर नाम लिखिए, इलाका बताइए और कमरों की संख्या भरिए।',
              en: 'Choose your room type here, then enter the title, area and number of rooms.',
            ),
            _step0(),
          ],
        );
      case 1:
        return Column(
          children: [
            const GuideVideo(
              asset: 'assets/guide_rent.mp4',
              hi: 'यहाँ अपना किराया भरें। आप महीने के कितने रुपये पर कमरा देना चाहते हैं?',
              en: 'Enter your rent here. How much per month do you want for the room?',
            ),
            _step1(),
          ],
        );
      case 2:
        return Column(
          children: [
            const GuideVideo(
              asset: 'assets/guide_photos.mp4',
              hi: 'यहाँ कमरे की कम से कम आठ साफ़ फोटो डालिए। रोशनी में खींची हुई फोटो ज़्यादा लोगों को पसंद आती हैं।',
              en: 'Add at least eight clear photos of the room here. Photos taken in good light attract more people.',
            ),
            _step2(),
          ],
        );
      case 3:
        return Column(
          children: [
            const GuideVideo(
              asset: 'assets/guide_amenities.mp4',
              hi: 'यहाँ कमरे की सुविधाएँ चुनिए, और अपना नाम व फोन नंबर भरिए, ताकि किरायेदार सीधे आपसे बात कर सकें।',
              en: 'Choose the room facilities here, and enter your name and phone number so tenants can contact you directly.',
            ),
            _step3(),
          ],
        );
      case 4:
        return _step4();
      case 5:
        return _stepPin();
      default:
        return _step5();
    }
  }

  Widget _bottomBar() {
    final last = _step == _lastStep;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          if (_step > 0) ...[
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _submitting ? null : _back,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(t('पिछला', 'Back')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _next,
                icon: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Icon(last ? Icons.send : Icons.arrow_forward, size: 20),
                iconAlignment: IconAlignment.end,
                label: Text(_submitting
                    ? t('भेज रहे हैं...', 'Submitting...')
                    : last
                        ? t('लिस्टिंग सबमिट करें', 'Submit listing')
                        : t('अगला चरण', 'Next step')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary,
                  disabledForegroundColor: Colors.white70,
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
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, lang, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7FCF9),
          body: Column(
            children: [
              _topBar(),
              _stepper(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: _body(),
                ),
              ),
              _bottomBar(),
            ],
          ),
        );
      },
    );
  }
}
