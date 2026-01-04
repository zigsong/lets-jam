import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class DropdownItem<T> {
  final T value;
  final String text;

  DropdownItem({required this.value, required this.text});
}

class CustomDropdown<T> extends StatefulWidget {
  const CustomDropdown({
    super.key,
    required this.currentValue,
    required this.options,
    required this.onSelect,
    this.label,
    this.placeholder,
    this.defaultValue,
  });

  final String? label;
  final String? placeholder;
  final String? defaultValue;
  final DropdownItem? currentValue;
  final List<DropdownItem> options;
  final Function(DropdownItem value) onSelect;

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _targetKey = GlobalKey();

  @override
  void dispose() {
    _hideDropdown();
    super.dispose();
  }

  void _showDropdown() {
    final targetContext = _targetKey.currentContext;
    if (targetContext == null) return;

    final renderBox = targetContext.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _hideDropdown,
            ),
          ),
          Positioned(
            width: renderBox.size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: ColorSeed.meticulousGrayLight.color),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.options.asMap().entries.map((entry) {
                        final option = entry.value;
                        final isDefaultValue = widget.defaultValue != null &&
                            option.text == widget.defaultValue;

                        return InkWell(
                          highlightColor: isDefaultValue
                              ? Colors.transparent
                              : ColorSeed.boldOrangeLight.color,
                          onTap: isDefaultValue
                              ? null
                              : () {
                                  widget.onSelect(option);
                                  _hideDropdown();
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            width: double.infinity,
                            height: 36,
                            child: Text(
                              option.text,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.38,
                                color: isDefaultValue
                                    ? ColorSeed.meticulousGrayMedium.color
                                    : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = widget.currentValue?.text ?? widget.placeholder ?? '';
    final isDefaultValue =
        widget.defaultValue != null && displayValue == widget.defaultValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        GestureDetector(
          key: _targetKey,
          onTap: _showDropdown,
          child: CompositedTransformTarget(
            link: _layerLink,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: ColorSeed.meticulousGrayLight.color),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.38,
                      color: isDefaultValue
                          ? ColorSeed.meticulousGrayMedium.color
                          : Colors.black,
                    ),
                  ),
                  Image.asset(
                    'assets/icons/arrow_down.png',
                    width: 12,
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
