import 'package:auto_route/auto_route.dart';
import 'package:daytask/core/routes/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

@RoutePage()
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Color(0xff202832),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/images/upper.png',
                  width: 100,
                  height: 100,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 330,
                width: double.infinity,
                child: FlutterSplashScreen.fadeIn(
                  backgroundColor: Colors.white,
                  onInit: () {
                    debugPrint("On Init");
                  },
                  onEnd: () {
                    debugPrint("On End");
                  },
                  childWidget: SizedBox(
                    height: 330,
                    width: double.infinity,
                    child: Image.asset("assets/images/splash.png"),
                  ),
                  onAnimationEnd: () => debugPrint("On Fade In End"),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Manage',
                    style: GoogleFonts.adventPro(
                      fontSize: 55,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Text(
                    'Your ',
                    style: GoogleFonts.adventPro(
                      fontSize: 55,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Text(
                    'Tasks with ',
                    style: GoogleFonts.adventPro(
                      fontSize: 55,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Text(
                    'DayTask',
                    style: GoogleFonts.adventPro(
                      fontSize: 55,
                      fontWeight: FontWeight.normal,
                      color: Color(0xffFED36A),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity, // set your desired width
                height: 70, // set your desired height
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffFED36A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  onPressed: () {
                    context.router.push(SignInRoute());
                  },
                  child: Center(
                    child: Text(
                      'Let\'s Start',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
