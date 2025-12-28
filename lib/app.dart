// import 'package:flutter/material.dart';
// import 'ui/customer_screen.dart';

// class App extends StatelessWidget {
//   const App({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SQLite DataBase Windows Demo',
//       theme: ThemeData(useMaterial3: true),
//       home: const CustomerScreen(),
//     );
//   }
// }
import 'package:barber_demo/features/appointment/view/appointment_screen.dart';
import 'package:flutter/material.dart';
import 'features/services/view/services_list_screen.dart';

class BarberShopAdminApp extends StatelessWidget {
  const BarberShopAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barber Shop Admin',
      debugShowCheckedModeBanner: false,

      // Production Quality Theme Configuration
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        // Brand Colors
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A2B4A), // Navy Blue
          secondary: const Color(0xFFD4AF37), // Gold accent
          surface: Colors.white,
        ),

        // Consistent Input Styling
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Color(0xFF1A2B4A), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),

        // Consistent Button Styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A2B4A),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // AppBar Styling
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A2B4A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      // Start with Services Feature
      home: const AppointmentScreen(),
    );
  }
}
