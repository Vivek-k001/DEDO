import 'package:dedo/bloc/theme/theme_bloc.dart';
import 'package:dedo/screens/category/category.dart';
import 'package:dedo/services/notification_service.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/text.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/appbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DHomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  const DHomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return DAppBar(
      title: Text(
        DTexts.appName,
        style: Theme.of(context).textTheme.headlineMedium,
      ),

      actions: [
        /// Theme Switcher
        BlocBuilder<ThemeBloc, ThemeMode>(
          builder: (context, state) {
            return IconButton(
              icon: Icon(
                state == ThemeMode.dark
                    ? Icons.nightlight_round
                    : Icons.wb_sunny,
                color: state == ThemeMode.dark ? DColors.light : DColors.dark,
              ),
              onPressed: () async {
                context.read<ThemeBloc>().add(
                  ThemeChangedEvent(state == ThemeMode.dark ? false : true),
                );
                final allowed =
                    await NotificationService().requestNotificationPermission();
                if (allowed) {
                  NotificationService().showNotification(
                    id: 1,
                    title: "Theme Changed",
                    body:
                        state == ThemeMode.dark
                            ? "Switched to light mode"
                            : "Switched to dark mode",
                  );
                } else {
                  if (kDebugMode) {
                    print("Notification permission denied");
                  }
                  await NotificationService().requestNotificationPermission();
                }
              },
            );
          },
        ),

        /// Profile Icon
        IconButton(
          icon: Icon(
            Icons.category_sharp,
            color: isDark ? DColors.light : DColors.dark,
          ),
          onPressed: () {
            DHelperFunctions.navigateToScreen(context, CategoryScreen());
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
