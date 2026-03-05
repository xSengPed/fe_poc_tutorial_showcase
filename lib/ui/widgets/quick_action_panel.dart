import 'package:fe_poc_tutorial_showcase/ui/widgets/tutorial_showcase/custom_showcase.dart';
import 'package:flutter/material.dart';

class QuickActionPanel extends StatelessWidget {
  const QuickActionPanel({super.key, this.showcaseController});

  final ShowcaseController? showcaseController;

  Widget _createQuickActionButton({
    String title = '',
    Icon icon = const Icon(Icons.question_mark_outlined),
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          CircleAvatar(child: icon),
          Text(title),
        ],
      ),
    );
  }

  Widget _wrapShowcase(int stepIndex, Widget child) {
    final controller = showcaseController;
    if (controller == null) return child;
    return CustomShowcase(
      controller: controller,
      stepIndex: stepIndex,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Card(
        elevation: 0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _wrapShowcase(0, _createQuickActionButton(icon: const Icon(Icons.monitor), title: 'Menu 1')),
            _wrapShowcase(1, _createQuickActionButton(icon: const Icon(Icons.monitor), title: 'Menu 2')),
            _wrapShowcase(2, _createQuickActionButton(icon: const Icon(Icons.monitor), title: 'Menu 3')),
            _wrapShowcase(3, _createQuickActionButton(icon: const Icon(Icons.monitor), title: 'Menu 4')),
            _wrapShowcase(4, _createQuickActionButton(icon: const Icon(Icons.monitor), title: 'Menu 5')),
          ],
        ),
      ),
    );
  }
}
