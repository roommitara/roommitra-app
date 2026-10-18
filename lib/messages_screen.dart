import 'package:flutter/material.dart';
import 'data.dart';
import 'detail_screen.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'strings.dart';
import 'theme.dart';

class ChatMsg {
  final String text;
  final bool mine;
  final String time;
  final bool location;
  const ChatMsg(this.text, this.mine, this.time, {this.location = false});
}

class Conversation {
  final String id;
  final String name;
  final String role; // मकान मालिक / किरायेदार
  final String listingId;
  final List<ChatMsg> msgs;
  int unread;
  String status; // inbox, archive, blocked

  Conversation({
    required this.id,
    required this.name,
    required this.role,
    required this.listingId,
    required this.msgs,
    this.unread = 0,
    this.status = 'inbox',
  });

  ChatMsg get last => msgs.last;

  String get roleLabel {
    if (role == 'मकान मालिक' || role == 'owner') {
      return t('मकान मालिक', 'Owner');
    }
    return t('किरायेदार', 'Tenant');
  }
}

/// डेमो चैट (असली चैट Supabase जुड़ने पर आएगी)
final ValueNotifier<List<Conversation>> conversations =
    ValueNotifier<List<Conversation>>([
  Conversation(
    id: 'c1',
    name: 'राहुल शर्मा',
    role: 'मकान मालिक',
    listingId: 'n1',
    unread: 2,
    msgs: [
      ChatMsg(
          'नमस्ते! आपने जो 1BHK रूम के बारे में पूछा था, वो अभी भी उपलब्ध है। अगर आपको देखना हो तो कल शाम 5 बजे आ सकते हैं।',
          false,
          '16:12'),
      ChatMsg('जी बिल्कुल, मैं कल शाम 5 बजे आ जाऊँगा। कृपया लोकेशन भी भेज दीजिए।',
          true, '16:15'),
      ChatMsg('Rani Tal, Nahan', false, '16:16', location: true),
      ChatMsg('ठीक है, धन्यवाद! क्या इसमें WiFi भी है?', true, '16:18'),
      ChatMsg('हाँ, WiFi और पार्किंग दोनों हैं।', false, '16:20'),
    ],
  ),
  Conversation(
    id: 'c2',
    name: 'अमित यादव',
    role: 'किरायेदार',
    listingId: 'n2',
    unread: 1,
    msgs: [
      ChatMsg('नमस्ते, PG में अभी जगह खाली है?', false, '08:40'),
      ChatMsg('जी हाँ, एक बेड खाली है।', true, '08:44'),
      ChatMsg('क्या यह कमरा लड़कों के लिए ही है?', false, '08:47'),
    ],
  ),
  Conversation(
    id: 'c3',
    name: 'प्रियंका सिंह',
    role: 'किरायेदार',
    listingId: 'n3',
    msgs: [
      ChatMsg('मैं कल देखने के लिए आ सकती हूँ। टाइम क्या रहेगा?', false, '18:32'),
    ],
  ),
  Conversation(
    id: 'c4',
    name: 'संदीप कुमार',
    role: 'मकान मालिक',
    listingId: 'p1',
    msgs: [
      ChatMsg('सभी सुविधाएँ मौजूद हैं। अगर आप इंटरेस्टेड हैं तो बताएँ।', false,
          '16:12'),
    ],
  ),
  Conversation(
    id: 'c5',
    name: 'पूजा वर्मा',
    role: 'किरायेदार',
    listingId: 'n1',
    status: 'archive',
    msgs: [
      ChatMsg('क्या इसमें वाई-फाई और पानी की सुविधा है?', false, '13:45'),
      ChatMsg('जी हाँ, दोनों हैं।', true, '13:50'),
    ],
  ),
]);

void _refreshConv() {
  conversations.value = List<Conversation>.of(conversations.value);
}

String _nowTime() {
  final n = DateTime.now();
  final h = n.hour.toString().padLeft(2, '0');
  final m = n.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

Listing _listingOf(String id) {
  return sampleListings.firstWhere(
    (l) => l.id == id,
    orElse: () => sampleListings.first,
  );
}

Widget _greenBar(BuildContext context) {
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
        const Icon(Icons.chat_bubble, color: Colors.white, size: 24),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// संदेश लिस्ट
// ---------------------------------------------------------------------------

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  static const List<String> _tabs = ['inbox', 'archive', 'blocked'];
  int _tab = 0;
  final TextEditingController _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _open(Conversation c) {
    c.unread = 0;
    _refreshConv();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ChatScreen(conv: c)),
    );
  }

  Widget _tabBtn(int i, IconData icon, String label, {int badge = 0}) {
    final sel = _tab == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = i),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: sel ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 20, color: sel ? Colors.white : AppColors.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
              if (badge > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: sel ? Colors.white : AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badge',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: sel ? AppColors.primary : Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabsRow(int unread) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _tabBtn(0, Icons.chat_bubble_outline, t('संदेश', 'Messages'),
              badge: unread),
          _tabBtn(1, Icons.archive_outlined, t('आर्काइव', 'Archive')),
          _tabBtn(2, Icons.block, t('ब्लॉक्ड', 'Blocked')),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.primary, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _q,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14.5, color: AppColors.text),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: t('किसी से चैट खोजें...', 'Search chats...'),
                hintStyle:
                    const TextStyle(fontSize: 14.5, color: AppColors.muted),
              ),
            ),
          ),
          if (_q.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _q.clear();
                setState(() {});
              },
              child: const Icon(Icons.close, size: 20, color: AppColors.muted),
            ),
        ],
      ),
    );
  }

  Widget _item(Conversation c) {
    final last = c.last;
    final unread = c.unread > 0;
    return GestureDetector(
      onTap: () => _open(c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.tint,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.person, color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.tint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          c.roleLabel,
                          style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    last.mine
                        ? '${t('आप', 'You')}: ${last.text}'
                        : (last.location
                            ? t('लोकेशन भेजी गई', 'Location shared')
                            : last.text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: unread ? FontWeight.w700 : FontWeight.w400,
                      color: unread ? AppColors.text : AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.done_all,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${t('आज', 'Today')} ${last.time}',
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (unread)
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${c.unread}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              )
            else
              const Icon(Icons.chevron_right, color: AppColors.text),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    final icons = [
      Icons.chat_bubble_outline,
      Icons.archive_outlined,
      Icons.block,
    ];
    final texts = [
      t('अभी कोई संदेश नहीं है', 'No messages yet'),
      t('आर्काइव खाली है', 'Archive is empty'),
      t('कोई ब्लॉक किया हुआ यूज़र नहीं है', 'No blocked users'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        children: [
          Icon(icons[_tab], size: 64, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(
            texts[_tab],
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.text),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF9),
      body: Column(
        children: [
          _greenBar(context),
          Expanded(
            child: ListenableBuilder(
              listenable: conversations,
              builder: (context, _) {
                final all = conversations.value;
                final unread = all
                    .where((c) => c.status == 'inbox')
                    .fold<int>(0, (s, c) => s + c.unread);
                final q = _q.text.trim().toLowerCase();
                final list = all.where((c) {
                  if (c.status != _tabs[_tab]) return false;
                  if (q.isEmpty) return true;
                  return c.name.toLowerCase().contains(q) ||
                      c.last.text.toLowerCase().contains(q);
                }).toList();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  children: [
                    _tabsRow(unread),
                    const SizedBox(height: 12),
                    _searchBox(),
                    const SizedBox(height: 12),
                    if (list.isEmpty) _empty() else ...list.map(_item),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// चैट स्क्रीन
// ---------------------------------------------------------------------------

class ChatScreen extends StatefulWidget {
  final Conversation conv;
  const ChatScreen({super.key, required this.conv});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  Conversation get c => widget.conv;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _toBottom());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toBottom() {
    if (_scroll.hasClients) {
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    }
  }

  void _send(String text, {bool location = false}) {
    final txt = text.trim();
    if (txt.isEmpty) return;
    setState(() {
      c.msgs.add(ChatMsg(txt, true, _nowTime(), location: location));
    });
    _refreshConv();
    _ctrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _toBottom());
  }

  void _onMenu(String v) {
    final messenger = ScaffoldMessenger.of(context);
    void toast(String msg) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }

    if (v == 'archive') {
      c.status = 'archive';
      _refreshConv();
      Navigator.of(context).pop();
      toast(t('चैट आर्काइव में चली गई', 'Chat moved to archive'));
    } else if (v == 'block') {
      c.status = 'blocked';
      _refreshConv();
      Navigator.of(context).pop();
      toast(t('${c.name} को ब्लॉक कर दिया गया', '${c.name} has been blocked'));
    } else if (v == 'restore') {
      setState(() => c.status = 'inbox');
      _refreshConv();
      toast(t('चैट इनबॉक्स में वापस आ गई', 'Chat moved back to inbox'));
    }
  }

  Widget _header() {
    final l = _listingOf(c.listingId);
    final items = <PopupMenuEntry<String>>[];
    if (c.status == 'inbox') {
      items.add(PopupMenuItem<String>(
          value: 'archive', child: Text(t('आर्काइव करें', 'Archive'))));
      items.add(PopupMenuItem<String>(
          value: 'block', child: Text(t('ब्लॉक करें', 'Block'))));
    } else if (c.status == 'archive') {
      items.add(PopupMenuItem<String>(
          value: 'restore',
          child: Text(t('इनबॉक्स में लाएं', 'Move to inbox'))));
      items.add(PopupMenuItem<String>(
          value: 'block', child: Text(t('ब्लॉक करें', 'Block'))));
    } else {
      items.add(PopupMenuItem<String>(
          value: 'restore', child: Text(t('अनब्लॉक करें', 'Unblock'))));
    }
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
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
                Text(
                  '${c.roleLabel} · ${l.typeLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFFD9F2E3)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => showMsg(
                context,
                t('कॉल की सुविधा Supabase जुड़ने पर आएगी। अभी कमरे की डिटेल से कॉल करें',
                    'Calling will come once Supabase is connected. For now, call from the room details')),
            icon: const Icon(Icons.call, color: Colors.white),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _onMenu,
            itemBuilder: (_) => items,
          ),
        ],
      ),
    );
  }

  Widget _listingCard() {
    final l = _listingOf(c.listingId);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child:
                Image.asset(l.image, width: 66, height: 56, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
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
                const SizedBox(height: 2),
                Text(
                  l.area,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${inr(l.price)}${t('/माह', '/month')}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DetailScreen(listing: l),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.tint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t('विवरण देखें', 'View details'),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  const Icon(Icons.chevron_right,
                      size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(ChatMsg m) {
    final mine = m.mine;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        decoration: BoxDecoration(
          color: mine ? const Color(0xFFDDF4E4) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(mine ? 14 : 4),
            bottomRight: Radius.circular(mine ? 4 : 14),
          ),
          border: mine ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (m.location)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${t('लोकेशन', 'Location')}: ${m.text}',
                      style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text),
                    ),
                  ),
                ],
              )
            else
              Text(
                m.text,
                style: const TextStyle(
                    fontSize: 14.5, height: 1.4, color: AppColors.text),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  m.time,
                  style:
                      const TextStyle(fontSize: 10.5, color: AppColors.muted),
                ),
                if (mine) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all,
                      size: 14, color: AppColors.primary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.tint,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputArea() {
    final bottom = MediaQuery.of(context).padding.bottom;
    if (c.status == 'blocked') {
      return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
        child: Row(
          children: [
            const Icon(Icons.block, color: AppColors.danger, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                t('आपने इस यूज़र को ब्लॉक किया है',
                    'You have blocked this user'),
                style:
                    const TextStyle(fontSize: 13.5, color: AppColors.text),
              ),
            ),
            TextButton(
              onPressed: () => _onMenu('restore'),
              child: Text(t('अनब्लॉक करें', 'Unblock')),
            ),
          ],
        ),
      );
    }
    final l = _listingOf(c.listingId);
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _quickBtn(Icons.location_on,
                    t('लोकेशन शेयर करें', 'Share location'),
                    () => _send(l.area, location: true)),
                _quickBtn(
                    Icons.call,
                    t('कॉल करें', 'Call'),
                    () => showMsg(
                        context,
                        t('कॉल करने के लिए कमरे की डिटेल स्क्रीन में "कॉल करें" दबाएँ',
                            'To call, tap "Call" on the room details screen'))),
                _quickBtn(
                    Icons.image,
                    t('फोटो भेजें', 'Send photo'),
                    () => showMsg(
                        context,
                        t('फोटो भेजना Supabase जुड़ने पर आएगा',
                            'Sending photos will come once Supabase is connected'))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3FAF6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    onSubmitted: (v) => _send(v),
                    textInputAction: TextInputAction.send,
                    style:
                        const TextStyle(fontSize: 14.5, color: AppColors.text),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: t('यहाँ संदेश लिखें...', 'Type a message...'),
                      hintStyle: const TextStyle(
                          fontSize: 14.5, color: AppColors.muted),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _send(_ctrl.text),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6F3),
      body: Column(
        children: [
          _header(),
          _listingCard(),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              children: c.msgs.map(_bubble).toList(),
            ),
          ),
          _inputArea(),
        ],
      ),
    );
  }
}
