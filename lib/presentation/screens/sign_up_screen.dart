import 'package:auto_route/auto_route.dart';
import 'package:daytask/core/routes/app_router.gr.dart';
import 'package:daytask/providers/auth_provider.dart';
import 'package:daytask/providers/note_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// --- Constants (consider moving to a theme or constants file) ---
final Color scaffoldBackgroundColor = const Color(0xff202832);
final Color textFieldColor = const Color(0xff8CAAB9);
final Color formFieldColor = const Color(0xff455A64);
final Color accentColor = const Color(
  0xffFED36A,
); // Defined once for consistency

// --- SignUpScreen Widget ---
@RoutePage()
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

// --- _SignUpScreenState ---
class _SignUpScreenState extends State<SignUpScreen> {
  // --- Text Editing Controllers ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // --- State Variables ---
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Event Handlers ---

  Future<void> _handleSignUp() async {
    // 1. Validate Form & Terms
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      _showSnackBar(
        'Please accept the Terms and Conditions to continue',
        Colors.orange,
      );
      return;
    }

    // 2. Get Providers (listen: false as we're performing actions)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    // Clear any previous errors before starting new operation
    authProvider.clearError();

    // 3. Password Match Check
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', Colors.red);
      return;
    }

    // 4. Attempt Sign Up
    final success = await authProvider.register(
      // Using 'register' as per previous discussion
      _fullNameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    // 5. Check mounted state after async operation
    if (!mounted) return;

    // 6. Handle Sign Up Result
    if (success) {
      // Load user's notes after successful signup (if applicable)
      await noteProvider
          .fetchNotes(); // Assuming NoteProvider.fetchNotes() is implemented

      if (!mounted) return; // Check again after fetching notes

      _showSnackBar(
        'Welcome ${authProvider.user?.name ?? _fullNameController.text}! Account created successfully.',
        accentColor,
      );

      // Navigate to home screen and clear the navigation stack
      context.router.pushAndPopUntil(HomeRoute(), predicate: (_) => false);
    } else {
      // Error message is handled by AuthProvider and displayed in UI Consumer
      _showSnackBar(authProvider.error ?? 'Sign up failed', Colors.red);
    }
  }

  Future<void> _handleGoogleSignUp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Removed noteProvider here as it's not directly needed for initiating Google sign-up flow
    // final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    authProvider.clearError(); // Clear previous errors

    // Placeholder for Google Sign-Up functionality
    _showSnackBar('Google Sign-Up coming soon!', Colors.blue);

    // Uncomment and implement when googleSignUp is available in AuthProvider:
    // final success = await authProvider.googleSignUp();
    // if (!mounted) return;
    // if (success) {
    //   await noteProvider.fetchNotes();
    //   if (!mounted) return;
    //   _showSnackBar('Welcome ${authProvider.user?.name}! Account created with Google.', accentColor);
    //   context.router.pushAndPopUntil(HomeRoute(), predicate: (_) => false);
    // } else {
    //   _showSnackBar(authProvider.error ?? 'Google Sign-Up failed', Colors.red);
    // }
  }

  // Helper method for showing SnackBars
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: formFieldColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Terms and Conditions',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                  style: GoogleFonts.inter(
                    color: textFieldColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '• Your personal information will be handled securely\n'
                  '• We respect your privacy and data protection rights\n'
                  '• You can delete your account at any time\n'
                  '• We do not share your data with third parties',
                  style: GoogleFonts.inter(
                    color: textFieldColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.inter(
                  color: accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Section
              Center(
                child: SizedBox(
                  height: 90,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/logoup.png', // Use Image.asset
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Text(
                            'Create your account',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              wordSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join us and start your journey',
                            style: GoogleFonts.inter(
                              color: textFieldColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Error Message Display
                          if (authProvider.error != null)
                            _buildErrorMessage(authProvider),

                          // Full Name Field
                          _buildTextFieldLabel('Full Name'),
                          const SizedBox(height: 10),
                          _buildTextFormField(
                            controller: _fullNameController,
                            enabled: !authProvider.isLoading,
                            hintText: 'Enter your full name',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your full name';
                              }
                              if (value.trim().length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),

                          // Email Field
                          _buildTextFieldLabel('Email Address'),
                          const SizedBox(height: 10),
                          _buildTextFormField(
                            controller: _emailController,
                            enabled: !authProvider.isLoading,
                            hintText: 'Enter your email address',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email address';
                              }
                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(value.trim())) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          _buildTextFieldLabel('Password'),
                          const SizedBox(height: 10),
                          _buildTextFormField(
                            controller: _passwordController,
                            enabled: !authProvider.isLoading,
                            hintText: 'Enter your password',
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            obscuringCharacter: '*',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.white,
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),

                          // Confirm Password Field
                          _buildTextFieldLabel('Confirm Password'),
                          const SizedBox(height: 10),
                          _buildTextFormField(
                            controller: _confirmPasswordController,
                            enabled: !authProvider.isLoading,
                            hintText: 'Confirm your password',
                            icon: Icons.lock_outline,
                            obscureText: _obscureConfirmPassword,
                            obscuringCharacter: '*',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.white,
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) =>
                                authProvider.isLoading ? null : _handleSignUp(),
                          ),
                          const SizedBox(height: 20),

                          // Terms and Conditions Checkbox
                          _buildTermsAndConditions(authProvider),
                          const SizedBox(height: 30),

                          // Sign Up Button
                          _buildSignUpButton(authProvider),
                          const SizedBox(height: 20),

                          // Divider with "OR"
                          _buildOrDivider(),
                          const SizedBox(height: 20),

                          // Google Sign Up Button
                          _buildGoogleSignUpButton(authProvider),
                          const SizedBox(height: 30),

                          // Sign In Link
                          _buildSignInLink(authProvider),
                          const SizedBox(height: 20),
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

  // --- Widget Builders (extracted for readability) ---

  Widget _buildErrorMessage(AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              authProvider.error!,
              style: GoogleFonts.inter(color: Colors.red, fontSize: 14),
            ),
          ),
          IconButton(
            onPressed: authProvider.clearError,
            icon: const Icon(Icons.close, color: Colors.red, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textFieldColor,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required bool enabled,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String obscuringCharacter = '•',
    String? Function(String?)? validator,
    Widget? suffixIcon,
    TextInputAction textInputAction = TextInputAction.done,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      obscureText: obscureText,
      obscuringCharacter: obscuringCharacter,
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled ? formFieldColor : formFieldColor.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: GoogleFonts.inter(color: Colors.white60),
      ),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
    );
  }

  Widget _buildTermsAndConditions(AuthProvider authProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptedTerms,
          onChanged: authProvider.isLoading
              ? null
              : (value) {
                  setState(() {
                    _acceptedTerms = value ?? false;
                  });
                },
          activeColor: accentColor,
          checkColor: Colors.black,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Expanded(
          child: GestureDetector(
            onTap: authProvider.isLoading ? null : _showTermsDialog,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    color: authProvider.isLoading
                        ? textFieldColor.withOpacity(0.5)
                        : textFieldColor,
                    fontSize: 14,
                  ),
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: GoogleFonts.inter(
                        color: authProvider.isLoading
                            ? accentColor.withOpacity(0.5)
                            : accentColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(AuthProvider authProvider) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: authProvider.isLoading
            ? accentColor.withOpacity(0.7)
            : accentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(double.infinity, 56),
        elevation: authProvider.isLoading ? 0 : 2,
      ),
      onPressed: authProvider.isLoading ? null : _handleSignUp,
      child: authProvider.isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : Text(
              'Create Account',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: textFieldColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: GoogleFonts.inter(color: textFieldColor, fontSize: 14),
          ),
        ),
        Expanded(child: Divider(color: textFieldColor)),
      ],
    );
  }

  Widget _buildGoogleSignUpButton(AuthProvider authProvider) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: formFieldColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(double.infinity, 56),
        side: const BorderSide(color: Colors.white24, width: 1),
      ),
      onPressed: authProvider.isLoading ? null : _handleGoogleSignUp,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            // Use Image.asset
            'assets/images/google.png',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 12),
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
    );
  }

  Widget _buildSignInLink(AuthProvider authProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
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
                  context.router
                      .pop(); // Go back to the previous screen (SignIn)
                },
          child: Text(
            ' Sign In',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: authProvider.isLoading
                  ? accentColor.withOpacity(0.5)
                  : accentColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
