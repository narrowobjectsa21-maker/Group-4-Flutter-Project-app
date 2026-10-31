import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'orbit_snack_bar.dart';

/// A text field with a round button next to it, used to add things
/// (a task, a file, a teammate).
///
/// It owns a [TextEditingController] and disposes it in [dispose].
/// If the user taps the button with an empty field, a SnackBar tells them
/// to type something first; otherwise [onSubmit] is called with the text.
class InlineComposer extends StatefulWidget {
  const InlineComposer({
    super.key,
    required this.hint,
    required this.emptyMessage,
    required this.onSubmit,
    this.onCancel,
    this.keyboardType = TextInputType.text,
    this.sendIcon = Icons.add_rounded,
  });

  final String hint;
  final String emptyMessage;
  final ValueChanged<String> onSubmit;
  final VoidCallback? onCancel;
  final TextInputType keyboardType;
  final IconData sendIcon;

  @override
  State<InlineComposer> createState() => _InlineComposerState();
}

class _InlineComposerState extends State<InlineComposer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      showOrbitSnackBar(context, widget.emptyMessage);
    } else {
      widget.onSubmit(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: widget.keyboardType,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            style: const TextStyle(fontSize: 15, color: AppColors.ink),
            decoration: orbitInputDecoration(hint: widget.hint),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: _submit,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: Colors.white,
          ),
          icon: Icon(widget.sendIcon),
        ),
        if (widget.onCancel != null)
          IconButton(
            onPressed: widget.onCancel,
            tooltip: 'Cancel',
            icon: const Icon(Icons.close_rounded, color: AppColors.muted),
          ),
      ],
    );
  }
}
