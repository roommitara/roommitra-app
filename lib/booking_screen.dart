import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'notifications_screen.dart';
import 'strings.dart';
import 'theme.dart';

const List<String> _hiMonths = [
  'जनवरी',
  'फ़रवरी',
  'मार्च',
  'अप्रैल',
  'मई',
  'जून',
  'जुलाई',
  'अगस्त',
  'सितंबर',
  'अक्टूबर',
  'नवंबर',
  'दिसंबर',
];

const List<String> _enMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _hiDays = [
  'सोमवार',
  'मंगलवार',
  'बुधवार',
  'गुरुवार',
  'शुक्रवार',
  'शनिवार',
  'रविवार',
];

const List<String> _enDays = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

const List<String> _slots = [
  '09:00 AM – 10:00 AM',
  '11:00 AM – 12:00 PM',
  '02:00 PM – 03:00 PM',
  '04:00 PM – 05:00 PM',
  '06:00 PM – 07:00 PM',
];

String _monthName(DateTime d) =>
    t(_hiMonths[d.month - 1], _enMonths[d.month - 1]);

String _dayName(DateTime d) => t(_hiDays[d.weekday - 1], _enDays[d.weekday - 1]);

Widget _topBar(BuildContext context) {
  final top = MediaQuery.of(context).padding.top;
  return Container(
    color: AppColors.primary,
    padding: EdgeInsets.fromLTRB(4, top + 8, 12, 10),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        const RoomMitraLogo(),
      ],
    ),
  );
}

Widget _listingMiniCard(Listing l, {bool showVerified = true}) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 104,
            height: 104,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(l.image, fit: BoxFit.cover),
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x99000000),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.photo_camera,
                            size: 12, color: Colors.white),
                        const SizedBox(width: 3),
                        Text('1/${l.photos}',
                            style: const TextStyle(
                                fontSize: 10.5, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(l.area,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13, color: AppColors.text)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('₹${inr(l.price)}${t('/माह', '/month')}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 10,
                runSpacing: 4,
                children: [
                  _mini(Icons.bed_outlined,
                      '${l.rooms} ${t('कमरा', 'Room')}'),
                  _mini(Icons.square_foot,
                      '${l.sqft} ${t('वर्ग फुट', 'sq ft')}'),
                  _mini(Icons.apartment, '${l.floor}'),
                ],
              ),
              if (showVerified && l.verified) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.tint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user,
                          size: 15, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Text(t('सत्यापित प्रॉपर्टी', 'Verified property'),
                          style: TextStyle(
                              fontSize: 11.5, color: AppColors.text)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _mini(IconData icon, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: AppColors.primary),
      const SizedBox(width: 3),
      Text(text, style: TextStyle(fontSize: 11.5, color: AppColors.text)),
    ],
  );
}

class BookingScreen extends StatefulWidget {
  final Listing listing;
  const BookingScreen({super.key, required this.listing});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _day = 0;
  int _slot = 0;
  late final List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dates = List.generate(
      5,
      (i) => DateTime(now.year, now.month, now.day).add(Duration(days: i + 1)),
    );
  }

  String _dateText(DateTime d) =>
      '${d.day} ${_monthName(d)} ${d.year}, ${_dayName(d)}';

  Widget _step(int n, String label, bool done, bool active) {
    final on = done || active;
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: on ? AppColors.primary : AppColors.border,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text('$n',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                color: on ? AppColors.text : AppColors.muted)),
      ],
    );
  }

  Widget _line(bool on) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Container(
          height: 3,
          color: on ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  Widget _steps() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _step(1, t('कमरा चुनें', 'Choose room'), true, false),
          _line(true),
          _step(2, t('दिन और समय चुनें', 'Choose day & time'), false, true),
          _line(false),
          _step(3, t('कन्फर्मेशन', 'Confirmation'), false, false),
        ],
      ),
    );
  }

  Widget _section(
      {required IconData icon,
      required String title,
      required String sub,
      required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tintLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text)),
                    Text(sub,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _dateRow() {
    return Row(
      children: List.generate(_dates.length, (i) {
        final d = _dates[i];
        final sel = i == _day;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _day = i),
            child: Container(
              margin: EdgeInsets.only(right: i == _dates.length - 1 ? 0 : 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: sel ? AppColors.primary : AppColors.border),
              ),
              child: Column(
                children: [
                  Text('${d.day}',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: sel ? Colors.white : AppColors.text)),
                  Text(_monthName(d),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : AppColors.text)),
                  Text(_dayName(d),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 9.5,
                          color: sel ? Colors.white : AppColors.muted)),
                  const SizedBox(height: 6),
                  Icon(
                    sel ? Icons.radio_button_checked : Icons.radio_button_off,
                    size: 17,
                    color: sel ? Colors.white : AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _slotWrap() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_slots.length, (i) {
        final sel = i == _slot;
        return GestureDetector(
          onTap: () => setState(() => _slot = i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: sel ? AppColors.primary : AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_slots[i],
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : AppColors.text)),
                if (sel) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check, size: 16, color: Colors.white),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _summaryItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      TextStyle(fontSize: 11.5, color: AppColors.muted)),
              Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summary() {
    final l = widget.listing;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tintLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.home, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(t('आपकी बुकिंग का सारांश', 'Your booking summary'),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _summaryItem(
              Icons.event, t('तारीख', 'Date'), _dateText(_dates[_day])),
          const SizedBox(height: 10),
          _summaryItem(Icons.schedule, t('समय', 'Time'), _slots[_slot]),
          const SizedBox(height: 10),
          _summaryItem(Icons.apartment, t('प्रॉपर्टी', 'Property'), l.title),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.info, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t('कमरा देखने के बाद ही आप बुकिंग की पुष्टि करेंगे।\nइससे पहले कोई भुगतान नहीं करना होगा।',
                        'You will confirm the booking only after seeing the room.\nNo payment is needed before that.'),
                    style:
                        TextStyle(fontSize: 12, color: AppColors.text),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _confirm,
              icon: const Icon(Icons.event_available, size: 20),
              label: Text(t('बुकिंग कन्फर्म करें', 'Confirm booking'),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
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

  void _confirm() {
    final l = widget.listing;
    demoNotifications.insert(
      0,
      NotifItem(
        kind: NotifKind.booking,
        title: t('बुकिंग अनुरोध भेजा गया', 'Booking request sent'),
        body: t('${l.title} देखने का आपका अनुरोध मकान मालिक को भेज दिया गया है।',
            'Your request to view ${l.title} has been sent to the owner.'),
        extra: '${_dateText(_dates[_day])}, ${_slots[_slot].split(' – ').first}',
        extraIcon: Icons.event,
        time: t('अभी', 'Just now'),
        unread: true,
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => BookingSuccessScreen(listing: l),
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
            _topBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    _steps(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          _listingMiniCard(widget.listing),
                          const SizedBox(height: 12),
                          _section(
                            icon: Icons.event,
                            title: t('कमरा देखने की तारीख चुनें',
                                'Choose a date to see the room'),
                            sub: t(
                                'कृपया वह दिन चुनें जब आप कमरे को देखने के लिए आ सकते हैं।',
                                'Please choose the day you can come to see the room.'),
                            child: _dateRow(),
                          ),
                          _section(
                            icon: Icons.schedule,
                            title: t('समय चुनें', 'Choose a time'),
                            sub: t('आप किस समय पर कमरे को देखना चाहेंगे?',
                                'At what time would you like to see the room?'),
                            child: _slotWrap(),
                          ),
                          _summary(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingSuccessScreen extends StatelessWidget {
  final Listing listing;
  const BookingSuccessScreen({super.key, required this.listing});

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12.5, height: 1.35, color: AppColors.text)),
          ),
        ],
      ),
    );
  }

  Widget _box({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = listing;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Column(
          children: [
            _topBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 20),
                child: Column(
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: AppColors.tint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.home_work,
                          size: 56, color: AppColors.primary),
                    ),
                    const SizedBox(height: 14),
                    Text(t('बधाई हो!', 'Congratulations!'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark)),
                    const SizedBox(height: 4),
                    Text(
                        t('आपका विज़िट अनुरोध भेज दिया गया है!',
                            'Your visit request has been sent!'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                    const SizedBox(height: 10),
                    Text(
                      t('अब आप सीधे मकान मालिक से बात कर सकते हैं। कृपया उनसे संपर्क करें और कमरे की आगे की प्रक्रिया पूरी करें।',
                          'You can now talk to the owner directly. Please contact them and complete the next steps for the room.'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14, height: 1.4, color: AppColors.text),
                    ),
                    const SizedBox(height: 16),
                    _box(
                      color: AppColors.tintLight,
                      child: Row(
                        children: [
                          Icon(Icons.shield,
                              size: 34, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    t('RoomMitra पर आपको सुरक्षित और भरोसेमंद लिस्टिंग मिलती है।',
                                        'On RoomMitra you get safe and trusted listings.'),
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text)),
                                const SizedBox(height: 2),
                                Text(
                                    t('कृपया बातचीत और लेन-देन हमेशा सीधे मकान मालिक से ही करें।',
                                        'Please always talk and deal directly with the owner.'),
                                    style: TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _listingMiniCard(l, showVerified: false),
                    const SizedBox(height: 12),
                    _box(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t('मकान मालिक की जानकारी', 'Owner details'),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text)),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  color: AppColors.tint,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.person,
                                    size: 36, color: AppColors.primary),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('राजेश वर्मा',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.text)),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.tint,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.verified,
                                              size: 14,
                                              color: AppColors.primary),
                                          const SizedBox(width: 4),
                                          Text(
                                              t('वेरिफाइड मालिक',
                                                  'Verified owner'),
                                              style: TextStyle(
                                                  fontSize: 11.5,
                                                  color: AppColors.text)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            size: 15,
                                            color: AppColors.primary),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(l.area,
                                              style: TextStyle(
                                                  fontSize: 12.5,
                                                  color: AppColors.text)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 46,
                                  child: ElevatedButton.icon(
                                    onPressed: () => contactOwner(context, l,
                                        whatsapp: false),
                                    icon: const Icon(Icons.phone, size: 18),
                                    label: Text(t('कॉल करें', 'Call'),
                                        style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  height: 46,
                                  child: ElevatedButton.icon(
                                    onPressed: () => contactOwner(context, l,
                                        whatsapp: true),
                                    icon: const Icon(Icons.chat, size: 18),
                                    label: const Text('WhatsApp',
                                        style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _box(
                      color: AppColors.tintLight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info,
                                  size: 22, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(t('कुछ जरूरी बातें', 'Some important points'),
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.text)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _bullet(t(
                              'मकान मालिक से बात करने से पहले कमरे की सभी जानकारी अच्छी तरह से जांच लें।',
                              'Before talking to the owner, check all the room details carefully.')),
                          _bullet(t(
                              'किराया और सिक्योरिटी डिपॉज़िट सीधे मकान मालिक को ही दें।',
                              'Pay rent and security deposit directly to the owner only.')),
                          _bullet(t(
                              'किसी भी तरह की धोखाधड़ी से बचने के लिए सतर्क रहें।',
                              'Stay alert to avoid any kind of fraud.')),
                        ],
                      ),
                    ),
                    ListenableBuilder(
                      listenable: appState,
                      builder: (context, _) {
                        final fav = appState.isFav(l.id);
                        return Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: OutlinedButton.icon(
                                  onPressed: () => appState.toggleFavorite(l.id),
                                  icon: Icon(
                                      fav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 20),
                                  label: Text(
                                      fav
                                          ? t('पसंदीदा में सेव है',
                                              'Saved to favorites')
                                          : t('पसंदीदा में सेव करें',
                                              'Save to favorites'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: BorderSide(
                                        color: AppColors.primary),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.of(context)
                                      .popUntil((r) => r.isFirst),
                                  icon: const Icon(Icons.home, size: 20),
                                  label: Text(t('होम पर जाएं', 'Go to Home'),
                                      style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
