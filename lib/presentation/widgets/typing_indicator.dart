import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          children: List.generate(3, (index) {
            final active = ((_controller.value * 3).floor() % 3) == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: CircleAvatar(
                radius: active ? 4 : 3,
                backgroundColor: active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
              ),
            );
          }),
        );
      },
    );
  }
}
