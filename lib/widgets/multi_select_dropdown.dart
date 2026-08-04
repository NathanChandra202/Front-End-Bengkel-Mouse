import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class MultiSelectDropdown extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  final String hint;
  final ValueChanged<List<String>> onChanged;

  const MultiSelectDropdown({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeDropdown,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 4),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surface,
                  shadowColor: Colors.black26,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerTheme.color!),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      children: widget.items.map((item) {
                        return StatefulBuilder(
                          builder: (context, setStateOverlay) {
                            final isSelected = widget.selectedItems.contains(item);
                            return InkWell(
                              onTap: () {
                                final newSelected = List<String>.from(widget.selectedItems);
                                if (isSelected) {
                                  newSelected.remove(item);
                                } else {
                                  newSelected.add(item);
                                }
                                widget.onChanged(newSelected);
                                // rebuild overlay item
                                setStateOverlay(() {});
                                // rebuild main widget
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                          color: isSelected ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isOpen ? AppTheme.primaryColor : Theme.of(context).dividerTheme.color!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: widget.selectedItems.isEmpty
                    ? Text(
                        widget.hint,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.textMuted
                              : AppTheme.textMutedLight,
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.selectedItems.map((item) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    final newSelected = List<String>.from(widget.selectedItems);
                                    newSelected.remove(item);
                                    widget.onChanged(newSelected);
                                    if (_isOpen) {
                                      _closeDropdown();
                                    }
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(width: 8),
              Icon(
                _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.textMuted
                    : AppTheme.textMutedLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
