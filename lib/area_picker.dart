import 'package:flutter/material.dart';

import 'data.dart';
import 'places_service.dart';
import 'strings.dart';
import 'theme.dart';

/// शहर के इलाकों की लिस्ट (Google के नाम) खोलकर एक चुनवाता है।
/// खोजने का डिब्बा भी है; लिस्ट में न मिले तो "अपना नाम लिखें" का रास्ता भी।
Future<String?> showAreaPicker(BuildContext context, String city) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _AreaSheet(city: city),
  );
}

class _AreaSheet extends StatefulWidget {
  final String city;
  const _AreaSheet({required this.city});

  @override
  State<_AreaSheet> createState() => _AreaSheetState();
}

class _AreaSheetState extends State<_AreaSheet> {
  List<AreaItem>? _all;
  String _q = '';

  @override
  void initState() {
    super.initState();
    PlacesService.areas(widget.city).then((l) {
      if (mounted) setState(() => _all = l);
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height * 0.8;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final all = _all;
    final q = _q.trim().toLowerCase();
    final list = all == null
        ? <AreaItem>[]
        : all.where((a) => q.isEmpty || a.name.toLowerCase().contains(q)).toList();
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: h,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                        '${t('इलाका चुनें', 'Choose area')} · ${cityName(widget.city)}',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _q = v),
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  hintText: t('इलाके का नाम खोजें', 'Search area name'),
                  hintStyle: TextStyle(color: AppColors.muted),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary)),
                ),
              ),
            ),
            Expanded(
              child: all == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        for (final a in list)
                          ListTile(
                            dense: true,
                            leading: Icon(Icons.place_outlined,
                                color: AppColors.primary),
                            title: Text(a.name,
                                style: TextStyle(color: AppColors.text)),
                            onTap: () => Navigator.of(context).pop(a.name),
                          ),
                        if (list.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                                all.isEmpty
                                    ? t('अभी लिस्ट नहीं मिली। नीचे से अपना नाम लिखें।',
                                        'List not available right now. Type your own name below.')
                                    : t('इस नाम का इलाका नहीं मिला।',
                                        'No area with this name.'),
                                style: TextStyle(color: AppColors.muted)),
                          ),
                        if (all.isEmpty && PlacesService.lastError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text('Error: ${PlacesService.lastError}',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.danger)),
                          ),
                        if (q.length >= 2)
                          ListTile(
                            leading: Icon(Icons.edit, color: AppColors.accent),
                            title: Text(
                                t('"${_q.trim()}" खुद का नाम इस्तेमाल करें',
                                    'Use "${_q.trim()}" as my own name'),
                                style: TextStyle(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w700)),
                            onTap: () => Navigator.of(context).pop(_q.trim()),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
