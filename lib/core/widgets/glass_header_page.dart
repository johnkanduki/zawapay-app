import 'package:flutter/material.dart';

import 'glass.dart';

/// A page whose header (back button, title, buttons) is a fixed plate of
/// frosted glass at the top: it never moves, and the page scrolls behind it.
/// [body] receives the room to keep free at the top of the scrolling list.
class GlassHeaderPage extends StatelessWidget {
  const GlassHeaderPage({
    super.key,
    required this.header,
    required this.body,
    this.compact = false,
  });

  /// True when the header is only a round button (no title): no plate, the
  /// glass button floats alone.
  final bool compact;

  /// Usually a Row: back button, title, maybe a button on the right.
  final Widget header;
  final Widget Function(double top) body;

  /// 8 above + the glass plate (54 + 2 × 6) + 10 below.
  static const double space = 84;

  /// 8 above + the round button (54) + 10 below.
  static const double compactSpace = 72;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Stack(
        children: [
          Positioned.fill(child: body(compactSpace)),
          Positioned(top: 8, left: 16, right: 16, child: header),
        ],
      );
    }
    return Stack(
      children: [
        Positioned.fill(child: body(space)),
        Positioned(
          top: 8,
          left: 12,
          right: 12,
          child: GlassSurface(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
              child: SizedBox(height: 54, child: header),
            ),
          ),
        ),
      ],
    );
  }
}
