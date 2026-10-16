import 'package:flutter/material.dart';
import 'data.dart';
import 'detail_screen.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'theme.dart';

class _TypeChip {
  final String label;
  final IconData icon;
  const _TypeChip(this.label, this.icon);
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryCtrl = TextEditingController();
  String _type = 'सभी';
  Filters _filters = Filters();
  int _sort = 0;
  bool _grid = false;

  static const List<_TypeChip> _types = [
    _TypeChip('सभी', Icons.bed),
    _TypeChip('PG', Icons.person_outline),
    _TypeChip('1RK', Icons.home_outlined),
    _TypeChip('1BHK', Icons.home_outlined),
    _TypeChip('2BHK', Icons.home_outlined),
    _TypeChip('3BHK+', Icons.home_outlined),
  ];

  static const List<String> _sortLabels = [
    'किराया (कम से ज्यादा)',
    'किराया (ज्यादा से कम)',
    'नए पहले',
  ];

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  List<Listing> _resultsWith(Filters f) {
    final q = _queryCtrl.text.trim().toLowerCase();
    final list = sampleListings.where((l) {
      if (l.city != appState.city) return false;
      if (_type != 'सभी' && l.type != _type) return false;
      if (!f.matches(l)) return false;
      if (q.isNotEmpty) {
        final hay = '${l.title} ${l.area} ${l.desc}'.toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();
    if (_sort == 0) {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sort == 1) {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else {
      list.sort((a, b) => b.order.compareTo(a.order));
    }
    return list;
  }

  Future<void> _openFilter() async {
    final res = await Navigator.of(context).push<Filters>(
      MaterialPageRoute<Filters>(
        builder: (_) => FilterScreen(
          initial: _filters.copy(),
          countFor: (f) => _resultsWith(f).length,
        ),
      ),
    );
    if (res != null && mounted) {
      setState(() => _filters = res);
    }
  }

  void _openDetail(Listing l) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(listing: l),
      ),
    );
  }

  void _resetAll() {
    setState(() {
      _filters = Filters();
      _type = 'सभी';
      _queryCtrl.clear();
    });
  }

  BoxDecoration _cardDeco() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
      boxShadow: const [
        BoxShadow(
            color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2)),
      ],
    );
  }

  Widget _cityPicker() {
    return PopupMenuButton<String>(
      onSelected: appState.setCity,
      itemBuilder: (_) => allCities
          .map((c) => PopupMenuItem<String>(
              value: c, child: Text(cityHindi[c] ?? c)))
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 20, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              cityHindi[appState.city] ?? appState.city,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text),
            ),
            const Icon(Icons.keyboard_arrow_down,
                size: 20, color: AppColors.text),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    final cityName = cityHindi[appState.city] ?? appState.city;
    return Container(
      height: 54,
      padding: const EdgeInsets.only(left: 14, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border, width: 1.3),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.primary, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _queryCtrl,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 15, color: AppColors.text),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: '$cityName में कमरा खोजें',
                hintStyle:
                    const TextStyle(fontSize: 15, color: AppColors.muted),
              ),
            ),
          ),
          if (_queryCtrl.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _queryCtrl.clear();
                setState(() {});
              },
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close, size: 20, color: AppColors.muted),
              ),
            ),
          Container(
            width: 1,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: AppColors.border,
          ),
          _cityPicker(),
        ],
      ),
    );
  }

  Widget _typeChips() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final t = _types[i];
          final sel = _type == t.label;
          return GestureDetector(
            onTap: () => setState(() => _type = t.label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.tint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(t.icon,
                      size: 20, color: sel ? Colors.white : AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    t.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _pill(IconData icon, String label,
      {bool arrow = false, bool active = false}) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: active ? AppColors.tint : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: active ? AppColors.primary : AppColors.border, width: 1.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text),
          ),
          if (arrow) ...[
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                size: 20, color: AppColors.text),
          ],
        ],
      ),
    );
  }

  Widget _controls() {
    final n = _filters.activeCount;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        GestureDetector(
          onTap: _openFilter,
          child: _pill(Icons.tune, n > 0 ? 'फिल्टर ($n)' : 'फिल्टर',
              arrow: true, active: n > 0),
        ),
        PopupMenuButton<int>(
          onSelected: (v) => setState(() => _sort = v),
          itemBuilder: (_) => List.generate(
            _sortLabels.length,
            (i) => PopupMenuItem<int>(value: i, child: Text(_sortLabels[i])),
          ),
          child: _pill(Icons.swap_vert, _sortLabels[_sort], arrow: true),
        ),
        GestureDetector(
          onTap: () => showMsg(context, 'मैप वाला हिस्सा बाद में जुड़ेगा'),
          child: _pill(Icons.map_outlined, 'मैप पर देखें'),
        ),
      ],
    );
  }

  Widget _toggleBtn(IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 34,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            size: 20, color: selected ? Colors.white : AppColors.primary),
      ),
    );
  }

  Widget _countRow(int count) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'कुल $count परिणाम',
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.text),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.tint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _toggleBtn(Icons.grid_view, _grid, () => setState(() => _grid = true)),
              _toggleBtn(
                  Icons.view_list, !_grid, () => setState(() => _grid = false)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _photo(Listing l, double w, double h) {
    final fav = appState.isFav(l.id);
    return SizedBox(
      width: w,
      height: h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(l.image, fit: BoxFit.cover),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => appState.toggleFavorite(l.id),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0x66000000),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    fav ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: fav ? const Color(0xFFFF6B6B) : Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x99000000),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo_camera,
                        size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '1/${l.photos}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
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

  Widget _priceChip(int price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '₹${inr(price)}/माह',
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.primary),
      ),
    );
  }

  Widget _stat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
      ],
    );
  }

  Widget _contactRow(Listing l) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () => contactOwner(context, l, whatsapp: false),
              icon: const Icon(Icons.call, size: 18),
              label: const Text('कॉल करें'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                textStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 42,
            child: OutlinedButton.icon(
              onPressed: () => contactOwner(context, l, whatsapp: true),
              icon: const Icon(Icons.chat, size: 18),
              label: const Text('WhatsApp करें'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                padding: EdgeInsets.zero,
                textStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _listCard(Listing l) {
    return GestureDetector(
      onTap: () => _openDetail(l),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: _cardDeco(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _photo(l, 124, 152),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 15, color: AppColors.primary),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              l.area,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12.5, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _priceChip(l.price),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          _stat(Icons.home_outlined, l.typeLabel),
                          _stat(Icons.bathtub_outlined, l.bathLabel),
                          _stat(Icons.square_foot, '${l.sqft} sq ft'),
                          _stat(Icons.apartment, l.floor),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              l.desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12.5, height: 1.35, color: AppColors.muted),
            ),
            const SizedBox(height: 10),
            _contactRow(l),
          ],
        ),
      ),
    );
  }

  Widget _gridCard(Listing l) {
    return GestureDetector(
      onTap: () => _openDetail(l),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: _cardDeco(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _photo(l, double.infinity, 116),
            const SizedBox(height: 8),
            Text(
              l.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    l.area,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _priceChip(l.price),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () =>
                          contactOwner(context, l, whatsapp: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Icon(Icons.call, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () =>
                          contactOwner(context, l, whatsapp: true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                            color: AppColors.primary, width: 1.2),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Icon(Icons.chat, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestRow(String text, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            const Icon(Icons.check_circle,
                size: 22, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                    fontSize: 14.5, height: 1.3, color: AppColors.text),
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        children: [
          Image.asset(
            'assets/empty_art.png',
            width: 270,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          const Text(
            'कोई कमरा नहीं मिला',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          const Text(
            'आपके द्वारा चुनी गई जानकारी के अनुसार,\nकोई भी कमरा उपलब्ध नहीं है।',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15, height: 1.5, color: AppColors.text),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
            decoration: BoxDecoration(
              color: AppColors.tintLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 24, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'आप ये भी कोशिश कर सकते हैं:',
                        style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _suggestRow('किराया रेंज थोड़ा बदलें', _openFilter),
                _suggestRow('किसी दूसरे इलाके को चुनें', _openFilter),
                _suggestRow('फिल्टर कम करके फिर से खोजें', _resetAll),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 260,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _resetAll,
              icon: const Icon(Icons.search, size: 24),
              label: const Text('फिर से खोजें'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final results = _resultsWith(_filters);
        return Scaffold(
          backgroundColor: const Color(0xFFF7FCF9),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _searchBar(),
                        const SizedBox(height: 14),
                        _typeChips(),
                        const SizedBox(height: 12),
                        _controls(),
                        const SizedBox(height: 16),
                        _countRow(results.length),
                      ],
                    ),
                  ),
                ),
              ),
              if (results.isEmpty)
                SliverToBoxAdapter(child: _empty())
              else if (_grid)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _gridCard(results[i]),
                      childCount: results.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: 300,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _listCard(results[i]),
                      childCount: results.length,
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
  static const List<MapEntry<String, String>> _kinds = [
    MapEntry('PG', 'PG'),
    MapEntry('फ्लैट', 'फ्लैट'),
    MapEntry('रूम', 'रूम'),
    MapEntry('हॉस्टल', 'बॉयज/गर्ल्स हॉस्टल'),
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
        Text(
          text,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.text),
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
            onPressed: () => showMsg(context, 'पसंदीदा कमरे नीचे के "पसंदीदा" टैब में दिखेंगे'),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'फ़िल्टर',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
                Text(
                  'अपनी जरूरत के अनुसार कमरे को फ़िल्टर करें',
                  style: TextStyle(fontSize: 12, color: AppColors.text),
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
            label: const Text('सभी फ़िल्टर\nहटाएं',
                style: TextStyle(fontSize: 11.5, height: 1.2)),
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
          _title(Icons.currency_rupee, 'किराया रेंज (प्रति माह)'),
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
          _title(Icons.location_on, 'स्थान'),
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
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'कॉलोनी, एरिया या इलाके का नाम',
                      hintStyle:
                          TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _title(Icons.my_location, 'दूरी'),
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
                        value: d, child: Text('$d km तक')))
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
          _title(Icons.bed, 'कमरों की संख्या'),
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
          _title(Icons.home, 'प्रकार'),
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
          _title(Icons.star, 'सुविधाएँ (एक या अधिक चुनें)'),
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
          _title(Icons.settings, 'अन्य विकल्प'),
          const SizedBox(height: 6),
          _switchRow('केवल सत्यापित प्रॉपर्टी', _f.verifiedOnly,
              (v) => setState(() => _f.verifiedOnly = v)),
          _switchRow('सुरक्षित महिला प्रॉपर्टी', _f.safeWomen,
              (v) => setState(() => _f.safeWomen = v)),
          _switchRow('केवल मालिक से सीधे', _f.directOwner,
              (v) => setState(() => _f.directOwner = v)),
          _switchRow('लड़कियों के लिए', _f.girlsOnly,
              (v) => setState(() => _f.girlsOnly = v)),
          _switchRow('तुरंत उपलब्ध', _f.immediate,
              (v) => setState(() => _f.immediate = v)),
          _switchRow('कमर्शियल प्रॉपर्टी', _f.commercial,
              (v) => setState(() => _f.commercial = v)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                label: Text('फ़िल्टर लागू करें ($count परिणाम)'),
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
}
