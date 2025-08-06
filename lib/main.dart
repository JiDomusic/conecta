import 'package:conecta/home_screen.dart';
import 'package:conecta/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'edit_profile_screen.dart';
import 'firebase_options.dart';
import 'landing_screen.dart';
import 'login_screen.dart';
import 'membership_screen.dart';
import 'profile_screen.dart';
import 'premium_match_screen.dart';
import 'accessibility_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conecta - App Inclusiva',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // Accessibility improvements
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme().apply(
          fontSizeFactor: 1.2, // Slightly larger text for better readability
        ),
      ),
      // High contrast theme for visually impaired users
      highContrastTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ).copyWith(
          // High contrast colors for accessibility
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.blue.shade900,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme().apply(
          fontSizeFactor: 1.3,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LandingScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/edit-profile': (_) => const EditProfileScreen(),
        '/home': (_) => const HomeScreen(),
        '/membership': (_) => const MembershipScreen(),
        '/premium-matches': (_) => const PremiumMatchScreen(),
      },
      builder: (context, child) {
        return AccessibilityWrapper(child: child!);
      },
    );
  }
}
