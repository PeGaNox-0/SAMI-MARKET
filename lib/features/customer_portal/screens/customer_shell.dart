import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/services/local_notification_service.dart';
import '../../../core/services/battery_optimization_service.dart';
import 'customer_dashboard_screen.dart';
import 'customer_transactions_screen.dart';
import 'customer_profile_screen.dart';
import 'customer_notifications_screen.dart';
import '../../../core/widgets/dark_glass_container.dart';

final customerNavIndexProvider = StateProvider<int>((ref) => 0);

class CustomerShell extends ConsumerStatefulWidget {
  final VoidCallback onLogout;

  const CustomerShell({super.key, required this.onLogout});

  @override
  ConsumerState<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends ConsumerState<CustomerShell> {
  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _setupNotifications() async {
    // 1. Initialize local system notification plugin
    final notifService = ref.read(notificationTapHandlerProvider);
    await notifService.initialize();

    // 2. Request Android battery optimization bypass to keep connection alive in background
    final batteryIgnored = await BatteryOptimizationService.isIgnored();
    if (!batteryIgnored) {
      await BatteryOptimizationService.requestIgnore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = ref.watch(customerNavIndexProvider);
    final unreadCount = ref.watch(customerUnreadCountProvider);

    final screens = [
      CustomerDashboardScreen(
        onViewAllTransactions: () {
          ref.read(customerNavIndexProvider.notifier).state = 1;
        },
      ),
      const CustomerTransactionsScreen(),
      const CustomerNotificationsScreen(),
      CustomerProfileScreen(onLogout: widget.onLogout),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: SafeArea(
        child: DarkGlassContainer(
          hasBlur: true,
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
          borderRadius: 28,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          backgroundColor: const Color(0xFF16161A),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomBarItem(
                context: context,
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.dashboard_outlined,
                selectedIcon: Icons.dashboard,
                label: l10n.dashboard,
                ref: ref,
              ),
              _buildBottomBarItem(
                context: context,
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long,
                label: l10n.transactionHistory,
                ref: ref,
              ),
              _buildBottomBarItem(
                context: context,
                index: 2,
                currentIndex: currentIndex,
                icon: Icons.notifications_outlined,
                selectedIcon: Icons.notifications,
                label: l10n.notifications,
                ref: ref,
                badgeValue: unreadCount,
              ),
              _buildBottomBarItem(
                context: context,
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: l10n.myAccount,
                ref: ref,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBarItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required WidgetRef ref,
    int badgeValue = 0,
  }) {
    final isSelected = index == currentIndex;
    final color = isSelected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.4);

    Widget iconWidget = Icon(
      isSelected ? selectedIcon : icon,
      size: 22,
      color: color,
    );

    if (badgeValue > 0) {
      iconWidget = Badge(
        label: Text(
          badgeValue > 99 ? '99+' : '$badgeValue',
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
        child: iconWidget,
      );
    }

    return InkWell(
      onTap: () => ref.read(customerNavIndexProvider.notifier).state = index,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
