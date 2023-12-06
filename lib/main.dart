import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_theme.dart';
import 'models/models.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final appStateManager = AppStateManager();
  await appStateManager.initializeApp();
  runApp(MovieApp(appStateManager: appStateManager));
}

class MovieApp extends StatefulWidget {
  final AppStateManager appStateManager;

  const MovieApp({super.key, required this.appStateManager});

  @override
  MovieAppState createState() => MovieAppState();
}

class MovieAppState extends State<MovieApp> {
  // late final _groceryManager = GroceryManager();
  // late final _profileManager = ProfileManager();
  late final _appRouter = AppRouter(
    widget.appStateManager,
    // _profileManager,
    // _groceryManager,
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => widget.appStateManager,
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = _appRouter.router;
          return MaterialApp.router(
            theme: AppTheme.dark(),
            title: 'NutriApp',
            routeInformationParser: router.routeInformationParser,
            routeInformationProvider: router.routeInformationProvider,
            routerDelegate: router.routerDelegate,
          );
        },
      ),
    );
  }
}