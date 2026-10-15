import 'package:flutter/material.dart';
import 'add_listing_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
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
              'लिस्ट करें',
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
      decoration: const BoxDecoration(
        color: Colors.white,
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
            _navItem(0, Icons.home_outlined, Icons.home_rounded, 'होम'),
            _navItem(1, Icons.search, Icons.search, 'खोजें'),
            _centerItem(),
            _navItem(
                3, Icons.favorite_border, Icons.favorite, 'पसंदीदा'),
            _navItem(4, Icons.person_outline, Icons.person, 'प्रोफाइल'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onListTap: () => _go(2), onSearchTap: () => _go(1)),
      const SearchScreen(),
      AddListingScreen(onDone: () => _go(0)),
      const PlaceholderScreen(icon: Icons.favorite_border, title: 'पसंदीदा'),
      const PlaceholderScreen(icon: Icons.person_outline, title: 'प्रोफाइल'),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _bottomBar(context),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  const PlaceholderScreen({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              '$title की स्क्रीन अगले चरण में बनेगी',
              style: const TextStyle(fontSize: 16, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
