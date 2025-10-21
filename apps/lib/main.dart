import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';

void
main() {
  runApp(
    const MyApp(),
  );
}

class MyApp
    extends
        StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return MaterialApp(
      title: 'ShowOff.life',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/onboarding':
            (
              context,
            ) => const OnboardingScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
