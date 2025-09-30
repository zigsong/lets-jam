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
  });

  final String? label;
  final String? placeholder;
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

  void _showDropdown() {
    final targetContext = _targetKey.currentContext;
    if (targetContext == null) {
      debugPrint("Target context is null. Widget might not be built yet.");
      return;
    }

    final renderBox = targetContext.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(children: [
        // MARK: 투명한 GestureDetector 추가 → 바깥쪽 클릭 감지
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border:
                      Border.all(color: ColorSeed.meticulousGrayLight.color),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.options.asMap().entries.map((entry) {
                    return Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.vertical(
                        top: entry.key == 0
                            ? const Radius.circular(6)
                            : Radius.zero,
                        bottom: entry.key == widget.options.length - 1
                            ? const Radius.circular(6)
                            : Radius.zero,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        highlightColor: ColorSeed.boldOrangeLight.color,
                        child: Ink(
                          color: Colors.white,
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              width: double.infinity,
                              height: 36,
                              child: Text(
                                widget.options[entry.key].text,
                                style:
                                    const TextStyle(fontSize: 13, height: 1.38),
                              )),
                        ),
                        onTap: () {
                          widget.onSelect(entry.value);
                          _hideDropdown();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
    overlay.insert(_overlayEntry!);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    String displayValue = widget.currentValue?.text ?? widget.placeholder ?? '';

    return Stack(
      children: [
        if (widget.label != null)
          Positioned(
              child: Text(
            widget.label!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          )),
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
                    style: const TextStyle(fontSize: 13, height: 1.38),
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
