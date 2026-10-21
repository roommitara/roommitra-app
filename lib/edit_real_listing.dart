import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data.dart';
import 'strings.dart';
import 'theme.dart';

/// मालिक अपनी असली लिस्टिंग का शीर्षक, विवरण, किराया और डिपॉजिट बदल सकता है।
/// सुरक्षा: बदलाव के बाद सर्वर खुद कमरे को फिर से जाँच (pending) में भेज देता है।
class EditRealListingScreen extends StatefulWidget {
  final String listingId;
  const EditRealListingScreen({super.key, required this.listingId});

  @override
  State<EditRealListingScreen> createState() => _EditRealListingScreenState();
}

class _EditRealListingScreenState extends State<EditRealListingScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _rent = TextEditingController();
  final _deposit = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _rent.dispose();
    _deposit.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final row = await Supabase.instance.client
          .from('room_listings')
          .select('title, description, monthly_rent, security_deposit')
          .eq('id', widget.listingId)
          .single();
      _title.text = (row['title'] ?? '').toString();
      _desc.text = (row['description'] ?? '').toString();
      _rent.text = (row['monthly_rent'] ?? '').toString();
      _deposit.text = (row['security_deposit'] ?? 0).toString();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = t('लिस्टिंग लोड नहीं हो सकी। इंटरनेट जाँचें।',
            'Could not load the listing. Check your internet.');
      });
    }
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final rent = int.tryParse(_rent.text.trim());
    final deposit = int.tryParse(_deposit.text.trim()) ?? 0;
    if (title.length < 5) {
      showMsg(context, t('शीर्षक कम से कम 5 अक्षर का लिखें',
          'Title must be at least 5 characters'));
      return;
    }
    if (rent == null || rent <= 0) {
      showMsg(context, t('सही किराया लिखें', 'Enter a valid rent'));
      return;
    }
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.from('room_listings').update({
        'title': title,
        'description': _desc.text.trim(),
        'monthly_rent': rent,
        'security_deposit': deposit,
      }).eq('id', widget.listingId);
      await listingsStore.load();
      if (!mounted) return;
      showMsg(
          context,
          t('बदलाव सेव हुए। कमरा फिर से जाँच में गया है, मंज़ूरी के बाद दिखेगा।',
              'Changes saved. The room is back in review and will show again once approved.'));
      Navigator.of(context).pop(true);
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showMsg(context, '${t('सेव नहीं हो सका', 'Could not save')}: ${e.message}');
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showMsg(context, t('इंटरनेट जाँचकर फिर कोशिश करें',
          'Check your internet and try again'));
    }
  }

  Widget _field(String label, TextEditingController c,
      {bool number = false, int lines = 1, int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        maxLines: lines,
        minLines: 1,
        maxLength: maxLength,
        keyboardType: number ? TextInputType.number : TextInputType.multiline,
        inputFormatters:
            number ? [FilteringTextInputFormatter.digitsOnly] : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(t('लिस्टिंग बदलें', 'Edit listing')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.tintLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          t('ध्यान दें: बदलाव सेव करने पर कमरा फिर से जाँच (pending) में जाएगा। मंज़ूरी मिलने तक वह सबको नहीं दिखेगा।',
                              'Note: after saving, the room goes back to review (pending). It will not be public until approved.'),
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                      _field(t('शीर्षक', 'Title'), _title, maxLength: 80),
                      _field(t('विवरण', 'Description'), _desc,
                          lines: 5, maxLength: 600),
                      _field(t('किराया (₹ प्रति माह)', 'Rent (₹ per month)'),
                          _rent,
                          number: true),
                      _field(t('सिक्योरिटी डिपॉजिट (₹)', 'Security deposit (₹)'),
                          _deposit,
                          number: true),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text(t('सेव करें', 'Save'),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
