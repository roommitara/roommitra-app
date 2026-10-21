import 'package:flutter/material.dart';
import 'add_listing_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'strings.dart';
import 'theme.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  Widget _navItem(
      int i, IconData icon, IconData activeIcon, String label) {
    final sel = _index == i;
    return Expanded(
      child: InkWell(
        onTap: () => _go(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              sel ? activeIcon : icon,
              size: 27,
              color: sel ? AppColors.primary : AppColors.muted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                color: sel ? AppColors.primary : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _centerItem() {
    return Expanded(
      child: InkWell(
        onTap: () => _go(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 8,
                      offset: Offset(0, 2)),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 2),
            Text(
              t('लिस्ट करें', 'List'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: _index == 2 ? FontWeight.w800 : FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
              color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -2)),
        ],
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: SizedBox(
        height: 70,
        child: Row(
          children: [
            _navItem(
                0, Icons.home_outlined, Icons.home_rounded, t('होम', 'Home')),
            _navItem(1, Icons.search, Icons.search, t('खोजें', 'Search')),
            _centerItem(),
            _navItem(3, Icons.favorite_border, Icons.favorite,
                t('पसंदीदा', 'Favorites')),
            _navItem(4, Icons.person_outline, Icons.person,
                t('प्रोफाइल', 'Profile')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, lang, _) {
        final pages = <Widget>[
          HomeScreen(
              onListTap: () => _go(2),
              onSearchTap: () => _go(1),
              onProfileTap: () => _go(4)),
          const SearchScreen(),
          AddListingScreen(onDone: () => _go(0)),
          FavoritesScreen(onSearchTap: () => _go(1)),
          ProfileScreen(onAdd: () => _go(2)),
        ];
        return Scaffold(
          // छिपे टैब में ऐनिमेशन/वीडियो न चलें, इसलिए TickerMode से बंद रखते हैं
          body: IndexedStack(
            index: _index,
            children: [
              for (var i = 0; i < pages.length; i++)
                TickerMode(enabled: i == _index, child: pages[i]),
            ],
          ),
          bottomNavigationBar: _bottomBar(context),
        );
      },
    );
  }
}
