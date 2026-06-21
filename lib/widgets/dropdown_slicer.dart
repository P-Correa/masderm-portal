import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DropdownSlicer<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final Set<T> selected;
  final String Function(T) labelOf;
  final void Function(T) onToggle;
  final VoidCallback? onClear;

  const DropdownSlicer({
    required this.title,
    required this.items,
    required this.selected,
    required this.labelOf,
    required this.onToggle,
    this.onClear,
    super.key,
  });

  @override
  State<DropdownSlicer<T>> createState() => _DropdownSlicerState<T>();
}

class _DropdownSlicerState<T> extends State<DropdownSlicer<T>> {
  bool _open = false;
  OverlayEntry? _overlay;
  final _layerLink = LayerLink();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  void didUpdateWidget(DropdownSlicer<T> old) {
    super.didUpdateWidget(old);
    if (_overlay != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _overlay?.markNeedsBuild());
    }
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _close() {
    _removeOverlay();
    if (mounted) setState(() => _open = false);
  }

  void _toggle() {
    if (_open) {
      _close();
    } else {
      final overlay = Overlay.of(context);
      _overlay = OverlayEntry(builder: _buildDropdown);
      overlay.insert(_overlay!);
      setState(() => _open = true);
    }
  }

  Widget _buildDropdown(BuildContext ctx) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 220, minWidth: 120, maxWidth: 180),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.onClear != null) ...[
                    InkWell(
                      onTap: () {
                        widget.onClear!();
                        WidgetsBinding.instance.addPostFrameCallback((_) => _overlay?.markNeedsBuild());
                      },
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(12, 8, 12, 6),
                        child: Text('(Selecionar Tudo)', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.items.map((item) {
                          final isSelected = widget.selected.contains(item);
                          return InkWell(
                            onTap: () {
                              widget.onToggle(item);
                              WidgetsBinding.instance.addPostFrameCallback((_) => _overlay?.markNeedsBuild());
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                    size: 16,
                                    color: isSelected ? AppTheme.accent : AppTheme.textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.labelOf(item),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.selected.isNotEmpty;
    final label = isActive ? widget.selected.map(widget.labelOf).join(', ') : 'Todos';

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            border: Border.all(
              color: _open || isActive ? AppTheme.accent : AppTheme.border,
              width: _open || isActive ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.title}: ',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
