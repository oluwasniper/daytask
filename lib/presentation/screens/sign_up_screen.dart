import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final scaffoldBackgroundColor = Color(0xff202832);
final textFieldColor = Color(0xff8CAAB9);
final formFieldColor = Color(0xff455A64);
const space = SizedBox(height: 20);

bool? _acceptedTerms = false;

@RoutePage()
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize any necessary data or state here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  height: 90,
                  width: double.infinity,
                  child: Image(image: AssetImage('assets/images/logoup.png')),
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create your account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Full Name',
                      style: TextStyle(color: (textFieldColor), fontSize: 16),
                    ),
                    space,
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: formFieldColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.white),
                        hintText: 'Enter your full name',
                      ),
                    ),
                    space,
                    Text(
                      'Email Address',
                      style: TextStyle(color: (formFieldColor), fontSize: 16),
                    ),
                    space,
                    TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xff455A64),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(
                          Icons.verified_user,
                          color: Colors.white,
                        ),
                        hintText: 'Enter your email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    space,
                    Text(
                      'Password',
                      style: TextStyle(color: (textFieldColor), fontSize: 16),
                    ),
                    space,
                    TextFormField(
                      obscureText: true,
                      obscuringCharacter: '*',
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: formFieldColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.white),
                        hintText: 'Enter your password',
                      ),
                    ),
                    space,
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptedTerms ?? false,
                          onChanged: (value) {
                            setState(() {
                              _acceptedTerms = value!;
                            });
                          },
                          activeColor: Color(0xffFED36A),
                          checkColor: Colors.white,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Show terms and conditions dialog or navigate to terms page
                            },
                            child: Text(
                              'I agree to the Terms and Conditions',
                              style: TextStyle(
                                color: textFieldColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffFED36A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        minimumSize: Size(double.infinity, 70),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {},
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(color: Colors.white, thickness: 1),
                    space,
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff455A64),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        minimumSize: Size(double.infinity, 70),
                      ),
                      onPressed: () {
                        // TODO: Implement Google sign-in
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(image: AssetImage('assets/images/google.png')),
                          SizedBox(width: 5),
                          Text(
                            'Google',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    space,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(color: formFieldColor, fontSize: 16),
                        ),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            context.router
                                .pop(); // Navigate back to sign-in screen
                          },
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              color: Color(0xffFED36A),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
