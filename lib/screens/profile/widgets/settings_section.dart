import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/widgets/toggle_list_tile.dart';
import 'package:flutter/material.dart';

/// A section widget for settings in the profile screen
/// This section includes a toggle for enabling/disabling dark mode.
class DSettingsSection extends StatelessWidget {
  const DSettingsSection({
    super.key,
    required this.darkModeEnabled,
    required this.onChanged,
  });

  // Local state to track whether dark mode is enabled
  final bool darkModeEnabled;

  // Callback function to handle changes in the toggle switch
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title "Settings"
        Text(
          "Settings",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: DSizes.sm),

        // Toggle for dark mode; updates the ThemeBloc when changed
        DToggleListTile(
          title: "Dark Mode",
          iconEnabled: Icons.wb_sunny,
          iconDisabled: Icons.nightlight_outlined,
          initialValue: darkModeEnabled,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
