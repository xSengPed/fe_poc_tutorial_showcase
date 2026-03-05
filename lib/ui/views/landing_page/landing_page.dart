import 'package:fe_poc_tutorial_showcase/ui/widgets/quick_action_panel.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            spacing: 8,
            children: [const SizedBox(height: 16), QuickActionPanel()],
          ),
        ),
      ),
    );
  }
}
