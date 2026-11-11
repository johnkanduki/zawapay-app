import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Closes the keyboard when the user taps anywhere that is not a text
/// field: empty space, a card, a list, a sheet… on every page of the app.
///
/// It listens to the raw touches (not a GestureDetector), so buttons,
/// lists and cards under the finger can never swallow the tap. A drag or a
/// scroll does not count as a tap.
class KeyboardDismisser extends StatefulWidget {
  const KeyboardDismisser({super.key, required this.child});

  final Widget child;

  @override
  State<KeyboardDismisser> createState() => _KeyboardDismisserState();
}

class _KeyboardDismisserState extends State<KeyboardDismisser> {
  Offset? _down;

  void _onUp(PointerUpEvent event) {
    final down = _down;
    _down = null;
    final focus = FocusManager.instance.primaryFocus;
    if (down == null || focus == null || !focus.hasPrimaryFocus) return;
    // Moved: it was a scroll or a drag, not a tap.
    if ((event.position - down).distance > kTouchSlop) return;
    final result = HitTestResult();
    WidgetsBinding.instance.hitTestInView(
      result,
      event.position,
      View.of(context).viewId,
    );
    // On a text field (any one): typing goes on there.
    final onField = result.path.any((entry) => entry.target is RenderEditable);
    if (onField || _insideFocusedField(focus, event.position)) return;
    focus.unfocus();
  }

  /// The whole box of the field being typed in (its padding and rounded
  /// frame too), so a tap on its edge keeps the keyboard open.
  static bool _insideFocusedField(FocusNode focus, Offset position) {
    final field = focus.context?.findAncestorStateOfType<State<TextField>>();
    final box = (field?.context ?? focus.context)?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return false;
    final topLeft = box.localToGlobal(Offset.zero);
    return (topLeft & box.size).contains(position);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => _down = event.position,
      onPointerCancel: (_) => _down = null,
      onPointerUp: _onUp,
      child: widget.child,
    );
  }
}
