import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Работает с 6.0.5
import './screens/login_screen.dart';
import './screens/register_screen.dart';
import './screens/subscription_screen.dart';
import './providers/auth_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider( // Работает с 6.0.5
      providers: [
        ChangeNotifierProvider( // Работает с 6.0.5
          create: (_) => AuthProvider(),
        ),
      ],
      child: Consumer<AuthProvider>( // Работает с 6.0.5
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: 'Subscription App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: _buildHomeScreen(authProvider),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  Widget _buildHomeScreen(AuthProvider authProvider) {
    if (authProvider.isAuthenticated) {
      return SubscriptionsScreen(); // Экран подписок
    }
    return LoginScreen();
  }
}