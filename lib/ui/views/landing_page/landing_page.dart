import 'package:fe_poc_tutorial_showcase/ui/views/example_page/example_page.dart';
import 'package:fe_poc_tutorial_showcase/ui/widgets/quick_action_panel.dart';
import 'package:fe_poc_tutorial_showcase/ui/widgets/tutorial_showcase/custom_showcase.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late final ShowcaseController _showcaseController = ShowcaseController(
    steps: [
      // Menu 1 — lottie header + text
      ShowcaseStep(
        title: 'Menu 1',
        placement: ShowcasePlacement.below,
        headerWidget: Lottie.asset(
          'assets/lottie/homepage_step_01.json',
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        content: const Text(
          'แตะที่นี่เพื่อเข้าถึง Menu 1 และตัวเลือกที่มีให้บริการ',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ),
      // Menu 2 — lottie header + icon + text row
      ShowcaseStep(
        title: 'Menu 2',
        placement: ShowcasePlacement.below,
        headerWidget: Lottie.asset(
          'assets/lottie/homepage_step_02.json',
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        content: Row(
          children: const [
            Icon(Icons.flash_on_rounded, size: 16, color: Colors.amber),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Quick Action ที่ใช้บ่อยที่สุด เข้าถึงได้ใน 1 แตะ',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
      // Menu 3 — step list
      ShowcaseStep(
        title: 'Menu 3',
        placement: ShowcasePlacement.below,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepRow(number: '1', label: 'เลือก Workflow'),
            const SizedBox(height: 4),
            _StepRow(number: '2', label: 'กำหนดค่า'),
            const SizedBox(height: 4),
            _StepRow(number: '3', label: 'บันทึกและใช้งาน'),
          ],
        ),
      ),
      // Menu 4 — highlighted badge + description (tailSize ใหญ่ขึ้น)
      ShowcaseStep(
        title: 'Menu 4',
        placement: ShowcasePlacement.below,
        tailSize: 24,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ฟีเจอร์ใหม่',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'ใช้ Menu 4 เพื่อเข้าถึงฟีเจอร์ที่ใช้บ่อยได้รวดเร็วขึ้น',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
      // Menu 5 — tags / chips
      ShowcaseStep(
        title: 'Menu 5',
        placement: ShowcasePlacement.below,
        content: Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _TagChip(label: 'รายงาน'),
            _TagChip(label: 'สรุปผล'),
            _TagChip(label: 'Export'),
          ],
        ),
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

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExamplePage(),
                    ),
                  );
                },
                child: Text('View Example Page'),
              ),
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

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
