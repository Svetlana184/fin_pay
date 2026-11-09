import 'package:go_router/go_router.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/auth/sign_up_screen.dart';
import '../features/auth/change_password_screen.dart';
import '../features/auth/password_changed_success_screen.dart';
import '../features/home/home_screen.dart';
import '../features/transfer/transfer_screen.dart';
import '../features/account/account_and_card_screen.dart';
import '../features/account/card_details_screen.dart';
import '../features/account/management_screen.dart';
import '../features/settings/app_info_screen.dart';
import '../features/withdraw/withdraw_screen.dart';


final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // Auth
    GoRoute(path: '/login', builder: (context, state) => const SignInScreen()),
    GoRoute(path: '/register', builder: (context, state) => const SignUpScreen()),
    GoRoute(path: '/change-password', builder: (context, state) => const ChangePasswordScreen()),
    GoRoute(path: '/password-changed', builder: (context, state) => const PasswordChangedSuccessScreen()),

    // Main
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

    // Transfer
    GoRoute(path: '/transfer', builder: (context, state) => const TransferScreen()),

    // Account & Cards
    GoRoute(path: '/account', builder: (context, state) => const AccountAndCardScreen()),
    GoRoute(path: '/card/:id', builder: (context, state) => CardDetailsScreen(cardId: state.pathParameters['id']!)),
    GoRoute(path: '/management', builder: (context, state) => const ManagementScreen()),

    // Transactions
    //GoRoute(path: '/transactions', builder: (context, state) => const TransactionsScreen()),

    // Bills
    //GoRoute(path: '/pay-bill', builder: (context, state) => const PayBillScreen()),
    //GoRoute(path: '/bill/:id', builder: (context, state) => BillDetailsScreen(billId: state.pathParameters['id']!)),

    // ATMs
    //GoRoute(path: '/atms', builder: (context, state) => const AtmsScreen()),

    // Exchange
    //GoRoute(path: '/exchange', builder: (context, state) => const ExchangeRatesScreen()),

    // Settings
    //GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    //GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    GoRoute(path: '/app-info', builder: (context, state) => const AppInfoScreen()),

    // Дополнительные экраны
    GoRoute(path: '/withdraw', builder: (context, state) => const WithdrawScreen()),
    //GoRoute(path: '/mobile-prepaid', builder: (context, state) => const MobilePrepaidScreen()),
    //GoRoute(path: '/save-online', builder: (context, state) => const SaveOnlineScreen()),
    //GoRoute(path: '/credit-card', builder: (context, state) => const CreditCardScreen()),
    //GoRoute(path: '/transaction-report', builder: (context, state) => const TransactionReportScreen()),
    //GoRoute(path: '/beneficiary', builder: (context, state) => const BeneficiaryScreen()),
    //GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    //GoRoute(path: '/mail', builder: (context, state) => const MailScreen()),
  ],
);