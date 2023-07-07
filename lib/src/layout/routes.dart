import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todopeer/src/page/pomo/pomo.dart';
import 'package:todopeer/src/todo/list.dart';
import 'package:todopeer/src/user/login.dart';

import '../env.dart';
import '../page/review/review.dart';

class RoutesConfig {
  static int counter = 0;
  RoutesConfig({
    required IconData icon,
    required String label,
    required this.route,
    required this.pageBuilder,
  }):
        barItem = BottomNavigationBarItem(
          icon: Icon(icon), label: label,
        ), idx = counter {
    counter++;
  }


  final BottomNavigationBarItem barItem;
  final String route;
  final Widget Function(BuildContext, Env) pageBuilder;
  final int idx;

  Scaffold getScaffold(BuildContext ctx, Env env) {
    return Scaffold(
      appBar: AppBar(title: const Text("TodoPeer App")),
      body: pageBuilder(ctx, env),
      bottomNavigationBar: BottomNavigationBar(
        items: Routes.barItems,
        currentIndex: idx,

        unselectedItemColor: Colors.blueGrey,
        selectedItemColor: Theme.of(ctx).primaryColor,

        showUnselectedLabels: true,
        // onTap: (idx) => Navigator.of(ctx).pushNamed(route),
        onTap: (idx) {
          ctx.go(Routes.barConfigs[idx].route);
        },
    ));
  }
}

class Routes {
  static var barConfigs = [
    RoutesConfig(icon: Icons.list, label: "Task", route: "/", pageBuilder: (ctx, env) => TaskListPage(env: env,)),
    RoutesConfig(icon: Icons.watch_later_outlined, label: "Pomodoro", route: "/pomo", pageBuilder: (ctx, env) => PomoPage()),
    RoutesConfig(icon: Icons.calendar_today_outlined, label: "Review", route: "/review", pageBuilder: (ctx, env) => ReviewPage(env: env,)),
    RoutesConfig(icon: Icons.person, label: "Me", route: "/login", pageBuilder: (ctx, env) => LoginPage(env: env)),
  ];

  static var barItems = barConfigs.map((e) => e.barItem).toList(growable: false);

  static int getIndexFromRoute(String? route) {
    route ??= "/tasks/";

    for (var i = 0 ; i < barConfigs.length ; i++) {
      if(route.startsWith(barConfigs[i].route)) {
        return i;
      }
    }

    // didn't find an active index
    return -1;
  }

  // static Widget getPage(RouteSettings settings, BuildContext ctx, final Env env) {
  //   int idx = getIndexFromRoute(settings.name);
  //   if(idx < 0) {
  //     idx = 0;
  //   }
  //
  //   return Scaffold(
  //     appBar: AppBar(title: const Text("TodoPeer App")),
  //     body: barConfigs[idx].pageBuilder(ctx, env),
  //     bottomNavigationBar: BottomNavigationBar(
  //       items: barItems,
  //       currentIndex: idx,
  //
  //       unselectedItemColor: Colors.blueGrey,
  //       selectedItemColor: Theme.of(ctx).primaryColor,
  //
  //       showUnselectedLabels: true,
  //       onTap: (idx) => Navigator.of(ctx).pushNamed(barConfigs[idx].route),
  //     ),
  //   );
  // }

  static Map<String, WidgetBuilder> getNamed(Env env) {
    return Map<String, WidgetBuilder>.fromEntries(barConfigs.map((e) => MapEntry(e.route, (ctx) => e.pageBuilder(ctx, env))));
  }

  static getRouter(Env env) {
    return GoRouter(routes: barConfigs.map((e) => GoRoute(path: e.route, builder: (ctx, state) => e.getScaffold(ctx, env))).toList());
  }
}