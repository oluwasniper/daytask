import 'package:auto_route/auto_route.dart';
import 'package:daytask/core/routes/app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.material(); //.cupertino, .adaptive ..etc

  @override
  List<AutoRoute> get routes => [
    // HomeScreen is generated as HomeRoute because
    // of the replaceInRouteName property
    AutoRoute(page: HomeRoute.page, initial: false),
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: SignInRoute.page, initial: false),
    AutoRoute(page: SignUpRoute.page, initial: false),
    AutoRoute(page: CalendarRoute.page, initial: false),
    AutoRoute(page: ChatRoute.page, initial: false),
    AutoRoute(page: NotificationsRoute.page, initial: false),
  ];

  @override
  List<AutoRouteGuard> get guards => [
    // optionally add root guards here
  ];
}
