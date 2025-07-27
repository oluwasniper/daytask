import 'package:daytask/core/routes/app_router.dart';
import 'package:daytask/providers/auth_provider.dart';
import 'package:daytask/providers/note_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider - handles user authentication
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        // Note Provider - handles note management
        ChangeNotifierProvider(create: (context) => NoteProvider()),
        // You can add more providers here as your app grows
        // Example: ThemeProvider, SettingsProvider, etc.
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'DayTask',
            debugShowCheckedModeBanner: false,

            // Theme configuration
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
            ),

            // Dark theme (optional)
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: Colors.blue,
              appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
            ),

            routerConfig: _appRouter.config(),
          );
        },
      ),
    );
  }
}

// Optional: App initialization widget to handle auth state
class AppInitializer extends StatefulWidget {
  final Widget child;

  const AppInitializer({super.key, required this.child});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if user is already logged in
    await authProvider.checkAuthStatus();

    // If user is authenticated, fetch their notes
    if (authProvider.isAuthenticated) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      await noteProvider.fetchNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
