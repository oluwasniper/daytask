import 'package:auto_route/auto_route.dart';
import 'package:daytask/core/routes/app_router.gr.dart';
import 'package:daytask/providers/auth_provider.dart';
import 'package:daytask/providers/note_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    // Clear any previous errors
    authProvider.clearError();

    final success = await authProvider.login(
      emailController.text.trim(),
      passwordController.text,
    );

    if (!mounted) return; // Check if the widget is still in the tree

    if (success) {
      // Load user's notes after successful login
      // NOTE: Ensure your NoteProvider has a fetchNotes method
      await noteProvider.fetchNotes();

      if (!mounted) return; // Check again after fetching notes

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${authProvider.user?.name ?? 'User'}!'),
          backgroundColor: Color(0xffFED36A),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to home screen and clear the navigation stack
      context.router.pushAndPopUntil(
        HomeRoute(),
        predicate: (_) => false, // This will clear the entire stack
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email address to reset password'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError(); // Clear any existing errors

    // Check if the authProvider is currently loading (e.g., from a previous action)
    if (authProvider.isLoading) {
      return; // Prevent multiple requests
    }

    final success = await authProvider.forgotPassword(email);

    if (!mounted) return; // Check if the widget is still in the tree

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $email'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to send reset email.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Form(
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

                          // Show error message if present
                          if (authProvider.error != null) ...[
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authProvider.error!,
                                      style: GoogleFonts.inter(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: authProvider.clearError,
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          ],

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
                            enabled: !authProvider.isLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: authProvider.isLoading
                                  ? Color(0xff455A64).withOpacity(0.5)
                                  : Color(0xff455A64),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.white,
                              ),
                              hintText: 'Enter your email',
                              hintStyle: GoogleFonts.inter(
                                color: Colors.white60,
                              ),
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
                          SizedBox(height: 10),
                          TextFormField(
                            controller: passwordController,
                            enabled: !authProvider.isLoading,
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
                              labelStyle: GoogleFonts.inter(
                                color: Colors.white,
                              ),
                              filled: true,
                              fillColor: authProvider.isLoading
                                  ? Color(0xff455A64).withOpacity(0.5)
                                  : Color(0xff455A64),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.white,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                              ),
                              hintText: 'Enter your password',
                              hintStyle: GoogleFonts.inter(
                                color: Colors.white60,
                              ),
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            onFieldSubmitted: (_) =>
                                authProvider.isLoading ? null : _handleSignIn(),
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: GestureDetector(
                              onTap: authProvider.isLoading
                                  ? null
                                  : _handleForgotPassword,
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: authProvider.isLoading
                                      ? Color(0xff8CAAB9).withOpacity(0.5)
                                      : Color(0xff8CAAB9),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: authProvider.isLoading
                                  ? Color(0xffFED36A).withOpacity(0.7)
                                  : Color(0xffFED36A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: Size(double.infinity, 56),
                              elevation: authProvider.isLoading ? 0 : 2,
                            ),
                            onPressed: authProvider.isLoading
                                ? null
                                : _handleSignIn,
                            child: authProvider.isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Log In',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                          SizedBox(height: 20),

                          // Divider with "OR"
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: Color(0xff8CAAB9)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: GoogleFonts.inter(
                                    color: Color(0xff8CAAB9),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: Color(0xff8CAAB9)),
                              ),
                            ],
                          ),

                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff455A64),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: Size(double.infinity, 56),
                              side: BorderSide(color: Colors.white24, width: 1),
                            ),
                            onPressed: authProvider.isLoading
                                ? null
                                : () {
                                    // TODO: Implement Google sign-in
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Google Sign-In coming soon!',
                                        ),
                                        backgroundColor: Colors.blue,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage('assets/images/google.png'),
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
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
                                onTap: authProvider.isLoading
                                    ? null
                                    : () {
                                        context.router.push(SignUpRoute());
                                      },
                                child: Text(
                                  ' Sign Up',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: authProvider.isLoading
                                        ? Color(0xffFED36A).withOpacity(0.5)
                                        : Color(0xffFED36A),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
