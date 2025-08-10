import 'package:dedo/screens/profile/widgets/username_dialog.dart';
import 'package:dedo/services/user_services.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class DProfileHeader extends StatefulWidget {
  const DProfileHeader({super.key});

  @override
  State<DProfileHeader> createState() => _DProfileHeaderState();
}

class _DProfileHeaderState extends State<DProfileHeader> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? const Color(0xFF939EFF) : Colors.black;

    return Column(
      children: [
        // profile picture (CircleAvatar)
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage("assets/images/dp.png"),
        ),
        const SizedBox(height: DSizes.sm),

        // Display username from UserService
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              UserService.username,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(width: DSizes.xs),

            IconButton(
              icon: Icon(Icons.edit, size: 16, color: iconColor),
              onPressed: () async {
                final changed = await showDialog<bool>(
                  context: context,
                  builder: (_) => const UsernameDialog(),
                );

                if (changed == true) {
                  setState(() {});
                }
              },
              tooltip: 'Edit Profile',
            ),
          ],
        ),
      ],
    );
  }
}
