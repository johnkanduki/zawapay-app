import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// The refresh wheel of Zawapay: 8 rounded bars around a centre, like iOS.
/// [progress] 0 → 1 while the page is pulled: the bars appear one by one.
/// null: the bars turn (a bright bar followed by fading ones).
class BarSpinner extends StatefulWidget {
  const BarSpinner({super.key, this.progress, this.size = 30, this.color});

  final double? progress;
  final double size;
  final Color? color;

  @override
  State<BarSpinner> createState() => _BarSpinnerState();
}

class _BarSpinnerState extends State<BarSpinner>
    with SingleTickerProviderStateMixin {
  late final _turn = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void initState() {
    super.initState();
    if (widget.progress == null) _turn.repeat();
  }

  @override
  void didUpdateWidget(BarSpinner old) {
    super.didUpdateWidget(old);
    if (widget.progress == null && !_turn.isAnimating) _turn.repeat();
    if (widget.progress != null && _turn.isAnimating) _turn.stop();
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _turn,
        builder: (_, _) => CustomPaint(
          painter: _BarsPainter(
            color: widget.color ?? AppColors.red,
            progress: widget.progress,
            // Which bar is the bright one (steps, like iOS).
            head: (_turn.value * _bars).floor() % _bars,
          ),
        ),
      ),
    );
  }
}

const int _bars = 8;

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.color,
    required this.progress,
    required this.head,
  });

  final Color color;
  final double? progress;
  final int head;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final paint = Paint()
      ..strokeWidth = size.width * 0.13
      ..strokeCap = StrokeCap.round;
    canvas.translate(r, r);
    final shown = progress == null ? _bars : (progress! * _bars).ceil();
    for (var i = 0; i < _bars; i++) {
      // Bar 0 at the top, then clockwise.
      final angle = -math.pi / 2 + i * 2 * math.pi / _bars;
      double alpha;
      if (progress != null) {
        if (i >= shown) continue;
        alpha = 0.9;
      } else {
        // The head is bright; the bars behind it fade out.
        final behind = (head - i) % _bars;
        alpha = math.max(0.18, 1 - behind * 0.12);
      }
      paint.color = color.withValues(alpha: alpha);
      final d = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(d * (r * 0.42), d * (r * 0.92), paint);
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.progress != progress || old.head != head || old.color != color;
}

/// Pull-to-refresh with the bar wheel, for any scrolling page: pull the page
/// down past [trigger] and let go; the wheel shows [top] pixels from the top
/// (just under a fixed glass header) and turns while [onRefresh] runs.
/// The scrolling child should bounce (BouncingScrollPhysics).
class BarPullRefresh extends StatefulWidget {
  const BarPullRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.top = 0,
    this.trigger = 80,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final double top;
  final double trigger;

  @override
  State<BarPullRefresh> createState() => _BarPullRefreshState();
}

class _BarPullRefreshState extends State<BarPullRefresh> {
  final _pull = ValueNotifier<double>(0);
  bool _dragging = false;
  double _releasePull = 0;
  bool _refreshing = false;

  @override
  void dispose() {
    _pull.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0) return false;
    _pull.value = math.max(0.0, -n.metrics.pixels);
    if (n is ScrollStartNotification) {
      _dragging = n.dragDetails != null;
      _releasePull = 0;
    } else if (n is ScrollUpdateNotification) {
      if (n.dragDetails != null) {
        _releasePull = -n.metrics.pixels;
      } else if (_dragging) {
        _release();
      }
    } else if (n is ScrollEndNotification && _dragging) {
      _release();
    }
    return false;
  }

  void _release() {
    _dragging = false;
    if (_releasePull >= widget.trigger) _refresh();
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    HapticFeedback.mediumImpact();
    setState(() => _refreshing = true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: widget.top + 6,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: ValueListenableBuilder<double>(
              valueListenable: _pull,
              builder: (_, pull, _) {
                final progress = _refreshing
                    ? null
                    : (pull / widget.trigger).clamp(0.0, 1.0);
                if (progress == 0) return const SizedBox(height: 30);
                return Center(child: BarSpinner(progress: progress));
              },
            ),
          ),
        ),
        // While reloading, the page stays a little lower so the wheel shows.
        AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(top: _refreshing ? 38 : 0),
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
