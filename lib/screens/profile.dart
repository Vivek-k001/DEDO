import 'package:dedo/widgets/appbar.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: DAppBar(),
      body: Center(child: Text("Hello")),
    );
  }
}
