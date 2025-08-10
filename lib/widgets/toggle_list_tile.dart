import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/container.dart';
import 'package:flutter/material.dart';

class DToggleListTile extends StatefulWidget {
  const DToggleListTile({
    super.key,
    required this.onChanged,
    this.initialValue = false,
    required this.title,
    required this.iconEnabled,
    required this.iconDisabled,
  });

  // Initial value of the toggle switch (on/off)
  final bool initialValue;

  // Title text shown beside the switch
  final String title;

  // Icon to display when toggle is enabled
  final IconData iconEnabled;

  // Icon to display when toggle is disabled
  final IconData iconDisabled;

  // Callback when toggle value changes, returns the new value (true/false)
  final Function(bool) onChanged;

  @override
  State<DToggleListTile> createState() => _DToggleListTileState();
}

class _DToggleListTileState extends State<DToggleListTile> {
  // Internal state to track whether the toggle is enabled
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    // Initialize _isEnabled from the widget's initialValue property
    _isEnabled = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // No elevation for a flat look
      elevation: 0,
      // Background color changes based on dark or light theme
      color:
          DHelperFunctions.isDarkMode(context)
              ? DColors.darkGrey
              : DColors.primary.withValues(alpha: 0.2),
      child: SwitchListTile(
        // Main title shown beside the switch
        title: Text(widget.title),

        // Subtitle text showing current toggle state as string
        subtitle: Text(_isEnabled ? 'Enabled' : 'Disabled'),

        // Current value of the switch
        value: _isEnabled,

        // Callback when switch toggled; update internal state and notify parent
        onChanged: (value) {
          setState(() => _isEnabled = value);
          widget.onChanged(value);
        },

        // Secondary widget shown at start of the tile (circle with icon)
        secondary: DContainer(
          // Background color of circle changes based on toggle state
          backgroundColor: _isEnabled ? DColors.primary : Colors.grey,
          shape: BoxShape.circle,
          padding: const EdgeInsets.all(DSizes.sm),

          // Icon changes based on toggle state
          child: Icon(
            _isEnabled ? widget.iconEnabled : widget.iconDisabled,
            // Icon color green if enabled, white if disabled
            color: _isEnabled ? Colors.black : Colors.white,
          ),
        ),

        // Color of the toggle thumb when active
        activeColor: DColors.primary,

        // Color of the toggle track when active (slightly transparent)
        activeTrackColor: DColors.primary.withValues(alpha: 0.5),

        // Color of toggle thumb when inactive
        inactiveThumbColor: Colors.grey,

        // Color of toggle track when inactive (slightly transparent)
        inactiveTrackColor: Colors.grey.withValues(alpha: 0.5),
      ),
    );
  }
}
