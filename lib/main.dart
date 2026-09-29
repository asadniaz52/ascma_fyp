// ─── ASCMA – Main Entry Point ──────────────────────────────────────────────────
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/complaint_service.dart';
import 'services/department_service.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'screens/auth/onboarding_screen.dart';
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
        ChangeNotifierProvider(create: (_) => DepartmentService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
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
      title:                      'ASCMA',
      debugShowCheckedModeBanner: false,
      theme:                      AppTheme.lightTheme,
      home:                       const AuthGate(),
    );
  }
}

// ─── Auth Gate ─────────────────────────────────────────────────────────────────
/// Checks local onboarding persistence, authentication state, and routes to correct screen.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? _hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSeenOnboarding = prefs.getBool(AppConstants.keyHasSeenOnboarding) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    // 1. If user is logged in, prioritize dashboard routing immediately
    if (authService.isLoggedIn) {
      final user = authService.currentUser;
      if (user != null) {
        if (user.isSuperAdmin) return const SuperAdminDashboardScreen();
        if (user.isDepartmentAdmin || user.isAdmin) return const AdminDashboardScreen();
        return const HomeScreen();
      }
      // Brief spinner while fetching Firestore user doc for existing Firebase session
      return const _SplashScreen();
    }

    // 2. If onboarding status is still loading from SharedPreferences
    if (_hasSeenOnboarding == null) {
      return const _SplashScreen();
    }

    // 3. First time app opened → Show Onboarding
    if (!_hasSeenOnboarding!) {
      return const OnboardingScreen();
    }

    // 4. Onboarding completed but not logged in → Welcome / Login Screen
    return const WelcomeScreen();
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
              width:  90,
              height: 90,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
              ),
              child: const Icon(
                Icons.shield_rounded,
                size:  54,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'ASCMA',
              style: TextStyle(
                fontSize:      32,
                fontWeight:    FontWeight.w900,
                color:         Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Anonymous Feedback System',
              style: TextStyle(
                fontSize: 12,
                color:    Colors.white70,
              ),
            ),
            const SizedBox(height: 36),
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

