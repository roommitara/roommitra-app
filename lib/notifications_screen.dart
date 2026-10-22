import 'package:flutter/material.dart';

import 'data.dart';
import 'notification_service.dart';
import 'strings.dart';
import 'theme.dart';

/// असली नोटिफिकेशन: कमरा मंज़ूर/रिजेक्ट/छिपा, और एडमिन के लिए नया कमरा व रिपोर्ट।
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationService get _svc => NotificationService.instance;

  @override
  void initState() {
    super.initState();
    _svc.start();
  }

  IconData _icon(String kind) {
    switch (kind) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'hidden':
        return Icons.visibility_off;
      case 'review':
        return Icons.fact_check;
      case 'report':
        return Icons.flag;
      default:
        return Icons.notifications;
    }
  }

  Color _color(String kind) {
    switch (kind) {
      case 'approved':
        return AppColors.primary;
      case 'rejected':
      case 'report':
        return AppColors.danger;
      case 'hidden':
        return const Color(0xFFF2A81D);
      default:
        return AppColors.primaryDark;
    }
  }

  String _ago(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return t('अभी', 'Just now');
    if (diff.inMinutes < 60) {
      return t('${diff.inMinutes} मिनट पहले', '${diff.inMinutes} min ago');
    }
    if (diff.inHours < 24) {
      return t('${diff.inHours} घंटे पहले', '${diff.inHours} h ago');
    }
    return t('${diff.inDays} दिन पहले', '${diff.inDays} days ago');
  }

  Widget _tile(AppNotification n) {
    final c = _color(n.kind);
    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _svc.delete(n),
      child: GestureDetector(
        onTap: () => _svc.markRead(n),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: n.isRead ? AppColors.surface : AppColors.tint,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: c.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon(n.kind), color: c, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t(n.titleHi, n.titleEn),
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text),
                          ),
                        ),
                        if (!n.isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    if (n.bodyHi.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        t(n.bodyHi, n.bodyEn),
                        style: TextStyle(
                            fontSize: 13, height: 1.35, color: AppColors.text),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _ago(n.createdAt),
                      style:
                          TextStyle(fontSize: 11.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty(String text, {bool retry = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 64, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, height: 1.4, color: AppColors.muted)),
            if (retry) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: _svc.load, child: Text(t('फिर कोशिश करें', 'Retry'))),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, _, __) => ListenableBuilder(
        listenable: _svc,
        builder: (context, _) {
          final items = _svc.items;
          Widget body;
          if (!_svc.loaded && _svc.error == null) {
            body = const Center(child: CircularProgressIndicator());
          } else if (!_svc.loaded && _svc.error != null) {
            body = _empty(
                t('नोटिफिकेशन लोड नहीं हो सके। इंटरनेट जाँचकर फिर कोशिश करें।',
                    'Could not load notifications. Check your internet and retry.'),
                retry: true);
          } else if (items.isEmpty) {
            body = _empty(t('अभी कोई नोटिफिकेशन नहीं है',
                'No notifications yet'));
          } else {
            body = RefreshIndicator(
              onRefresh: _svc.load,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(14),
                itemCount: items.length,
                itemBuilder: (c, i) => _tile(items[i]),
              ),
            );
          }
          return Scaffold(
            backgroundColor: AppColors.bg,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              title: Text(t('नोटिफिकेशन', 'Notifications')),
              actions: [
                if (_svc.unread > 0)
                  TextButton(
                    onPressed: _svc.markAllRead,
                    child: Text(t('सब पढ़ा', 'Mark all read'),
                        style: const TextStyle(color: Colors.white)),
                  ),
              ],
            ),
            body: body,
          );
        },
      ),
    );
  }
}
