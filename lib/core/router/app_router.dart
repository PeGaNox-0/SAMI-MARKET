import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/customers/screens/customers_list_screen.dart';
import '../../features/customers/screens/temporary_customers_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/customer_login_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/customer_portal/screens/customer_shell.dart';
import '../../features/customers/screens/customer_details_screen.dart';
import '../../features/customers/screens/add_edit_customer_screen.dart';
import '../../features/transactions/screens/add_debt_screen.dart';
import '../../features/transactions/screens/add_payment_screen.dart';
import '../../features/transactions/screens/edit_transaction_screen.dart';
import '../../features/customers/screens/send_notification_screen.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/services/customer_auth_service.dart';
import '../../core/services/sync_service.dart';
import '../widgets/dark_glass_container.dart';

/// Navigation index provider
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Auth wrapper — shows role selection, customer portal, or admin app based on auth/role state
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _showAdminLogin = true;

  @override
  Widget build(BuildContext context) {
    final activeRole = ref.watch(activeRoleProvider);
    final customerSession = ref.watch(customerSessionProvider);
    final authState = ref.watch(authStateProvider);

    // 1. If customer session is active -> Customer Portal
    if (customerSession != null) {
      return CustomerShell(
        onLogout: () {
          ref.read(customerSessionProvider.notifier).clearSession();
          ref.read(activeRoleProvider.notifier).state = AppRole.none;
        },
      );
    }

    // 2. If Admin Supabase auth session is active -> Admin Main Shell
    final adminSession = authState.asData?.value.session;
    if (adminSession != null) {
      return const MainShell();
    }

    // 3. Unauthenticated flows based on selected role
    switch (activeRole) {
      case AppRole.customer:
        return CustomerLoginScreen(
          onBackToRoles: () {
            ref.read(activeRoleProvider.notifier).state = AppRole.none;
          },
        );
      case AppRole.admin:
        return _showAdminLogin
            ? LoginScreen(
                onRegisterTap: () => setState(() => _showAdminLogin = false),
                onBackToRoles: () {
                  ref.read(activeRoleProvider.notifier).state = AppRole.none;
                },
              )
            : RegisterScreen(
                onLoginTap: () => setState(() => _showAdminLogin = true),
                onBackToRoles: () {
                  ref.read(activeRoleProvider.notifier).state = AppRole.none;
                },
              );
      case AppRole.none:
        return RoleSelectionScreen(
          onSelectAdmin: () {
            ref.read(activeRoleProvider.notifier).state = AppRole.admin;
          },
          onSelectCustomer: () {
            ref.read(activeRoleProvider.notifier).state = AppRole.customer;
          },
        );
    }
  }
}

/// Main app shell with bottom navigation
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final Set<int> _loadedTabs = {0};
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        ref.read(syncServiceProvider).handleAppResumed();
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(syncServiceProvider).startRealtimeSync(user.id);
      }
    });
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = ref.watch(navigationIndexProvider);
    _loadedTabs.add(currentIndex);

    // Listen for auth changes and trigger sync when user becomes available or changes
    ref.listen(currentUserProvider, (previous, next) {
      if (next != null && (previous == null || previous.id != next.id)) {
        ref.read(syncServiceProvider).startRealtimeSync(next.id);
      }
    });

    final screens = [
      _loadedTabs.contains(0) ? const DashboardScreen() : const SizedBox.shrink(),
      _loadedTabs.contains(1) ? const CustomersListScreen() : const SizedBox.shrink(),
      _loadedTabs.contains(2) ? const TemporaryCustomersScreen() : const SizedBox.shrink(),
      _loadedTabs.contains(3) ? const ReportsScreen() : const SizedBox.shrink(),
      _loadedTabs.contains(4) ? const SettingsScreen() : const SizedBox.shrink(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: SafeArea(
        child: DarkGlassContainer(
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
                icon: FontAwesomeIcons.house,
                label: l10n.dashboard,
                ref: ref,
              ),
              _buildBottomBarItem(
                context: context,
                index: 1,
                currentIndex: currentIndex,
                icon: FontAwesomeIcons.users,
                label: l10n.customers,
                ref: ref,
              ),
              _buildBottomBarItem(
                context: context,
                index: 2,
                currentIndex: currentIndex,
                icon: FontAwesomeIcons.stopwatch,
                label: 'مؤقت',
                ref: ref,
              ),
              _buildBottomBarItem(
                context: context,
                index: 3,
                currentIndex: currentIndex,
                icon: FontAwesomeIcons.chartColumn,
                label: l10n.reports,
                ref: ref,
              ),
              _buildBottomBarItem(
                context: context,
                index: 4,
                currentIndex: currentIndex,
                icon: FontAwesomeIcons.gear,
                label: l10n.settings,
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
    required FaIconData icon,
    required String label,
    required WidgetRef ref,
  }) {
    final isSelected = index == currentIndex;
    final color = isSelected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.4);

    return InkWell(
      onTap: () => ref.read(navigationIndexProvider.notifier).state = index,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 18, color: color),
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

/// Route generator for named routes
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '/');
    final segments = uri.pathSegments;

    // /customers/add
    if (segments.length == 2 &&
        segments[0] == 'customers' &&
        segments[1] == 'add') {
      return MaterialPageRoute(
        builder: (_) => const AddEditCustomerScreen(),
        settings: settings,
      );
    }

    // /customers/:id
    if (segments.length == 2 && segments[0] == 'customers') {
      return MaterialPageRoute(
        builder: (_) => CustomerDetailsScreen(customerId: segments[1]),
        settings: settings,
      );
    }

    // /customers/:id/edit
    if (segments.length == 3 &&
        segments[0] == 'customers' &&
        segments[2] == 'edit') {
      return MaterialPageRoute(
        builder: (_) => AddEditCustomerScreen(customerId: segments[1]),
        settings: settings,
      );
    }

    // /customers/:id/debt
    if (segments.length == 3 &&
        segments[0] == 'customers' &&
        segments[2] == 'debt') {
      return MaterialPageRoute(
        builder: (_) => AddDebtScreen(customerId: segments[1]),
        settings: settings,
      );
    }

    // /customers/:id/pay
    if (segments.length == 3 &&
        segments[0] == 'customers' &&
        segments[2] == 'pay') {
      return MaterialPageRoute(
        builder: (_) => AddPaymentScreen(customerId: segments[1]),
        settings: settings,
      );
    }

    // /transactions/:id/edit
    if (segments.length == 3 &&
        segments[0] == 'transactions' &&
        segments[2] == 'edit') {
      return MaterialPageRoute(
        builder: (_) => EditTransactionScreen(transactionId: segments[1]),
        settings: settings,
      );
    }

    // /forgot-password
    if (segments.length == 1 && segments[0] == 'forgot-password') {
      return MaterialPageRoute(
        builder: (_) => const ForgotPasswordScreen(),
        settings: settings,
      );
    }

    // /notifications/send
    if (segments.length == 2 &&
        segments[0] == 'notifications' &&
        segments[1] == 'send') {
      return MaterialPageRoute(
        builder: (_) => const SendNotificationScreen(),
        settings: settings,
      );
    }

    // Default — dashboard
    return MaterialPageRoute(
      builder: (_) => const AuthWrapper(),
      settings: settings,
    );
  }
}
