import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'providers/ai_provider.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_layout.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
      ],
      child: const MasdemApp(),
    ),
  );
}

class MasdemApp extends StatelessWidget {
  const MasdemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masderm Portugal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Show a blank screen while restoring session from shared_preferences
    if (auth.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
      );
    }

    return auth.isLoggedIn ? const MainLayout() : const LoginScreen();
  }
}
