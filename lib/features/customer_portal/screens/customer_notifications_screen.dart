import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/customer_auth_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/widgets/dark_glass_container.dart';

/// Unread count provider — used for badge in customer shell
final customerUnreadCountProvider = StateProvider<int>((ref) => 0);

/// Notifications list provider
final customerNotifListProvider =
    FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
      final session = ref.watch(customerSessionProvider);
      if (session == null) return [];

      final service = ref.read(notificationServiceProvider);
      final result = await service.getCustomerNotifications(
        customerId: session.customerId,
        pin: session.pin,
      );

      if (result['success'] == true) {
        final raw = (result['notifications'] as List?) ?? [];
        final list = raw
            .map(
              (e) => NotificationModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();

        // Update unread badge
        ref.read(customerUnreadCountProvider.notifier).state =
            result['unread_count'] as int? ?? 0;

        return list;
      }
      return [];
    });

class CustomerNotificationsScreen extends ConsumerWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(customerSessionProvider);
    final notifsAsync = ref.watch(customerNotifListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        elevation: 0,
        actions: [
          notifsAsync.maybeWhen(
            data: (list) {
              final hasUnread = list.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () async {
                  if (session == null) return;
                  HapticFeedback.lightImpact();
                  await ref
                      .read(notificationServiceProvider)
                      .markAllRead(
                        customerId: session.customerId,
                        pin: session.pin,
                      );
                  ref.read(customerUnreadCountProvider.notifier).state = 0;
                  ref.invalidate(customerNotifListProvider);
                },
                icon: const Icon(Icons.done_all, size: 18),
                label: Text(
                  l10n.markAllRead,
                  style: const TextStyle(fontSize: 13),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(customerNotifListProvider),
        child: notifsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return _EmptyState(l10n: l10n, isDark: isDark);
            }
            return ListView.separated(
              padding: const EdgeInsets.only(
                top: 12,
                left: 16,
                right: 16,
                bottom: 100,
              ),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final notif = notifications[i];
                return _NotificationCard(
                  notif: notif,
                  isDark: isDark,
                  onRead: () async {
                    if (notif.isRead || session == null) return;
                    await ref
                        .read(notificationServiceProvider)
                        .markRead(
                          customerId: session.customerId,
                          notificationId: notif.id,
                          pin: session.pin,
                        );
                    final current = ref.read(customerUnreadCountProvider);
                    ref.read(customerUnreadCountProvider.notifier).state =
                        (current - 1).clamp(0, 9999);
                    ref.invalidate(customerNotifListProvider);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off, size: 48, color: AppColors.textHint),
                const SizedBox(height: 12),
                Text(
                  'تعذر تحميل الإشعارات',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(customerNotifListProvider),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notif;
  final bool isDark;
  final VoidCallback onRead;

  const _NotificationCard({
    required this.notif,
    required this.isDark,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notif.isRead;

    Widget cardContent = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isUnread
                  ? AppColors.primary
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.surfaceVariant),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isUnread ? Icons.notifications_active : Icons.notifications_none,
              color: isUnread
                  ? Colors.white
                  : (isDark ? Colors.white : AppColors.textSecondary),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'SAMI MARKET',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.2)
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          border: isDark
                              ? Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                )
                              : null,
                        ),
                        child: const Text(
                          'جديد',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notif.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(notif.createdAt),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isDark) {
      return DarkGlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: 14,
        backgroundColor: const Color(0xFF16161A),
        borderColor: isUnread
            ? AppColors.primaryLight.withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.05),
        onTap: isUnread ? onRead : null,
        child: cardContent,
      );
    }

    return GestureDetector(
      onTap: isUnread ? onRead : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.primary.withAlpha(10) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread
                ? AppColors.primary.withAlpha(80)
                : AppColors.border,
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: isUnread
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: cardContent,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;

  const _EmptyState({required this.l10n, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_off_outlined,
                  size: 38,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.noNotifications,
                style: AppTextStyles.titleMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ستظهر هنا الرسائل من صاحب الماركت',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
