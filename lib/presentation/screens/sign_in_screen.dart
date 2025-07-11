import 'package:auto_route/auto_route.dart';
import 'package:daytask/core/routes/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

final scaffoldBackgroundColor = Color(0xff202832);

@RoutePage()
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      messenger.showSnackBar(
        SnackBar(content: Text('Signed in as ${credential.user?.email ?? ''}')),
      );
      // Navigate to home or next screen here
      if (!mounted) return;
      context.router.replace(HomeRoute());
    } on FirebaseAuthException catch (e) {
      String message = 'Sign in failed';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else {
        message = e.message ?? message;
      }
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          wordSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Email Address',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Color(0xff8CAAB9),
                        ),
                      ),
                      SizedBox(height: 10),
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
                      SizedBox(height: 20),
                      Text(
                        'Password',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Color(0xff8CAAB9),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        obscureText: _obscurePassword,
                        obscuringCharacter: '*',
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.inter(color: Colors.white),
                          filled: true,
                          fillColor: Color(0xff455A64),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.lock, color: Colors.white),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          hintText: 'Enter your password',
                        ),
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Implement forgot password
                          },
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Color(0xff8CAAB9),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffFED36A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          minimumSize: Size(double.infinity, 70),
                        ),
                        onPressed: _isLoading ? null : _handleSignIn,
                        child: _isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              )
                            : Center(
                                child: Text(
                                  'Log In',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(height: 20),
                      Divider(color: Color(0xff8CAAB9)),
                      SizedBox(height: 20),
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
                            Image(
                              image: AssetImage('assets/images/google.png'),
                            ),
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
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account?',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: Navigate to sign up screen
                              context.router.push(SignUpRoute());
                            },
                            child: Text(
                              ' Sign Up',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffFED36A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
