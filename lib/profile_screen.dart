import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_review_screen.dart';
import 'data.dart';
import 'help_screen.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'invite_screen.dart';
import 'login_screen.dart';
import 'messages_screen.dart';
import 'my_listings_screen.dart';
import 'otp_service.dart';
import 'strings.dart';
import 'terms_screen.dart';
import 'theme.dart';

// एक जैसा डिज़ाइन (आइकॉन/स्पेसिंग) हर जगह इन्हीं से चलेगा
const double _kIconSmall = 16; // हेडर कार्ड की लाइनों के आइकॉन
const double _kIconMenu = 24; // मेनू/सेटिंग की पंक्तियों के आइकॉन
const double _kIconBox = 46; // मेनू आइकॉन का गोल डिब्बा
const double _kGap = 12; // कार्ड्स के बीच की दूरी
const double _kRadius = 16; // कार्ड्स के कोने

class _MenuItem {
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.title, this.sub, this.onTap);
}

/// नोटिफिकेशन के स्विच (अभी सिर्फ ऐप चलने तक याद रहते हैं)
final Map<String, bool> notifPrefs = <String, bool>{
  'messages': true,
  'rooms': true,
  'bookings': true,
  'safety': true,
  'offers': false,
};

class ProfileScreen extends StatefulWidget {
  /// मेरी लिस्टिंग से "नई लिस्टिंग जोड़ें" दबाने पर चलेगा
  final VoidCallback onAdd;
  const ProfileScreen({super.key, required this.onAdd});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// एडमिन पैनल सिर्फ तब दिखेगा जब सर्वर का is_admin() true दे
  bool _isAdmin = false;
  String _name = '';
  String _avatarUrl = '';
  bool _avatarBusy = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _loadName();
  }

  Future<void> _loadName() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final row = await Supabase.instance.client
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();
      var n = (row?['full_name'] ?? '').toString().trim();
      if (n.isEmpty) {
        n = (user.userMetadata?['full_name'] ??
                user.userMetadata?['name'] ??
                '')
            .toString()
            .trim();
      }
      if (!mounted) return;
      setState(() => _name = n);
    } catch (_) {}
  }

  void _readAvatar() {
    final u = Supabase.instance.client.auth.currentUser;
    final m = u?.userMetadata;
    final url = (m?['avatar_url'] ?? m?['picture'] ?? '').toString();
    if (url != _avatarUrl) _avatarUrl = url;
  }

  Future<void> _pickAvatar() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      showMsg(context, t('पहले लॉगिन करें', 'Please log in first'));
      return;
    }
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: Text(t('गैलरी से चुनें', 'Choose from gallery')),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.photo_camera, color: AppColors.primary),
              title: Text(t('कैमरे से खींचें', 'Take a photo')),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final file = await ImagePicker().pickImage(
          source: source, maxWidth: 600, maxHeight: 600, imageQuality: 80);
      if (file == null || !mounted) return;
      setState(() => _avatarBusy = true);
      final bytes = await file.readAsBytes();
      final path =
          '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storage = Supabase.instance.client.storage.from('room-photos');
      await storage.uploadBinary(path, bytes,
          fileOptions:
              const FileOptions(contentType: 'image/jpeg', upsert: false));
      final url = storage.getPublicUrl(path);
      await Supabase.instance.client.auth
          .updateUser(UserAttributes(data: {'avatar_url': url}));
      if (!mounted) return;
      setState(() {
        _avatarUrl = url;
        _avatarBusy = false;
      });
      showMsg(context, t('प्रोफाइल फोटो बदल गई', 'Profile photo updated'));
    } catch (_) {
      if (!mounted) return;
      setState(() => _avatarBusy = false);
      showMsg(
          context,
          t('फोटो नहीं लग सकी, फिर कोशिश करें',
              'Could not set the photo, please try again'));
    }
  }

  Future<void> _editProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      showMsg(context, t('पहले लॉगिन करें', 'Please log in first'));
      return;
    }
    final ctrl = TextEditingController(text: _name);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('प्रोफाइल अपडेट करें', 'Update profile'),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text)),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              maxLength: 60,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: t('आपका नाम', 'Your name'),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(t('सेव करें', 'Save'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
    final newName = ctrl.text.trim();
    ctrl.dispose();
    if (saved != true || newName.isEmpty || !mounted) return;
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'full_name': newName}).eq('id', user.id);
      if (!mounted) return;
      setState(() => _name = newName);
      showMsg(context, t('प्रोफाइल सेव हो गई', 'Profile saved'));
    } catch (_) {
      if (!mounted) return;
      showMsg(context,
          t('सेव नहीं हो सका, फिर कोशिश करें', 'Could not save, try again'));
    }
  }

  Future<void> _checkAdmin() async {
    try {
      final res = await Supabase.instance.client.rpc('is_admin');
      final ok = res == true;
      if (!mounted) return;
      if (ok != _isAdmin) setState(() => _isAdmin = ok);
    } catch (_) {
      // गड़बड़ हो तो एडमिन पैनल छिपा ही रहेगा
      if (!mounted) return;
      if (_isAdmin) setState(() => _isAdmin = false);
    }
  }

  /// लॉगिन किए हुए फोन के सिर्फ अंक (जैसे 919805793737)
  String _digits() {
    try {
      final raw = Supabase.instance.client.auth.currentUser?.phone ?? '';
      return raw.replaceAll(RegExp(r'\D'), '');
    } catch (_) {
      return '';
    }
  }

  /// लॉगिन खाते का ईमेल (जैसे Google लॉगिन से), नहीं हो तो खाली
  String _email() {
    try {
      return (Supabase.instance.client.auth.currentUser?.email ?? '').trim();
    } catch (_) {
      return '';
    }
  }

  String _phoneFull() {
    final d = _digits();
    if (d.length == 12 && d.startsWith('91')) {
      return '+91 ${d.substring(2, 7)} ${d.substring(7)}';
    }
    return d.isEmpty ? '—' : '+$d';
  }

  String _phoneShort() {
    final d = _digits();
    if (d.length == 12 && d.startsWith('91')) {
      return '${d.substring(2, 7)} ${d.substring(7)}';
    }
    return d.isEmpty ? '—' : d;
  }

  Widget _langToggle() {
    return InkWell(
      onTap: AppLang.toggle,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white70, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 17, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              AppLang.isHindi ? 'English' : 'हिंदी',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding:
          EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 12),
      child: Row(
        children: [
          const RoomMitraLogo(),
          const Spacer(),
          _langToggle(),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => AppTheme.setDark(!AppTheme.isDark),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppTheme.isDark ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// प्रोफाइल फोटो: फोटो हो तो वही, वरना हरा गोला। दबाने पर नई फोटो चुन सकते हैं।
  Widget _avatarPlaceholder() {
    _readAvatar();
    final fallback = Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 42),
    );
    return GestureDetector(
      onTap: _avatarBusy ? null : _pickAvatar,
      child: SizedBox(
        width: 76,
        height: 76,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: _avatarUrl.isEmpty
                    ? fallback
                    : Image.network(
                        _avatarUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => fallback,
                      ),
              ),
            ),
            if (_avatarBusy)
              const Positioned.fill(
                child: Center(
                  child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(strokeWidth: 3)),
                ),
              ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.photo_camera,
                    color: Colors.white, size: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emailLine(BuildContext context) {
    final email = _email();
    if (email.isNotEmpty) {
      return Row(
        children: [
          Icon(Icons.email, size: _kIconSmall, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: AppColors.text),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _headerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(_kRadius),
      ),
      child: Row(
        children: [
          _avatarPlaceholder(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _name.isEmpty ? t('उपयोगकर्ता', 'User') : _name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _editProfile,
                      child: Icon(Icons.edit,
                          color: AppColors.primary, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.phone,
                        size: _kIconSmall, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(_phoneFull(),
                        style: TextStyle(
                            fontSize: 13, color: AppColors.text)),
                  ],
                ),
                const SizedBox(height: 4),
                _emailLine(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    Widget cell(IconData icon, String k, String v) {
      return Expanded(
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(k,
                style: TextStyle(fontSize: 11, color: AppColors.muted)),
            const SizedBox(height: 2),
            Text(
              v,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text),
            ),
          ],
        ),
      );
    }

    final cityText = AppLang.isHindi
        ? (cityHindi[appState.city] ?? '')
        : '${appState.city}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_kRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t('मेरी जानकारी', 'My information'),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: _kGap),
          Row(
            children: [
              cell(Icons.person, t('पूरा नाम', 'Full name'),
                  t('उपयोगकर्ता', 'User')),
              cell(Icons.phone, t('मोबाइल', 'Mobile'), _phoneShort()),
              cell(Icons.location_on, t('शहर', 'City'), cityText),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuRow(_MenuItem m, {bool last = false}) {
    return InkWell(
      onTap: m.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Container(
              width: _kIconBox,
              height: _kIconBox,
              decoration: BoxDecoration(
                color: AppColors.tint,
                shape: BoxShape.circle,
              ),
              child: Icon(m.icon, color: AppColors.primary, size: _kIconMenu),
            ),
            const SizedBox(width: _kGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.title,
                    style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    m.sub,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.text),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(t('लॉगआउट', 'Logout')),
        content: Text(
          t(
            'क्या आप अपने खाते से बाहर जाना चाहते हैं?',
            'Do you want to log out of your account?',
          ),
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t('रद्द करें', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t('लॉगआउट', 'Logout')),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await OtpService.signOut();
    } catch (_) {
      // साइन-आउट में नेटवर्क की दिक्कत हो तो भी आगे बढ़ो
    }

    if (!context.mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, lang, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final items = <_MenuItem>[
      _MenuItem(
        Icons.home_work,
        t('मेरी लिस्टिंग', 'My listings'),
        t('मालिक डैशबोर्ड: बदलें, हटाएं, सक्रिय/निष्क्रिय करें',
            'Owner dashboard: edit, delete, activate/deactivate'),
        () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MyListingsScreen(onAdd: widget.onAdd),
            ),
          );
        },
      ),
      if (_isAdmin)
        _MenuItem(
          Icons.admin_panel_settings,
          t('एडमिन पैनल', 'Admin panel'),
          t('सिर्फ एडमिन के लिए', 'For admins only'),
          () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AdminReviewScreen(),
              ),
            );
          },
        ),
      _MenuItem(
        Icons.manage_accounts,
        t('प्रोफाइल अपडेट करें', 'Update profile'),
        t('अपना नाम बदलें, फोटो बदलने के लिए फोटो दबाएँ', 'Change your name; tap the photo to change it'),
        _editProfile,
      ),
      _MenuItem(
        Icons.group_add,
        t('दोस्तों को बुलाएँ', 'Invite friends'),
        t('RoomMitra का लिंक WhatsApp पर शेयर करें',
            'Share the RoomMitra link on WhatsApp'),
        () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const InviteScreen(),
            ),
          );
        },
      ),
      _MenuItem(
        Icons.help,
        t('सहायता और सपोर्ट', 'Help & support'),
        t('FAQ, हेल्प सेंटर और संपर्क करें',
            'FAQ, help center and contact'),
        () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const HelpScreen(),
            ),
          );
        },
      ),
      _MenuItem(
        Icons.description,
        t('नियम और शर्तें', 'Terms & conditions'),
        t('ऐप की शर्तें और गोपनीयता नीति',
            'App terms and privacy policy'),
        () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const TermsScreen(),
            ),
          );
        },
      ),
      _MenuItem(
        Icons.logout,
        t('लॉगआउट', 'Logout'),
        t('अपने खाते से बाहर जाएँ', 'Sign out of your account'),
        () => _logout(context),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _topBar(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              children: [
                _headerCard(context),
                const SizedBox(height: _kGap),
                _infoCard(),
                const SizedBox(height: _kGap),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(_kRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        _menuRow(items[i], last: i == items.length - 1),
                    ],
                  ),
                ),
                const SizedBox(height: _kGap),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.tint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.favorite,
                          color: AppColors.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t('RoomMitra का उपयोग करने के लिए धन्यवाद!',
                              'Thank you for using RoomMitra!'),
                          style: TextStyle(
                              fontSize: 12.5, color: AppColors.text),
                        ),
                      ),
                      Text('v1.0.0',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// नोटिफिकेशन सेटिंग
// ---------------------------------------------------------------------------

class _PrefItem {
  final String key;
  final IconData icon;
  final String title;
  final String sub;
  const _PrefItem(this.key, this.icon, this.title, this.sub);
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  List<_PrefItem> get _items => [
        _PrefItem('messages', Icons.chat_bubble, t('मैसेज', 'Messages'),
            t('किसी का नया संदेश आने पर', 'When you get a new message')),
        _PrefItem('rooms', Icons.home, t('नए कमरे', 'New rooms'),
            t('आपके शहर में नया कमरा जुड़ने पर',
                'When a new room is added in your city')),
        _PrefItem('bookings', Icons.calendar_month, t('बुकिंग', 'Bookings'),
            t('विज़िट अनुरोध और उसके जवाब पर',
                'On visit requests and their replies')),
        _PrefItem('safety', Icons.shield, t('सुरक्षा अलर्ट', 'Safety alerts'),
            t('रिपोर्ट और सुरक्षा की ज़रूरी सूचना',
                'Important report and safety notices')),
        _PrefItem(
            'offers',
            Icons.campaign,
            t('ऑफर और ऐप अपडेट', 'Offers and app updates'),
            t('नई सुविधाओं और खबरों की जानकारी',
                'News about new features')),
      ];

  Widget _topBar() {
    return Container(
      decoration: BoxDecoration(
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
          const Icon(Icons.notifications, color: Colors.white, size: 26),
        ],
      ),
    );
  }

  Widget _row(_PrefItem p, {bool last = false}) {
    final on = notifPrefs[p.key] ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: _kIconBox,
            height: _kIconBox,
            decoration: BoxDecoration(
              color: AppColors.tint,
              shape: BoxShape.circle,
            ),
            child: Icon(p.icon, color: AppColors.primary, size: _kIconMenu),
          ),
          const SizedBox(width: _kGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
                const SizedBox(height: 2),
                Text(
                  p.sub,
                  style:
                      TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Switch(
            value: on,
            onChanged: (v) => setState(() => notifPrefs[p.key] = v),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, lang, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final items = _items;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _topBar(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                  16, 14, 16, 16 + MediaQuery.of(context).padding.bottom),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.tint,
                    borderRadius: BorderRadius.circular(_kRadius),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.tune, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: _kGap),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('नोटिफिकेशन सेटिंग', 'Notification settings'),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t('चुनें कि आपको किस बारे में सूचना चाहिए।',
                                  'Choose what you want to be notified about.'),
                              style: TextStyle(
                                  fontSize: 12.5, color: AppColors.text),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: _kGap),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(_kRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        _row(items[i], last: i == items.length - 1),
                    ],
                  ),
                ),
                const SizedBox(height: _kGap),
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
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t(
                            'यह अभी डेमो है। असली नोटिफिकेशन Supabase जुड़ने के बाद आपके फोन पर आएँगे और ये स्विच तभी असर करेंगे।',
                            'This is a demo for now. Real notifications will arrive on your phone once Supabase is connected, and only then will these switches take effect.',
                          ),
                          style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: AppColors.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
