part of 'add_listing_screen.dart';

// फॉर्म के 6 स्टेप। यह फ़ाइल add_listing_screen.dart का हिस्सा है।
extension _AddListingSteps on _AddListingScreenState {
  // ------------------------------------------------------------ छोटे विजेट

  Widget _choice(String text, bool sel, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sel ? AppColors.primary : AppColors.tint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: sel ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  String _titleHint() {
    switch (_category) {
      case 'shop':
        return t('जैसे - मेन बाज़ार में दुकान', 'e.g. Shop in main market');
      case 'pg_hostel':
        return t('जैसे - लड़कों के लिए PG (खाना सहित)',
            'e.g. PG for boys (food included)');
      case 'sharing':
        return t('जैसे - 2BHK में रूम पार्टनर चाहिए',
            'e.g. Room partner needed in 2BHK');
      case 'flat':
        return t('जैसे - 2BHK फ्लैट (फर्निश्ड)', 'e.g. 2BHK Flat (Furnished)');
      default:
        return t('जैसे - 1BHK रूम (फर्निश्ड)', 'e.g. 1BHK Room (Furnished)');
    }
  }

  // ------------------------------------------------------------ स्टेप 1

  Widget _step0() {
    final isSharing = _category == 'sharing';
    final isGB = _category == 'girls_boys';
    return Column(
      children: [
        _headerCard(
            Icons.home_work,
            t('लिस्टिंग की जानकारी', 'Listing details'),
            t('अपनी प्रॉपर्टी के बारे में बुनियादी जानकारी भरें',
                'Fill in the basic details about your property')),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label(t('श्रेणी चुनें', 'Choose category'), required: true),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: listingCategories.map((c) {
                  final sel = c.code == _category;
                  return GestureDetector(
                    onTap: () => _set(() => _category = c.code),
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
                          Icon(c.icon,
                              size: 20,
                              color: sel ? Colors.white : AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            c.label,
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
                }).toList(),
              ),
              if (isSharing || isGB) ...[
                const SizedBox(height: 14),
                _label(
                    isSharing
                        ? t('रूम पार्टनर कौन चाहिए?',
                            'Who do you want as room partner?')
                        : t('किनके लिए?', 'For whom?'),
                    required: true),
                Row(
                  children: [
                    _choice(
                        isSharing ? t('लड़का', 'Male') : t('लड़के', 'Boys'),
                        _gender == 'male',
                        () => _set(() => _gender = 'male')),
                    const SizedBox(width: 10),
                    _choice(
                        isSharing ? t('लड़की', 'Female') : t('लड़कियाँ', 'Girls'),
                        _gender == 'female',
                        () => _set(() => _gender = 'female')),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              _field(t('लिस्टिंग का शीर्षक', 'Listing title'), _title,
                  hint: _titleHint(),
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
                  if (v != null) _set(() => _city = v);
                },
                required: true,
              ),
              _field(t('इलाका/एरिया', 'Area/Locality'), _area,
                  hint: t('जैसे - Rani Tal', 'e.g. Rani Tal'),
                  required: true,
                  icon: Icons.location_city,
                  maxLength: 40),
              _dropdown<int>(
                t('कमरों की संख्या', 'Number of rooms'),
                _rooms,
                [1, 2, 3, 4, 5]
                    .map((n) => DropdownMenuItem<int>(
                        value: n, child: Text(n == 5 ? '5+' : '$n')))
                    .toList(),
                (v) {
                  if (v != null) _set(() => _rooms = v);
                },
                required: true,
              ),
              _field(t('विवरण', 'Description'), _desc,
                  hint: t(
                      'जैसे - बेड, अलमारी, वाई-फाई, पानी, बिजली, पार्किंग आदि की सुविधा...',
                      'e.g. Bed, wardrobe, WiFi, water, electricity, parking etc...'),
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
              Icon(Icons.info_outline,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t(
                    'किराया और डिपॉजिट किरायेदार सीधे आपसे तय करेगा। RoomMitra पर कोई ऑनलाइन पेमेंट नहीं होता।',
                    'The tenant will fix the rent and deposit directly with you. There is no online payment on RoomMitra.',
                  ),
                  style: TextStyle(
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
                onTap: () => _set(() => _photos.removeAt(i)),
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
                  style: TextStyle(
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
            t('फोटो अपलोड करें', 'Upload photos'),
            t('अच्छी क्वालिटी की फोटो डालें ताकि किरायेदार को जगह बेहतर दिखे। (कम से कम $_minPhotos फोटो ज़रूरी)',
                'Add good quality photos so tenants can see the place better. (At least $_minPhotos photos required)')),
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
                    TextStyle(fontSize: 11.5, color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t('अपलोड की गई फोटो (${_photos.length}/$_maxPhotos)',
                          'Uploaded photos (${_photos.length}/$_maxPhotos)'),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text),
                    ),
                  ),
                  if (_photos.isNotEmpty)
                    GestureDetector(
                      onTap: () => _set(() => _photos.clear()),
                      child: Row(
                        children: [
                          Text(t('सभी हटाएं', 'Remove all'),
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.danger)),
                          const SizedBox(width: 4),
                          Icon(Icons.delete_outline,
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
                    style: TextStyle(
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
                  Icon(Icons.lightbulb,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(t('फोटो के लिए सुझाव', 'Tips for photos'),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t(
                  '• अच्छी रोशनी में फोटो लें (दिन में सबसे बेहतर)\n'
                      '• अलग-अलग कोने की फोटो लें\n'
                      '• फोटो साफ़ हो, धुंधली फोटो से बचें\n'
                      '• दरवाज़ा, खिड़की, बालकनी भी दिखाएँ',
                  '• Take photos in good light (daytime is best)\n'
                      '• Take photos from different corners\n'
                      '• Keep photos sharp, avoid blurry ones\n'
                      '• Show the door, window and balcony too',
                ),
                style: TextStyle(
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
            t('जो सुविधाएँ हैं वो चुनें और अपना संपर्क लिखें',
                'Select the amenities and enter your contact')),
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
                        onTap: () => _set(() {
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
                            color: on ? AppColors.tint : AppColors.surface,
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
                                      style: TextStyle(
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
                  Icon(Icons.phone, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(t('आपका संपर्क विवरण', 'Your contact details'),
                      style: TextStyle(
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
              _field(t('कॉल करने का नंबर', 'Calling number'), _phone,
                  hint: t('10 अंकों का नंबर', '10-digit number'),
                  required: true,
                  icon: Icons.phone,
                  keyboard: TextInputType.phone,
                  maxLength: 10,
                  digitsOnly: true),
              _field(t('WhatsApp नंबर (वैकल्पिक)', 'WhatsApp number (optional)'),
                  _whatsapp,
                  hint: t('10 अंकों का नंबर', '10-digit number'),
                  icon: Icons.chat,
                  keyboard: TextInputType.phone,
                  maxLength: 10,
                  digitsOnly: true),
              Text(
                t('ये नंबर सबको नहीं दिखते। किरायेदार को कॉल या WhatsApp के बटन से ही संपर्क मिलता है।',
                    'These numbers are not shown to everyone. Tenants reach you only through the call or WhatsApp buttons.'),
                style: TextStyle(
                    fontSize: 12, height: 1.4, color: AppColors.muted),
              ),
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
            t('सही जगह का पता लिखें ताकि किरायेदार सही जगह पहुँच सके',
                'Enter the address so that the tenant can reach the right place')),
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
              Icon(Icons.lock, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t(
                    'आपका पूरा पता और फोन नंबर सुरक्षित रहता है। किरायेदार को सिर्फ इलाके का नाम दिखता है।',
                    'Your full address and phone number stay safe. Tenants only see the area name.',
                  ),
                  style: TextStyle(
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
                    TextStyle(fontSize: 13, color: AppColors.muted)),
          ),
          Expanded(
            child: Text(
              v.isEmpty ? '-' : v,
              style: TextStyle(
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
    final needsGender = _category == 'sharing' || _category == 'girls_boys';
    String genderText = '';
    if (_category == 'sharing') {
      genderText =
          _gender == 'male' ? t('लड़का', 'Male') : t('लड़की', 'Female');
    } else if (_category == 'girls_boys') {
      genderText =
          _gender == 'male' ? t('लड़के', 'Boys') : t('लड़कियाँ', 'Girls');
    }
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
              _sumRow(t('श्रेणी', 'Category'), categoryLabel(_category)),
              if (needsGender)
                _sumRow(t('किनके लिए', 'For'), genderText),
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
              _sumRow(t('कॉल नंबर', 'Calling no.'), _phone.text.trim()),
              _sumRow(t('WhatsApp', 'WhatsApp'), _whatsapp.text.trim()),
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
              Icon(Icons.verified_user,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t(
                    'लिस्टिंग 100% फ्री है। सबमिट के बाद एडमिन जाँच करेगा, फिर वह सबको दिखेगी।',
                    'Listing is 100% free. After you submit, the admin will review it and then it will be visible to everyone.',
                  ),
                  style: TextStyle(
                      fontSize: 12.5, height: 1.4, color: AppColors.text),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
