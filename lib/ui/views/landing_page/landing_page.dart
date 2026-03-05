import 'package:fe_poc_tutorial_showcase/ui/widgets/quick_action_panel.dart';
import 'package:fe_poc_tutorial_showcase/ui/widgets/tutorial_showcase/custom_showcase.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late final ShowcaseController _showcaseController = ShowcaseController(
    steps: [
      ShowcaseStep(
        title: 'Menu 1',
        description: 'แตะที่นี่เพื่อเข้าถึง Menu 1 และตัวเลือกที่มีให้บริการ',
        placement: ShowcasePlacement.below,
      ),
      ShowcaseStep(
        title: 'Menu 2',
        description: 'Menu 2 ใช้สำหรับดำเนินการ Quick Action ได้อย่างรวดเร็ว',
        placement: ShowcasePlacement.below,
      ),
      ShowcaseStep(
        title: 'Menu 3',
        description: 'Menu 3 มี Shortcut สำหรับ Workflow ของคุณ',
        placement: ShowcasePlacement.below,
      ),
      ShowcaseStep(
        title: 'Menu 4',
        description: 'ใช้ Menu 4 เพื่อเข้าถึงฟีเจอร์ที่ใช้บ่อย',
        placement: ShowcasePlacement.below,
        tailSize: 24,
      ),
      ShowcaseStep(
        title: 'Menu 5',
        description: 'Menu 5 เป็น Quick Action สุดท้ายของคุณ ลองแตะดูได้เลย!',
        placement: ShowcasePlacement.below,
      ),
    ],
  );

  @override
  void dispose() {
    _showcaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            spacing: 8,
            children: [
              const SizedBox(height: 16),
              QuickActionPanel(showcaseController: _showcaseController),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showcaseController.start(context),
        icon: const Icon(Icons.help_outline_rounded),
        label: const Text('Tutorial'),
      ),
    );
  }
}
