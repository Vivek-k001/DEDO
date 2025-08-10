import 'dart:ui';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

// A reusable widget that displays app information like name, version, description, etc.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main container with glassmorphism-style effect
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.9),
                DColors.primary.withOpacity(0.1), // Slight app tint
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 6), // Drop shadow effect
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Apply blur
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section title
                    Text(
                      "About",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: DSizes.sm),

                    // Information tiles
                    _aboutTile(
                      context,
                      icon: Icons.apps_rounded,
                      title: "App Name",
                      value: "Dedo",
                    ),
                    _divider(),

                    _aboutTile(
                      context,
                      icon: Icons.system_update_alt_rounded,
                      title: "Version",
                      value: "1.0.0",
                    ),
                    _divider(),

                    _aboutTile(
                      context,
                      icon: Icons.description_rounded,
                      title: "Description",
                      value:
                          "Dedo is a sleek task management app built to organize tasks, track progress, and boost productivity.",
                    ),
                    _divider(),

                    _aboutTile(
                      context,
                      icon: Icons.person_rounded,
                      title: "Developed by",
                      value: "VNJ Softworks",
                    ),
                    _divider(),

                    _aboutTile(
                      context,
                      icon: Icons.support_agent_rounded,
                      title: "Support & Feedback",
                      value: "sdedodedo80@gmail.com",
                      isLink: true, // Makes it tappable to copy
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Optional shimmer effect overlay for subtle motion
        Positioned.fill(
          child: IgnorePointer(
            child: Shimmer.fromColors(
              baseColor: Colors.transparent,
              highlightColor: Colors.white.withOpacity(0.3),
              period: const Duration(seconds: 10),
              direction: ShimmerDirection.ltr,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Reusable divider between items
  static Widget _divider() =>
      const Divider(height: 20, thickness: 0.6, color: Colors.grey);

  // Widget that displays a single row with an icon, title and value
  static Widget _aboutTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isLink = false, // If true, value is tappable and copyable
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon for the tile
        Icon(icon, size: 24, color: Colors.blueAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title text (e.g., App Name)
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),

              // Value text, optionally copyable
              isLink
                  ? Tooltip(
                    message: "Tap to copy email", // Tooltip on hover/tap
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: value),
                        ); // Copy to clipboard
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                        value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  )
                  : Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
