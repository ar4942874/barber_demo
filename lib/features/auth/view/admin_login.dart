
import 'package:barber_demo/features/dasboard/view/admin_dashboard.dart';
import 'package:flutter/material.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    void onTap() {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => AdminDashboardScreen()));
    }

    
    
    List<Widget> formWidgets = [
      const AdminTextField(text: 'Email'),
      const SizedBox(height: 20),
      const AdminTextField(text: 'Password'),
      const SizedBox(height: 20),
      const AdminTextField(text: 'Downtown', downdrop: Icons.arrow_drop_down),
      const SizedBox(height: 40),
      GestureDetector(
        onTap: onTap,
        child: AdminSignCon(text: 'Sign In', color: Colors.white),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF161D2F),

      // 1. USE LAYOUT BUILDER HERE
      body: LayoutBuilder(
        builder: (context, constraints) {
          // If width > 900, for  Desktop
          bool isDesktop = constraints.maxWidth > 900;

          if (isDesktop) {
            // 2.  we return the window widget that we made and the formWidget
            return WindowUser(formWidgets: formWidgets);
          } else {
            // 3. for the small screeen
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AdminLoginScreenHeader(isDesktop: false),
                    SizedBox(height: constraints.maxWidth * 0.1),
                    ...formWidgets, 
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------
// WINDOW USER 

class WindowUser extends StatelessWidget {
  final List<Widget> formWidgets; 

  const WindowUser({super.key, required this.formWidgets});

  @override
  Widget build(BuildContext context) {
    return Center(
      
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, 
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
            // LEFT SIDE: HEADER
            Expanded(
              child: Container(
                
                padding: const EdgeInsets.only(right: 50),
                alignment: Alignment.center,
                child: const AdminLoginScreenHeader(isDesktop: true),
              ),
            ),

            // This is the Vertical Divider Container
            Container(width: 1, height: 400, color: const Color(0xFF2A3042)),

            
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 50),
                alignment: Alignment.centerLeft,
               
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: formWidgets, // here we pass the list
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






@immutable
// ignore: must_be_immutable
class AdminTextField extends StatelessWidget {
  const AdminTextField({super.key, required this.text, this.downdrop});
  final String text;
  final IconData? downdrop;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth * 0.6,
      child: TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          // focusColor: Colors.white,
          fillColor: const Color(0xFF2A3042),
          hintStyle: const TextStyle(color: Color(0xFF9EA4B0)),
          hintText: text,
          suffixIcon: Icon(downdrop, color: Color(0xFF9EA4B0)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: const BorderSide(color: Color(0xFF4C5568)),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class AdminSignCon extends StatelessWidget {
  AdminSignCon({super.key, required this.text, this.color});

  String text;
  Color? color;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.4,
      height: screenHeight * 0.065,
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), color: color),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Color(0xFF8A56E2), // Button Text Color
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}


class AdminLoginScreenHeader extends StatelessWidget {
  const AdminLoginScreenHeader({super.key, required bool isDesktop});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          height: screenHeight * 0.16,
          width: screenWidth * 0.09,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),

            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6B8AF0), Color(0xFF8A56E2)],
            ),
          ),
          child: Center(
            child: FittedBox(
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              Text(
                'Admin Portal',
                style: TextStyle(
                  fontSize: 33,
                  letterSpacing: 2.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Elite Barber Management',

                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFFC4C8D8),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}