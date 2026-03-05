import 'package:flutter/material.dart';
import '../../widgets/account_card_widget.dart';
import '../../widgets/tutorial_showcase/custom_showcase.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  late final ShowcaseController _showcaseController;

  @override
  void initState() {
    super.initState();
    _showcaseController = ShowcaseController(
      steps: [
        ShowcaseStep(
          title: 'Account Card Overview',
          content: const Text(
            'This card displays your complete account information including your name, current balance, and loyalty points earned.',
            style: TextStyle(fontSize: 14.0, height: 1.5),
          ),
          placement: ShowcasePlacement.below,
        ),
        ShowcaseStep(
          title: 'Current Balance',
          content: const Text(
            'Your current account balance is displayed prominently. This is the amount of funds available in your account.',
            style: TextStyle(fontSize: 14.0, height: 1.5),
          ),
          placement: ShowcasePlacement.rightOf,
        ),
        ShowcaseStep(
          title: 'Cumulative Points',
          content: const Text(
            'Track your total loyalty points earned through various activities and transactions. Use these points for rewards and special benefits.',
            style: TextStyle(fontSize: 14.0, height: 1.5),
          ),
          placement: ShowcasePlacement.rightOf,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _showcaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example Page')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showcaseController.start(context),
        icon: const Icon(Icons.help_outline_rounded),
        label: const Text('Tutorial'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomShowcase(
              controller: _showcaseController,
              stepIndex: 0,
              child: AccountCard(
                accountName: 'John Doe',
                balance: 5250.75,
                cumulativePoints: 12500,
                showcaseController: _showcaseController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
