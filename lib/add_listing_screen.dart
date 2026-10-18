import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'data.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'strings.dart';
import 'theme.dart';

class _KindOpt {
  final String label;
  final IconData icon;
  const _KindOpt(this.label, this.icon);
}

class AddListingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const AddListingScreen({super.key, required this.onDone});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  static const int _lastStep = 5;
  static const int _minPhotos = 5;
  static const int _maxPhotos = 10;

  List<_KindOpt> get _kinds => [
        _KindOpt(t('कमरा', 'Room'), Icons.bed),
        _KindOpt(t('फ्लैट', 'Flat'), Icons.apartment),
        _KindOpt(t('मकान', 'House'), Icons.home),
        const _KindOpt('PG', Icons.people_outline),
        _KindOpt(t('दुकान/ऑफिस', 'Shop/Office'), Icons.storefront),
      ];

  List<String> get _stepLabels => [
        t('कमरे की\nजानकारी', 'Room\ndetails'),
        t('किराया &\nडिपॉजिट', 'Rent &\ndeposit'),
        t('फोटो\nअपलोड', 'Photo\nupload'),
        t('सुविधाएँ', 'Amenities'),
        t('लोकेशन', 'Location'),
        t('समाप्त', 'Finish'),
      ];

  List<String> get _photoLabels => [
        t('कमरे की मुख्य फोटो', 'Main room photo'),
        t('दूसरी एंगल', 'Second angle'),
        t('किचन', 'Kitchen'),
        t('बाथरूम', 'Bathroom'),
        t('बालकनी', 'Balcony'),
      ];

  final ScrollController _scroll = ScrollController();
  final ImagePicker _picker = ImagePicker();

  int _step = 0;
  int _kind = 0;
  String _city = 'Nahan';
  int _rooms = 1;

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

  @override
  void dispose() {
    _scroll.dispose();
    for (final c in [
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
    ]) {
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
    }
    return null;
  }

  void _next() {
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
    if (_step > 0) {
      _goStep(_step - 1);
    } else {
      widget.onDone();
    }
  }

  Future<void> _submit() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 28),
            const SizedBox(width: 8),
            Expanded(child: Text(t('लिस्टिंग तैयार है!', 'Listing is ready!'))),
          ],
        ),
        content: Text(
          t(
            'यह अभी डेमो है, इसलिए जानकारी सेव नहीं हुई। Supabase जुड़ने के बाद '
                'आपकी लिस्टिंग "जाँच में" रहेगी और एडमिन के approve करने पर सबको दिखेगी।',
            'This is a demo for now, so the details were not saved. Once Supabase is connected, '
                'your listing will stay "under review" and become visible to everyone after the admin approves it.',
          ),
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t('ठीक है', 'OK')),
          ),
        ],
      ),
    );
    if (!mounted) return;
    _resetForm();
    widget.onDone();
  }

  void _resetForm() {
    for (final c in [
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
    ]) {
      c.clear();
    }
    setState(() {
      _photos.clear();
      _amen.clear();
      _kind = 0;
      _city = 'Nahan';
      _rooms = 1;
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
          Expanded(
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
      final lineColor = AppColors.primary;
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

  // ------------------------------------------------------------ स्टेप 1

  Widget _step0() {
    final kinds = _kinds;
    return Column(
      children: [
        _headerCard(
            Icons.home_work,
            t('कमरे की जानकारी', 'Room details'),
            t('अपने कमरे के बारे में बुनियादी जानकारी भरें',
                'Fill in the basic details about your room')),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label(t('प्रॉपर्टी का प्रकार', 'Property type')),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(kinds.length, (i) {
                  final sel = i == _kind;
                  return GestureDetector(
                    onTap: () => setState(() => _kind = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.tint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(kinds[i].icon,
                              size: 20,
                              color: sel ? Colors.white : AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            kinds[i].label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: sel ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
              _field(t('लिस्टिंग का शीर्षक', 'Listing title'), _title,
                  hint: t('जैसे - 1BHK रूम (फर्निश्ड)',
                      'e.g. 1BHK Room (Furnished)'),
                  required: true,
                  icon: Icons.title,
                  maxLength: 60),
              _dropdown<String>(
                t('शहर चुनें', 'Select city'),
                _city,
                allCities
                    .map((c) => DropdownMenuItem<String>(
                        value: c, child: Text(cityName(c))))
                    .toList(),
                (v) {
                  if (v != null) setState(() => _city = v);
                },
                required: true,
              ),
              _field(t('इलाका/एरिया', 'Area/Locality'), _area,
                  hint: t('जैसे - Rani Tal', 'e.g. Rani Tal'),
                  required: true,
                  icon: Icons.location_city,
                  maxLength: 40),
              _dropdown<int>(
                t('कमरे की संख्या', 'Number of rooms'),
                _rooms,
                [1, 2, 3, 4, 5]
                    .map((n) => DropdownMenuItem<int>(
                        value: n, child: Text(n == 5 ? '5+' : '$n')))
                    .toList(),
                (v) {
                  if (v != null) setState(() => _rooms = v);
                },
                required: true,
              ),
              _field(t('विवरण', 'Description'), _desc,
                  hint: t(
                      'जैसे - कमरे में बेड, अलमारी, वाई-फाई, पानी, बिजली, पार्किंग आदि की सुविधा...',
                      'e.g. Room has bed, wardrobe, WiFi, water, electricity, parking etc...'),
                  required: true,
                  maxLength: 500,
                  maxLines: 4),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ स्टेप 2

  Widget _step1() {
    return Column(
      children: [
        _headerCard(
            Icons.currency_rupee,
            t('किराया और डिपॉजिट', 'Rent and deposit'),
            t('किराया और अन्य ज़रूरी जानकारी भरें',
                'Fill in the rent and other important details')),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(t('किराया (₹ प्रति माह)', 'Rent (₹ per month)'), _rent,
                  hint: t('जैसे - 5000', 'e.g. 5000'),
                  required: true,
                  icon: Icons.currency_rupee,
                  keyboard: TextInputType.number,
                  maxLength: 6,
                  digitsOnly: true),
              _field(t('सिक्योरिटी डिपॉजिट (₹)', 'Security deposit (₹)'),
                  _deposit,
                  hint: t('जैसे - 10000 (वैकल्पिक)', 'e.g. 10000 (optional)'),
                  icon: Icons.savings_outlined,
                  keyboard: TextInputType.number,
                  maxLength: 7,
                  digitsOnly: true),
              _field(t('एरिया (sq ft)', 'Area (sq ft)'), _sqft,
                  hint: t('जैसे - 250 (वैकल्पिक)', 'e.g. 250 (optional)'),
                  icon: Icons.square_foot,
                  keyboard: TextInputType.number,
                  maxLength: 5,
                  digitsOnly: true),
              _field(t('मंज़िल', 'Floor'), _floor,
                  hint: t('जैसे - 1st Floor (वैकल्पिक)',
                      'e.g. 1st Floor (optional)'),
                  icon: Icons.apartment,
                  maxLength: 20),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.tintLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
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
                    'किराया और डिपॉजिट किरायेदार सीधे आपसे तय करेगा। RoomMitra पर कोई ऑनलाइन पेमेंट नहीं होता।',
                    'The tenant will fix the rent and deposit directly with you. There is no online payment on RoomMitra.',
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

  // ------------------------------------------------------------ स्टेप 3 (फोटो)

  Widget _photoTile(int i, double w) {
    final photoLabels = _photoLabels;
    final label = i < photoLabels.length
        ? '${i + 1}. ${photoLabels[i]}'
        : t('फोटो ${i + 1}', 'Photo ${i + 1}');
    return SizedBox(
      width: w,
      height: w * 0.85,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(_photos[i].path), fit: BoxFit.cover),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => setState(() => _photos.removeAt(i)),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Color(0xCC000000),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              left: 4,
              right: 4,
              bottom: 4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x99000000),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickBtn(IconData icon, String text, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: AppColors.tintLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary, width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 4),
              Text(text,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step2() {
    return Column(
      children: [
        _headerCard(
            Icons.photo_camera,
            t('कमरे की फोटो अपलोड करें', 'Upload room photos'),
            t('अच्छी क्वालिटी की फोटो डालें ताकि किरायेदार को कमरा बेहतर दिखे। (कम से कम $_minPhotos फोटो ज़रूरी)',
                'Add good quality photos so tenants can see the room better. (At least $_minPhotos photos required)')),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _pickBtn(Icons.photo_library,
                      t('गैलरी से चुनें', 'Choose from gallery'),
                      () => _pick(ImageSource.gallery)),
                  const SizedBox(width: 10),
                  _pickBtn(Icons.photo_camera,
                      t('कैमरा से लें', 'Take with camera'),
                      () => _pick(ImageSource.camera)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                t('JPG, PNG (अधिकतम 5MB प्रति फोटो)',
                    'JPG, PNG (maximum 5MB per photo)'),
                style:
                    const TextStyle(fontSize: 11.5, color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t('अपलोड की गई फोटो (${_photos.length}/$_maxPhotos)',
                          'Uploaded photos (${_photos.length}/$_maxPhotos)'),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text),
                    ),
                  ),
                  if (_photos.isNotEmpty)
                    GestureDetector(
                      onTap: () => setState(() => _photos.clear()),
                      child: Row(
                        children: [
                          Text(t('सभी हटाएं', 'Remove all'),
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.danger)),
                          const SizedBox(width: 4),
                          const Icon(Icons.delete_outline,
                              size: 18, color: AppColors.danger),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (_photos.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  decoration: BoxDecoration(
                    color: AppColors.tintLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    t('अभी कोई फोटो नहीं जोड़ी गई', 'No photos added yet'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.muted),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, c) {
                    const gap = 8.0;
                    final w = (c.maxWidth - gap * 2) / 3;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: List.generate(
                          _photos.length, (i) => _photoTile(i, w)),
                    );
                  },
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(t('फोटो के लिए सुझाव', 'Tips for photos'),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t(
                  '• अच्छी रोशनी में फोटो लें (दिन में सबसे बेहतर)\n'
                      '• बेडरूम, किचन, बाथरूम की अलग-अलग फोटो लें\n'
                      '• फोटो साफ़ हो, धुंधली फोटो से बचें\n'
                      '• दरवाज़ा, खिड़की, बालकनी भी दिखाएँ',
                  '• Take photos in good light (daytime is best)\n'
                      '• Take separate photos of the bedroom, kitchen and bathroom\n'
                      '• Keep photos sharp, avoid blurry ones\n'
                      '• Show the door, window and balcony too',
                ),
                style: const TextStyle(
                    fontSize: 12.5, height: 1.6, color: AppColors.text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ स्टेप 4

  Widget _step3() {
    return Column(
      children: [
        _headerCard(
            Icons.star,
            t('सुविधाएँ और संपर्क', 'Amenities and contact'),
            t('कमरे में जो सुविधाएँ हैं वो चुनें और अपना संपर्क लिखें',
                'Select the amenities in the room and enter your contact')),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label(t('सुविधाएँ (चुनें)', 'Amenities (select)')),
              LayoutBuilder(
                builder: (context, c) {
                  const gap = 8.0;
                  final w = (c.maxWidth - gap * 4) / 5;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: allAmenities.map((a) {
                      final on = _amen.contains(a.id);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (on) {
                            _amen.remove(a.id);
                          } else {
                            _amen.add(a.id);
                          }
                        }),
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
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  size: 16,
                                  color: on
                                      ? AppColors.primary
                                      : AppColors.border,
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
        ),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(t('आपका संपर्क विवरण', 'Your contact details'),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text)),
                ],
              ),
              const SizedBox(height: 10),
              _field(t('नाम', 'Name'), _name,
                  hint: t('जैसे - राजेश शर्मा', 'e.g. Rajesh Sharma'),
                  required: true,
                  icon: Icons.person,
                  maxLength: 40),
              _field(t('मोबाइल नंबर', 'Mobile number'), _phone,
                  hint: t('10 अंकों का नंबर', '10-digit number'),
                  required: true,
                  icon: Icons.phone,
                  keyboard: TextInputType.phone,
                  maxLength: 10,
                  digitsOnly: true),
              _field(t('WhatsApp (वैकल्पिक)', 'WhatsApp (optional)'), _whatsapp,
                  hint: t('10 अंकों का नंबर', '10-digit number'),
                  icon: Icons.chat,
                  keyboard: TextInputType.phone,
                  maxLength: 10,
                  digitsOnly: true),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ स्टेप 5

  Widget _step4() {
    return Column(
      children: [
        _headerCard(
            Icons.location_on,
            t('लोकेशन', 'Location'),
            t('कमरे का पता लिखें ताकि किरायेदार सही जगह पहुँच सके',
                'Enter the room address so that the tenant can reach the right place')),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(t('पूरा पता', 'Full address'), _address,
                  hint: t('मकान नंबर, गली, मोहल्ला...',
                      'House number, street, locality...'),
                  required: true,
                  icon: Icons.home_outlined,
                  maxLength: 150,
                  maxLines: 3),
              _field(t('नज़दीकी लैंडमार्क', 'Nearby landmark'), _landmark,
                  hint: t('जैसे - रानी ताल के पास (वैकल्पिक)',
                      'e.g. Near Rani Tal (optional)'),
                  icon: Icons.flag_outlined,
                  maxLength: 60),
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
              const Icon(Icons.lock, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t(
                    'आपका पूरा पता और फोन नंबर सुरक्षित रहता है। किरायेदार को सिर्फ इलाके का नाम दिखता है।',
                    'Your full address and phone number stay safe. Tenants only see the area name.',
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

  // ------------------------------------------------------------ स्टेप 6

  Widget _sumRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(k,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.muted)),
          ),
          Expanded(
            child: Text(
              v.isEmpty ? '-' : v,
              style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step5() {
    final rent = int.tryParse(_rent.text.trim()) ?? 0;
    final dep = int.tryParse(_deposit.text.trim()) ?? 0;
    final amenNames = allAmenities
        .where((a) => _amen.contains(a.id))
        .map((a) => a.label)
        .join(', ');
    return Column(
      children: [
        _headerCard(
            Icons.fact_check,
            t('सब ठीक है? एक बार देख लें', 'All good? Please review once'),
            t('सबमिट करने से पहले अपनी जानकारी जाँच लें',
                'Check your details before submitting')),
        _card(
          Column(
            children: [
              _sumRow(t('प्रकार', 'Type'), _kinds[_kind].label),
              _sumRow(t('शीर्षक', 'Title'), _title.text.trim()),
              _sumRow(t('जगह', 'Place'),
                  '${_area.text.trim()}, ${cityName(_city)}'),
              _sumRow(t('कमरे', 'Rooms'), _rooms == 5 ? '5+' : '$_rooms'),
              _sumRow(t('किराया', 'Rent'),
                  rent > 0 ? '₹${inr(rent)}${t('/माह', '/month')}' : ''),
              _sumRow(t('डिपॉजिट', 'Deposit'), dep > 0 ? '₹${inr(dep)}' : ''),
              _sumRow(t('फोटो', 'Photos'), '${_photos.length}'),
              _sumRow(t('सुविधाएँ', 'Amenities'), amenNames),
              _sumRow(t('नाम', 'Name'), _name.text.trim()),
              _sumRow(t('मोबाइल', 'Mobile'), _phone.text.trim()),
              _sumRow(t('पता', 'Address'), _address.text.trim()),
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
              const Icon(Icons.verified_user,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t(
                    'लिस्टिंग 100% फ्री है। सबमिट के बाद एडमिन जाँच करेगा, फिर वह सबको दिखेगी।',
                    'Listing is 100% free. After you submit, the admin will review it and then it will be visible to everyone.',
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

  Widget _body() {
    switch (_step) {
      case 0:
        return _step0();
      case 1:
        return _step1();
      case 2:
        return _step2();
      case 3:
        return _step3();
      case 4:
        return _step4();
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
                onPressed: _back,
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
                onPressed: _next,
                icon: Icon(last ? Icons.send : Icons.arrow_forward, size: 20),
                iconAlignment: IconAlignment.end,
                label: Text(last
                    ? t('लिस्टिंग सबमिट करें', 'Submit listing')
                    : t('अगला चरण', 'Next step')),
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
