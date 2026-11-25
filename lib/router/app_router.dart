import 'package:fin_pay/features/account/account_and_card_screen.dart';
import 'package:fin_pay/features/account/card_details_screen.dart';
import 'package:fin_pay/features/account/management_screen.dart';
import 'package:fin_pay/features/atms/atms_screen.dart';
import 'package:fin_pay/features/auth/forgot_password_screen.dart';
import 'package:fin_pay/features/auth/password_changed_success_screen.dart';
import 'package:fin_pay/features/beneficiary/add_beneficiary_screen.dart';
import 'package:fin_pay/features/beneficiary/beneficiary_list_screen.dart';
import 'package:fin_pay/features/bills/bill_details_screen.dart';
import 'package:fin_pay/features/bills/pay_bill_categories_screen.dart';
import 'package:fin_pay/features/bills/pay_bill_screen.dart';
import 'package:fin_pay/features/bills/payment_history_screen.dart';
import 'package:fin_pay/features/branch/branch_screen.dart';
import 'package:fin_pay/features/branch/interest_rate_screen.dart';
import 'package:fin_pay/features/credit_card/credit_card_screen.dart';
import 'package:fin_pay/features/exchange/exchange_rates_screen.dart';
import 'package:fin_pay/features/exchange/exchange_screen.dart';
import 'package:fin_pay/features/home/home_screen.dart';
import 'package:fin_pay/features/mail/chat_screen.dart';
import 'package:fin_pay/features/mail/message_list_screen.dart';
import 'package:fin_pay/features/mobile_prepaid/mobile_prepaid_confirm_screen.dart';
import 'package:fin_pay/features/mobile_prepaid/mobile_prepaid_screen.dart';
import 'package:fin_pay/features/save_online/add_deposit_screen.dart';
import 'package:fin_pay/features/save_online/save_online_screen.dart';
import 'package:fin_pay/features/search/search_screen.dart';
import 'package:fin_pay/features/settings/app_info_screen.dart';
import 'package:fin_pay/features/settings/change_password_screen.dart';
import 'package:fin_pay/features/transaction_report/transaction_report_screen.dart';
import 'package:fin_pay/features/transfer/confirm_screen.dart';
import 'package:fin_pay/features/transfer/transfer_screen.dart';
import 'package:fin_pay/features/withdraw/withdraw_screen.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/auth/sign_up_screen.dart';
import '../features/settings/setting_screen.dart';
import '../models/card.dart';


// =============================================================================
// КЛЮЧИ НАВИГАТОРОВ ДЛЯ КАЖДОЙ ВКЛАДКИ
// =============================================================================
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _searchNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _mailNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _settingsNavigatorKey = GlobalKey<NavigatorState>();

// =============================================================================
// ПРОВЕРКА АВТОРИЗАЦИИ
// =============================================================================
final _storage = const FlutterSecureStorage();

Future<bool> _isAuthenticated() async {
  final token = await _storage.read(key: 'auth_token');
  return token != null && token.isNotEmpty;
}

// =============================================================================
// РОУТЕР
// =============================================================================
final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final isAuthenticated = await _isAuthenticated();
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/change-password' ||
        state.matchedLocation == '/password-changed';

    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }
    if (isAuthenticated && isAuthRoute) {
      return '/home';
    }
    return null;
  },
  routes: [
    // ========================================================================
    // AUTH ROUTES (без оболочки)
    // ========================================================================
    GoRoute(
      path: '/login',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
      redirect: (context, state) async {
        final isAuthenticated = await _isAuthenticated();
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/forgot-password' ||
            state.matchedLocation == '/password-changed';

        if (!isAuthenticated && !isAuthRoute) return '/login';
        if (isAuthenticated && isAuthRoute) return '/home';
        return null;
      },
    ),

    // ========================================================================
    // STATEFUL SHELL ROUTE — нижняя навигация с независимыми стеками
    // ========================================================================
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // --- BRANCH 1: HOME ---
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'mobile-prepaid',
                  builder: (context, state) => const MobilePrepaidScreen(),
                  routes: [
                    GoRoute(
                      path: 'confirm',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>? ?? {};
                        return MobilePrepaidConfirmScreen(
                          fromCard: extra['fromCard']! as Card,
                          phone: extra['phone'] as String,
                          amount: (extra['amount'] as num).toDouble(),
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'account',
                  builder: (context, state) => const AccountAndCardScreen(),
                  routes: [
                    GoRoute(
                      path: 'card/:id',
                      builder: (context, state) =>
                          CardDetailsScreen(cardId: state.pathParameters['id']!),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'payment-history',
                  builder: (context, state) {
                    final type = state.uri.queryParameters['type'] ?? 'electric';
                    return PaymentHistoryScreen(initialType: type);
                  },
                ),
                GoRoute(
                  path: 'transfer',
                  builder: (context, state) => const TransferScreen(),
                  routes: [
                    GoRoute(
                      path: 'confirm',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>? ?? {};
                        return ConfirmScreen(
                          fromCard: extra['fromCard'],
                          recipientName: extra['recipientName'] ?? '',
                          cardNumber: extra['cardNumber'] ?? '',
                          beneficiaryBank: extra['beneficiaryBank'] as String?,
                          amount: (extra['amount'] as num?)?.toDouble() ?? 0,
                          content: extra['content'] ?? '',
                          saveBeneficiary: extra['saveBeneficiary'] ?? false,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'exchange',
                  builder: (context, state) => const ExchangeScreen(),
                ),
                GoRoute(
                  path: 'pay-bill',
                  builder: (context, state) => const PayBillCategoriesScreen(),
                  routes: [
                    GoRoute(
                      path: ':type',
                      builder: (context, state) => PayBillScreen(billType: state.pathParameters['type']!),
                      routes: [
                        GoRoute(
                          path: 'details',
                          builder: (context, state) {
                            final billData = state.extra as Map<String, dynamic>? ?? {};
                            return BillDetailsScreen(
                              billData: billData,
                              billType: state.pathParameters['type']!,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                GoRoute(
                  path: 'pay-bill',
                  builder: (context, state) {
                    // Тип счёта передаётся через query-параметр ?type=internet
                    final type = state.uri.queryParameters['type'] ?? 'internet';
                    return PayBillScreen(billType: type);
                  },
                  routes: [
                    GoRoute(
                      path: ':type/details',
                      builder: (context, state) {
                        final billData = state.extra as Map<String, dynamic>? ?? {};
                        return BillDetailsScreen(billData: billData);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'atms',
                  builder: (context, state) => const AtmsScreen(),
                ),
                GoRoute(
                  path: 'branch',
                  builder: (context, state) => const BranchScreen(),
                ),
                // GoRoute(
                //   path: 'exchange',
                //   builder: (context, state) => const ExchangeScreen(),
                // ),
                GoRoute(
                  path: 'exchange-rate',
                  builder: (context, state) => const ExchangeRateScreen(),
                ),
                GoRoute(
                  path: 'interest-rate',
                  builder: (context, state) => const InterestRateScreen(),
                ),
                GoRoute(
                  path: 'withdraw',
                  builder: (context, state) => const WithdrawScreen(),
                ),
                GoRoute(
                  path: 'save-online',
                  builder: (context, state) => const SaveOnlineScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) => const AddDepositScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'credit-card',
                  builder: (context, state) => const CreditCardScreen(),
                ),
                GoRoute(
                  path: 'transaction-report',
                  builder: (context, state) => const TransactionReportScreen(),
                ),
                GoRoute(
                  path: 'beneficiary',
                  builder: (context, state) => const BeneficiaryListScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) => const AddBeneficiaryScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'management',
                  builder: (context, state) => const ManagementScreen(),
                ),
              ],
            ),
          ],
        ),

        // --- BRANCH 2: SEARCH ---
        StatefulShellBranch(
          navigatorKey: _searchNavigatorKey,
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),

        // --- BRANCH 3: MAIL ---
        StatefulShellBranch(
          navigatorKey: _mailNavigatorKey,
          routes: [
            GoRoute(
              path: '/mail',
              builder: (context, state) => const MessageListScreen(),
              routes: [
                GoRoute(
                  path: 'chat/:id',
                  builder: (context, state) => ChatScreen(
                    conversationId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),

        // --- BRANCH 4: SETTINGS ---
        StatefulShellBranch(
          navigatorKey: _settingsNavigatorKey,
          routes: [
            GoRoute(
              path: '/setting',
              builder: (context, state) => const SettingScreen(),
              routes: [
                GoRoute(
                  path: 'change-password',
                  builder: (context, state) => const ChangePasswordScreen(),
                ),
                GoRoute(
                  path: 'password-changed',
                  builder: (context, state) => const PasswordChangedSuccessScreen(),
                ),
                GoRoute(
                  path: 'app-info',
                  builder: (context, state) => const AppInfoScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

// =============================================================================
// ОБОЛОЧКА С НИЖНЕЙ НАВИГАЦИЕЙ
// =============================================================================
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            activeIcon: Icon(Icons.mail),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
        selectedItemColor: const Color(0xFF3B2F9F),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}