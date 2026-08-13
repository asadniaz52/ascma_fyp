// ─── ASCMA – Main Entry Point ──────────────────────────────────────────────────
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/complaint_service.dart';
import 'utils/app_theme.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/super_admin/super_admin_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ComplaintService()),
      ],
      child: const AscmaApp(),
    ),
  );
}

class AscmaApp extends StatelessWidget {
  const AscmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:            'ASCMA',
      debugShowCheckedModeBanner: false,
      theme:            AppTheme.lightTheme,
      home:             const AuthGate(),
    );
  }
}

// ─── Auth Gate ─────────────────────────────────────────────────────────────────
/// Listens to auth state and routes to appropriate screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    // Still initialising – show splash
    if (authService.firebaseUser == null && authService.isLoading) {
      return const _SplashScreen();
    }

    // Not logged in → Welcome
    if (!authService.isLoggedIn) {
      return const WelcomeScreen();
    }

    // Logged in but user doc not yet loaded
    final user = authService.currentUser;
    if (user == null) {
      return const _SplashScreen();
    }

    // Route by role
    if (user.isSuperAdmin) return const SuperAdminDashboardScreen();
    if (user.isAdmin)      return const AdminDashboardScreen();
    return const HomeScreen();
  }
}

// ─── Splash Screen ─────────────────────────────────────────────────────────────
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:  100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
              ),
              child: const Icon(
                Icons.shield_rounded,
                size:  60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ASCMA',
              style: TextStyle(
                fontSize:      36,
                fontWeight:    FontWeight.w900,
                color:         Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Anonymous Suggestion &\nComplaint Management Application',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color:    Colors.white70,
                height:   1.5,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
