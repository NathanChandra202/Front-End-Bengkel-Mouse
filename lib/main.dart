import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/tracking/orders_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/tracking/tracking_detail_screen.dart';
import 'screens/payment/payment_instruction_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_stock_screen.dart';
import 'screens/admin/admin_transaction_screen.dart';
import 'screens/admin/admin_transaction_detail_screen.dart';
import 'screens/profile/notifications_screen.dart';
import 'screens/profile/help_center_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const BengkelMouseApp(),
    ),
  );
}

class BengkelMouseApp extends StatelessWidget {
  const BengkelMouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      title: 'Bengkel Mouse',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return ResetPasswordScreen(email: email);
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/booking',
      builder: (context, state) => const BookingScreen(),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrdersScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/tracking/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TrackingDetailScreen(bookingId: id);
      },
    ),
    GoRoute(
      path: '/payment/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PaymentInstructionScreen(bookingId: id);
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpCenterScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/stock',
      builder: (context, state) => const AdminStockScreen(),
    ),
    GoRoute(
      path: '/admin/transactions',
      builder: (context, state) => const AdminTransactionScreen(),
    ),
    GoRoute(
      path: '/admin/transactions/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AdminTransactionDetailScreen(transactionId: id);
      },
    ),
  ],

  errorBuilder: (context, state) {
    debugPrint('[GoRouter] Route tidak ditemukan: ${state.uri}');
    debugPrint('[GoRouter] Error: ${state.error}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/home');
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  },
);
