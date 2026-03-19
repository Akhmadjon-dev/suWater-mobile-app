import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suwater_mobile/core/router/app_router.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';

class SuWaterApp extends ConsumerWidget {
  const SuWaterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Dark status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return MaterialApp.router(
      title: 'WaterFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      builder: (context, child) {
        return DefaultTextStyle(
          style: const TextStyle(
            decoration: TextDecoration.none,
            color: AppColors.textPrimary,
          ),
          child: child!,
        );
      },
    );
  }
}
