import 'package:dedo/services/user_services.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/widgets/button.dart';
import 'package:dedo/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:dedo/app.dart';

/// Screen to collect and set the username before entering the main app.
/// Uses a form to validate user input and updates shared user state.
class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  // Controller to manage the input field for username
  final TextEditingController _controller = TextEditingController();

  // Key to access and validate the form state
  final _formKey = GlobalKey<FormState>();

  /// Validates the entered username according to length constraints.
  /// Ensures the name is not empty, not too short, and not too long.
  /// Returns an error string if invalid, else null.
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name too short (min 2 characters)';
    }
    if (value.trim().length > 30) {
      return 'Name too long (max 30 characters)';
    }
    return null;
  }

  /// Handles form submission:
  /// - Validates input using the form key
  /// - If valid, updates the global username in UserService
  /// - Navigates to the main app screen, replacing current screen
  void _submitName() {
    if (_formKey.currentState!.validate()) {
      UserService.username = _controller.text.trim();

      // Using pushReplacement to prevent going back to username screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyApp()),
      );
    }
  }

  @override
  void dispose() {
    // Dispose the controller to free up resources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Dismiss keyboard when tapping outside input
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSizes.md),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: DSizes.md),

                  // Display app logo to reinforce branding
                  Image.asset('assets/logos/app_splash_logo.png', height: 300),
                  SizedBox(height: DSizes.md),

                  // Welcoming headline, styled with app theme and accent color
                  Text(
                    "Welcome to Dedo!",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                  SizedBox(height: DSizes.sm),

                  // Prompt to guide user to enter their name
                  Text(
                    "What should we call you?",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: DSizes.md),

                  // Input field for username with validation and styling
                  DTextFormField(
                    controller: _controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submitName(),
                    maxLength: 30,
                    validator: _validateName,
                    hintText: "Enter your name",
                    fillColor: Theme.of(context).cardColor,
                    prefixIcon: Icons.person_outline,
                    title: '',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DSizes.md,
                      vertical: DSizes.md + DSizes.xs,
                    ),
                  ),
                  SizedBox(height: DSizes.md),

                  // Submit button spans full width, with elevated styling
                  DButton(
                    onTap: _submitName,
                    btnTitle: "Continue",
                    width: double.infinity,
                    height: 50,
                    btnColor: DColors.primary,
                    textColor: Colors.white,
                    borderRadius: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
