import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class CopyButton extends StatefulWidget {
  final String text;
  final String? tooltip;

  const CopyButton({super.key, required this.text, this.tooltip});

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    setState(() => _copied = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip ?? 'Copiar',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          key: ValueKey(_copied),
          onPressed: _copy,
          icon: Icon(
            _copied ? Icons.check_rounded : Icons.copy_outlined,
            size: 15,
            color: _copied ? AppTheme.scoreHigh : AppTheme.textSecondary,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          splashRadius: 14,
        ),
      ),
    );
  }
}
