import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/button.dart';
import 'package:dedo/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:dedo/services/user_services.dart';

/// A dialog widget that allows users to edit and save their username.
/// Uses a form with validation to ensure input correctness.
/// On successful submission, updates the username in the UserService.
class UsernameDialog extends StatefulWidget {
  const UsernameDialog({super.key});

  @override
  State<UsernameDialog> createState() => _UsernameDialogState();
}

class _UsernameDialogState extends State<UsernameDialog> {
  // Form key to manage form state and validation
  final _formKey = GlobalKey<FormState>();

  // Controller for the username text field, initialized with current username
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller with the existing username so user can edit it
    _controller = TextEditingController(text: UserService.username);
  }

  /// Validates the username input according to the rules:
  /// - Must not be empty or whitespace only
  /// - Minimum length of 2 characters
  /// - Maximum length of 30 characters
  ///
  /// Returns an error message string if invalid, or null if valid.
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
    return null; // valid input
  }

  /// Handles form submission.
  /// Validates the form, updates the username in the UserService if valid,
  /// and closes the dialog returning true to indicate success.
  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Save trimmed username
      UserService.username = _controller.text.trim();
      // Close dialog and notify caller of successful save
      Navigator.of(context).pop(true);
    }
    // If invalid, the form will show validation errors automatically
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return Dialog(
      // Rounded corners and some elevation for a floating card effect
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      insetPadding: const EdgeInsets.all(24), // padding from screen edges
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min, // shrink dialog height to fit content
          children: [
            // Dialog title with emphasized styling
            Text(
              'Edit Username',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: DSizes.sm),

            // Form wraps the input field to enable validation
            Form(
              key: _formKey,
              child: DTextFormField(
                controller: _controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                maxLength: 30,
                validator: _validateName,
                hintText: 'Enter your name',
                prefixIcon: Icons.person_outline,
                fillColor: Theme.of(context).cardColor,
                onFieldSubmitted: (_) => _submit(),
                title: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: DSizes.md,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: DSizes.md),

            // Action buttons row: Cancel and Save
            Row(
              children: [
                Expanded(
                  child: DButton(
                    onTap: () => Navigator.of(context).pop(false),
                    btnTitle: 'Cancel',
                    width: double.infinity,
                    btnColor: isDark ? DColors.darkerGrey : DColors.white,
                    textColor: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: DSizes.sm),

                Expanded(
                  child: DButton(
                    onTap: _submit,
                    btnTitle: 'Save',
                    width: double.infinity,
                    btnColor: DColors.primary,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
