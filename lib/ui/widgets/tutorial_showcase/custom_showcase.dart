import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums & Models
// ─────────────────────────────────────────────────────────────────────────────

/// Position of the balloon relative to the target widget.
/// The tail always points from the balloon toward the target.
///
/// - [above]   → balloon above target, tail points downward
/// - [below]   → balloon below target, tail points upward
/// - [leftOf]  → balloon left of target, tail points right
/// - [rightOf] → balloon right of target, tail points left
enum ShowcasePlacement { above, below, leftOf, rightOf }

/// Represents one step in the tutorial showcase sequence.
class ShowcaseStep {
  ShowcaseStep({
    required this.title,
    required this.content,
    this.placement = ShowcasePlacement.below,
    this.tailSize = 16.0,
  });

  final String title;

  /// Custom widget displayed in the balloon body below the title.
  /// Can be any widget — Text, Column, Image, Lottie, etc.
  final Widget content;

  /// Preferred placement of the balloon relative to the target widget.
  final ShowcasePlacement placement;

  /// Height/width of the triangular tail. Can be adjusted per step.
  final double tailSize;

  /// Internal key used to locate the target widget on screen.
  final GlobalKey _widgetKey = GlobalKey();

  GlobalKey get widgetKey => _widgetKey;
}

// ─────────────────────────────────────────────────────────────────────────────
// ShowcaseController
// ─────────────────────────────────────────────────────────────────────────────

/// Controls the lifecycle of the tutorial showcase.
///
/// Usage:
/// ```dart
/// final controller = ShowcaseController(steps: [...]);
///
/// // Start from step 0
/// controller.start(context);
///
/// // Advance to next step (closes when on last step)
/// controller.next();
///
/// // Close all tutorials
/// controller.close();
/// ```
class ShowcaseController extends ChangeNotifier {
  ShowcaseController({required this.steps});

  final List<ShowcaseStep> steps;

  int _currentIndex = -1;
  bool _isActive = false;
  OverlayEntry? _overlayEntry;

  bool get isActive => _isActive;
  int get currentIndex => _currentIndex;
  int get totalSteps => steps.length;
  bool get isLastStep => _currentIndex == steps.length - 1;
  ShowcaseStep? get currentStep =>
      (_isActive && _currentIndex >= 0) ? steps[_currentIndex] : null;

  void start(BuildContext context) {
    if (steps.isEmpty) return;
    _currentIndex = 0;
    _isActive = true;
    _overlayEntry = OverlayEntry(
      builder: (_) => ListenableBuilder(
        listenable: this,
        builder: (ctx, _) => _ShowcaseOverlay(controller: this),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    notifyListeners();
  }

  void next() {
    if (isLastStep) {
      close();
      return;
    }
    _currentIndex++;
    notifyListeners();
  }

  void close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isActive = false;
    _currentIndex = -1;
    notifyListeners();
  }

  @override
  void dispose() {
    close();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomShowcase Wrapper Widget
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps a [child] widget and registers it as a tutorial target.
///
/// The [stepIndex] must match the position of the [ShowcaseStep] in
/// [ShowcaseController.steps].
///
/// Example:
/// ```dart
/// CustomShowcase(
///   controller: _showcaseController,
///   stepIndex: 0,
///   child: MyWidget(),
/// )
/// ```
class CustomShowcase extends StatelessWidget {
  const CustomShowcase({
    super.key,
    required this.controller,
    required this.stepIndex,
    required this.child,
  });

  final ShowcaseController controller;
  final int stepIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: controller.steps[stepIndex].widgetKey,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Overlay Widget (private)
// ─────────────────────────────────────────────────────────────────────────────

class _ShowcaseOverlay extends StatelessWidget {
  const _ShowcaseOverlay({required this.controller});

  final ShowcaseController controller;

  Rect? _getTargetRect(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;
    final offset = renderBox.localToGlobal(Offset.zero);
    return offset & renderBox.size;
  }

  ShowcasePlacement _resolveActualPlacement(
    ShowcasePlacement preferred,
    Rect target,
    Size screen,
  ) {
    const minSpace = 160.0;
    switch (preferred) {
      case ShowcasePlacement.above:
        if (target.top > minSpace) return ShowcasePlacement.above;
        if (screen.height - target.bottom > minSpace) {
          return ShowcasePlacement.below;
        }
        return ShowcasePlacement.below;
      case ShowcasePlacement.below:
        if (screen.height - target.bottom > minSpace) {
          return ShowcasePlacement.below;
        }
        if (target.top > minSpace) return ShowcasePlacement.above;
        return ShowcasePlacement.above;
      case ShowcasePlacement.leftOf:
        if (target.left > minSpace) return ShowcasePlacement.leftOf;
        if (screen.width - target.right > minSpace) {
          return ShowcasePlacement.rightOf;
        }
        return ShowcasePlacement.below;
      case ShowcasePlacement.rightOf:
        if (screen.width - target.right > minSpace) {
          return ShowcasePlacement.rightOf;
        }
        if (target.left > minSpace) return ShowcasePlacement.leftOf;
        return ShowcasePlacement.below;
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = controller.currentStep;
    if (step == null) return const SizedBox.shrink();

    final targetRect = _getTargetRect(step.widgetKey);
    if (targetRect == null) return const SizedBox.shrink();

    final screenSize = MediaQuery.of(context).size;
    final placement = _resolveActualPlacement(
      step.placement,
      targetRect,
      screenSize,
    );

    const edgePadding = 16.0;
    final balloonWidth = screenSize.width - edgePadding * 2;
    const balloonContentHeight = 120.0;
    final tailSize = step.tailSize;

    double left, top, tailOffset;

    switch (placement) {
      case ShowcasePlacement.above:
        left = edgePadding;
        top = targetRect.top - balloonContentHeight - tailSize - edgePadding;
        tailOffset = (targetRect.center.dx - left).clamp(
          tailSize * 2,
          balloonWidth - tailSize * 2,
        );
        break;

      case ShowcasePlacement.below:
        left = edgePadding;
        top = targetRect.bottom + edgePadding;
        tailOffset = (targetRect.center.dx - left).clamp(
          tailSize * 2,
          balloonWidth - tailSize * 2,
        );
        break;

      case ShowcasePlacement.leftOf:
        left = targetRect.left - balloonWidth - tailSize - edgePadding;
        top = (targetRect.center.dy - (balloonContentHeight + tailSize) / 2)
            .clamp(
              edgePadding,
              screenSize.height - balloonContentHeight - tailSize - edgePadding,
            );
        tailOffset = (targetRect.center.dy - top).clamp(
          tailSize * 2,
          balloonContentHeight - tailSize * 2,
        );
        break;

      case ShowcasePlacement.rightOf:
        left = targetRect.right + edgePadding;
        top = (targetRect.center.dy - (balloonContentHeight + tailSize) / 2)
            .clamp(
              edgePadding,
              screenSize.height - balloonContentHeight - tailSize - edgePadding,
            );
        tailOffset = (targetRect.center.dy - top).clamp(
          tailSize * 2,
          balloonContentHeight - tailSize * 2,
        );
        break;
    }

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Darkened backdrop with spotlight cutout around target
          // AbsorbPointer prevents taps from passing through to widgets below
          // without triggering any action (overlay cannot be dismissed by tapping backdrop)
          AbsorbPointer(
            child: CustomPaint(
              painter: _SpotlightPainter(targetRect: targetRect.inflate(6)),
              size: screenSize,
            ),
          ),
          // Chat balloon positioned relative to target
          Positioned(
            left: left,
            top: top,
            width: balloonWidth,
            child: _ChatBalloon(
              placement: placement,
              tailSize: tailSize,
              tailOffset: tailOffset,
              title: step.title,
              content: step.content,
              currentStep: controller.currentIndex + 1,
              totalSteps: controller.totalSteps,
              isLastStep: controller.isLastStep,
              onNext: controller.next,
              onClose: controller.close,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Spotlight Painter (private)
// ─────────────────────────────────────────────────────────────────────────────

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({required this.targetRect});

  final Rect targetRect;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.65);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(targetRect, const Radius.circular(8)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.targetRect != targetRect;
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat Balloon Widget (private)
// ─────────────────────────────────────────────────────────────────────────────

class _ChatBalloon extends StatelessWidget {
  const _ChatBalloon({
    required this.placement,
    required this.tailSize,
    required this.tailOffset,
    required this.title,
    required this.content,
    required this.currentStep,
    required this.totalSteps,
    required this.isLastStep,
    required this.onNext,
    required this.onClose,
  });

  final ShowcasePlacement placement;
  final double tailSize;
  final double tailOffset;
  final String title;
  final Widget content;
  final int currentStep;
  final int totalSteps;
  final bool isLastStep;
  final VoidCallback onNext;
  final VoidCallback onClose;

  EdgeInsets get _contentPadding {
    const base = 12.0;
    switch (placement) {
      case ShowcasePlacement.above:
        // Tail at bottom → extra padding at bottom
        return EdgeInsets.fromLTRB(base, base, base, base + tailSize);
      case ShowcasePlacement.below:
        // Tail at top → extra padding at top
        return EdgeInsets.fromLTRB(base, base + tailSize, base, base);
      case ShowcasePlacement.leftOf:
        // Tail at right → extra padding at right
        return EdgeInsets.fromLTRB(base, base, base + tailSize, base);
      case ShowcasePlacement.rightOf:
        // Tail at left → extra padding at left
        return EdgeInsets.fromLTRB(base + tailSize, base, base, base);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      painter: _BalloonPainter(
        placement: placement,
        tailSize: tailSize,
        tailOffset: tailOffset,
      ),
      child: Padding(
        padding: _contentPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with close button
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 6),
            // Custom content widget
            content,
            // const SizedBox(height: 10),
            // Footer: step counter + next / done button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currentStep / $totalSteps',
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
                GestureDetector(
                  onTap: onNext,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isLastStep ? 'Done' : 'Next',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Balloon Painter (private)
// ─────────────────────────────────────────────────────────────────────────────

class _BalloonPainter extends CustomPainter {
  _BalloonPainter({
    required this.placement,
    required this.tailSize,
    required this.tailOffset,
  });

  final ShowcasePlacement placement;

  /// Size (base width / height) of the triangular tail.
  final double tailSize;

  /// Position of the tail center along the balloon edge.
  /// Horizontal offset for [above]/[below], vertical offset for [leftOf]/[rightOf].
  final double tailOffset;

  static const _backgroundColor = Colors.white;
  static const _borderRadius = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);

    // Drop shadow
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Fill
    canvas.drawPath(path, Paint()..color = _backgroundColor);
  }

  Path _buildPath(Size size) {
    final r = const Radius.circular(_borderRadius);
    final ts = tailSize;
    final to = tailOffset;
    final w = size.width;
    final h = size.height;
    final path = Path();

    switch (placement) {
      case ShowcasePlacement.above:
        // Body occupies [0 .. h-ts], tail points downward from bottom edge
        final bodyH = h - ts;
        path
          ..moveTo(_borderRadius, 0)
          ..lineTo(w - _borderRadius, 0)
          ..arcToPoint(Offset(w, _borderRadius), radius: r)
          ..lineTo(w, bodyH - _borderRadius)
          ..arcToPoint(Offset(w - _borderRadius, bodyH), radius: r)
          ..lineTo(to + ts, bodyH)
          ..lineTo(to, h) // tail tip
          ..lineTo(to - ts, bodyH)
          ..lineTo(_borderRadius, bodyH)
          ..arcToPoint(Offset(0, bodyH - _borderRadius), radius: r)
          ..lineTo(0, _borderRadius)
          ..arcToPoint(Offset(_borderRadius, 0), radius: r)
          ..close();

      case ShowcasePlacement.below:
        // Tail points upward from top edge, body occupies [ts .. h]
        final bodyY = ts;
        path
          ..moveTo(to - ts, bodyY)
          ..lineTo(to, 0) // tail tip
          ..lineTo(to + ts, bodyY)
          ..lineTo(w - _borderRadius, bodyY)
          ..arcToPoint(Offset(w, bodyY + _borderRadius), radius: r)
          ..lineTo(w, h - _borderRadius)
          ..arcToPoint(Offset(w - _borderRadius, h), radius: r)
          ..lineTo(_borderRadius, h)
          ..arcToPoint(Offset(0, h - _borderRadius), radius: r)
          ..lineTo(0, bodyY + _borderRadius)
          ..arcToPoint(Offset(_borderRadius, bodyY), radius: r)
          ..close();

      case ShowcasePlacement.leftOf:
        // Body occupies [0 .. w-ts], tail points rightward from right edge
        final bodyW = w - ts;
        path
          ..moveTo(_borderRadius, 0)
          ..lineTo(bodyW - _borderRadius, 0)
          ..arcToPoint(Offset(bodyW, _borderRadius), radius: r)
          ..lineTo(bodyW, to - ts)
          ..lineTo(w, to) // tail tip
          ..lineTo(bodyW, to + ts)
          ..lineTo(bodyW, h - _borderRadius)
          ..arcToPoint(Offset(bodyW - _borderRadius, h), radius: r)
          ..lineTo(_borderRadius, h)
          ..arcToPoint(Offset(0, h - _borderRadius), radius: r)
          ..lineTo(0, _borderRadius)
          ..arcToPoint(Offset(_borderRadius, 0), radius: r)
          ..close();

      case ShowcasePlacement.rightOf:
        // Tail points leftward from left edge, body occupies [ts .. w]
        final bodyX = ts;
        path
          ..moveTo(bodyX + _borderRadius, 0)
          ..lineTo(w - _borderRadius, 0)
          ..arcToPoint(Offset(w, _borderRadius), radius: r)
          ..lineTo(w, h - _borderRadius)
          ..arcToPoint(Offset(w - _borderRadius, h), radius: r)
          ..lineTo(bodyX + _borderRadius, h)
          ..arcToPoint(Offset(bodyX, h - _borderRadius), radius: r)
          ..lineTo(bodyX, to + ts)
          ..lineTo(0, to) // tail tip
          ..lineTo(bodyX, to - ts)
          ..lineTo(bodyX, _borderRadius)
          ..arcToPoint(Offset(bodyX + _borderRadius, 0), radius: r)
          ..close();
    }

    return path;
  }

  @override
  bool shouldRepaint(_BalloonPainter old) =>
      old.placement != placement ||
      old.tailSize != tailSize ||
      old.tailOffset != tailOffset;
}
