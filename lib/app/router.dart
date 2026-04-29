import 'package:go_router/go_router.dart';
import '../features/auth/auth_screen.dart';
import '../features/requests/request_list_screen.dart';
import '../features/requests/new_request_screen.dart';
import '../features/approvals/approval_inbox_screen.dart';
import '../features/approvals/review_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/requests',
      builder: (context, state) => const RequestListScreen(),
    ),
    GoRoute(
      path: '/requests/new',
      builder: (context, state) => const NewRequestScreen(),
    ),
    GoRoute(
      path: '/approvals',
      builder: (context, state) => const ApprovalInboxScreen(),
    ),
    GoRoute(
      path: '/approvals/review/:requestId',
      builder: (context, state) {
        final id = state.pathParameters['requestId']!;
        return ReviewScreen(requestId: id);
      },
    ),
  ],
);
