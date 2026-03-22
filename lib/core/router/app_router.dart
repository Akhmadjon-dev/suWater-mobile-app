import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:suwater_mobile/providers/auth_provider.dart';
import 'package:suwater_mobile/features/auth/login_screen.dart';
import 'package:suwater_mobile/features/auth/register_screen.dart';
import 'package:suwater_mobile/features/worker/worker_shell.dart';
import 'package:suwater_mobile/features/worker/event_detail/worker_event_detail_screen.dart';
import 'package:suwater_mobile/features/citizen/citizen_shell.dart';
import 'package:suwater_mobile/features/citizen/report/citizen_report_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (authState.status == AuthStatus.initial) return null;
      if (!isAuth && !isLoginRoute) return '/login';

      if (isAuth && isLoginRoute) {
        final user = authState.user!;
        if (user.isCitizen) return '/citizen';
        return '/worker';
      }

      return null;
    },
    routes: [
      // Auth
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Worker
      GoRoute(
        path: '/worker',
        builder: (context, state) => const WorkerShell(),
      ),
      GoRoute(
        path: '/worker/events/:id',
        builder: (context, state) {
          final eventId = state.pathParameters['id'];
          if (eventId == null || eventId.isEmpty) {
            return const WorkerShell();
          }
          return WorkerEventDetailScreen(eventId: eventId);
        },
      ),

      // Citizen
      GoRoute(
        path: '/citizen',
        builder: (context, state) => const CitizenShell(),
      ),
      GoRoute(
        path: '/citizen/report',
        builder: (context, state) => const CitizenReportScreen(),
      ),
    ],
  );
});
