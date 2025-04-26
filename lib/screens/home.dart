import 'package:dedo/bloc/theme_bloc.dart';
import 'package:dedo/utils/constants/text.dart';
import 'package:dedo/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DAppBar(
        title: Text(DTexts.appName),
        actions: [
          BlocBuilder<ThemeBloc, ThemeMode>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state == ThemeMode.dark
                      ? Icons.nightlight_round
                      : Icons.wb_sunny,
                  color: state == ThemeMode.dark ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  context.read<ThemeBloc>().add(
                    ThemeChangedEvent(state == ThemeMode.dark ? false : true),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(child: Text("Home Page")),
    );
  }
}
