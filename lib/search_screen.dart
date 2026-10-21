import 'package:flutter/material.dart';
import 'data.dart';
import 'detail_screen.dart';
import 'filter_screen.dart';
import 'strings.dart';
import 'theme.dart';

export 'filter_screen.dart';

class _TypeChip {
  /// यह असली वैल्यू है (फ़िल्टर इसी से मिलान करता है), दिखने वाला नाम अलग से बनता है
  final String key;
  final IconData icon;
  const _TypeChip(this.key, this.icon);

  String get label => key == 'सभी' ? t('सभी', 'All') : key;
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

  List<String> get _sortLabels => [
        t('किराया (कम से ज्यादा)', 'Rent (low to high)'),
        t('किराया (ज्यादा से कम)', 'Rent (high to low)'),
        t('नए पहले', 'Newest first'),
      ];

  @override
  void initState() {
    super.initState();
    if (!listingsStore.loaded) {
      listingsStore.load();
    }
    searchPreset.addListener(_applyPreset);
  }

  void _applyPreset() {
    final p = searchPreset.value;
    if (p == null || !mounted) return;
    setState(() {
      _filters = p.copy();
      _type = 'सभी';
      _queryCtrl.clear();
    });
    searchPreset.value = null;
  }

  @override
  void dispose() {
    searchPreset.removeListener(_applyPreset);
    _queryCtrl.dispose();
    super.dispose();
  }

  List<Listing> _resultsWith(Filters f) {
    final q = _queryCtrl.text.trim().toLowerCase();
    final list = listingsStore.items.where((l) {
      if (l.status != 'approved' || !l.isAvailable) return false;
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
              value: c, child: Text(cityName(c))))
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 20, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              cityName(appState.city),
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
    final city = cityName(appState.city);
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
                hintText: t('$city में कमरा खोजें', 'Search rooms in $city'),
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
          final chip = _types[i];
          final sel = _type == chip.key;
          return GestureDetector(
            onTap: () => setState(() => _type = chip.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.tint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(chip.icon,
                      size: 20, color: sel ? Colors.white : AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    chip.label,
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
    final labels = _sortLabels;
    final filterWord = t('फिल्टर', 'Filter');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        GestureDetector(
          onTap: _openFilter,
          child: _pill(Icons.tune, n > 0 ? '$filterWord ($n)' : filterWord,
              arrow: true, active: n > 0),
        ),
        PopupMenuButton<int>(
          onSelected: (v) => setState(() => _sort = v),
          itemBuilder: (_) => List.generate(
            labels.length,
            (i) => PopupMenuItem<int>(value: i, child: Text(labels[i])),
          ),
          child: _pill(Icons.swap_vert, labels[_sort], arrow: true),
        ),
        GestureDetector(
          onTap: () => showMsg(
              context,
              t('मैप वाला हिस्सा बाद में जुड़ेगा',
                  'Map view will be added later')),
          child: _pill(Icons.map_outlined, t('मैप पर देखें', 'View on map')),
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
            t('कुल $count परिणाम', 'Total $count results'),
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
            ListingImage(listing: l, fit: BoxFit.cover),
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
        '₹${inr(price)}${t('/माह', '/month')}',
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

  /// असली कमरों में मालिक का नंबर अभी कार्ड पर नहीं है, इसलिए विवरण खोलने का बटन
  Widget _detailBtn(Listing l, {double height = 42}) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton.icon(
        onPressed: () => _openDetail(l),
        icon: const Icon(Icons.visibility_outlined, size: 18),
        label: Text(t('विवरण देखें', 'View details')),
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
                          if (l.typeLabel.isNotEmpty)
                            _stat(Icons.home_outlined, l.typeLabel),
                          if (l.bathLabel.isNotEmpty)
                            _stat(Icons.bathtub_outlined, l.bathLabel),
                          if (l.sqft > 0)
                            _stat(Icons.square_foot, '${l.sqft} sq ft'),
                          if (l.floor.isNotEmpty)
                            _stat(Icons.apartment, l.floor),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (l.desc.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                l.desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12.5, height: 1.35, color: AppColors.muted),
              ),
            ],
            const SizedBox(height: 10),
            _detailBtn(l),
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
            _detailBtn(l, height: 36),
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
          Text(
            t('कोई कमरा नहीं मिला', 'No rooms found'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            t('आपके द्वारा चुनी गई जानकारी के अनुसार,\nकोई भी कमरा उपलब्ध नहीं है।',
                'According to your selection,\nno rooms are available.'),
            textAlign: TextAlign.center,
            style: const TextStyle(
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
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        size: 24, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t('आप ये भी कोशिश कर सकते हैं:',
                            'You can also try:'),
                        style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _suggestRow(
                    t('किराया रेंज थोड़ा बदलें',
                        'Change the rent range a little'),
                    _openFilter),
                _suggestRow(
                    t('किसी दूसरे इलाके को चुनें',
                        'Choose a different area'),
                    _openFilter),
                _suggestRow(
                    t('फिल्टर कम करके फिर से खोजें',
                        'Reduce filters and search again'),
                    _resetAll),
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
              label: Text(t('फिर से खोजें', 'Search again')),
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

  Widget _loadingBox() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _errorBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
      child: Column(
        children: [
          const Icon(Icons.wifi_off, size: 44, color: AppColors.muted),
          const SizedBox(height: 10),
          Text(
            listingsStore.error ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: listingsStore.loading ? null : listingsStore.load,
            child: Text(t('फिर कोशिश करें', 'Try again')),
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
        return ListenableBuilder(
          listenable: Listenable.merge([appState, listingsStore]),
          builder: (context, _) {
            final loaded = listingsStore.loaded;
            final results = loaded ? _resultsWith(_filters) : <Listing>[];
            return Scaffold(
              backgroundColor: const Color(0xFFF7FCF9),
              body: RefreshIndicator(
                onRefresh: () => listingsStore.load(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                              if (loaded) ...[
                                const SizedBox(height: 16),
                                _countRow(results.length),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!loaded && listingsStore.error == null)
                      SliverToBoxAdapter(child: _loadingBox())
                    else if (!loaded)
                      SliverToBoxAdapter(child: _errorBox())
                    else if (results.isEmpty)
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
              ),
            );
          },
        );
      },
    );
  }
}
