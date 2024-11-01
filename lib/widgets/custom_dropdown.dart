import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  const CustomDropdown(
      {super.key,
      required this.label,
      this.placeholder,
      required this.currentValue,
      required this.options,
      required this.optionValues,
      required this.onSelect});

  final String label;
  final String? placeholder;
  final T? currentValue;
  final List<T> options;
  final Map<T, String> optionValues;
  final Function(T value) onSelect;

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _targetKey = GlobalKey();

  void _showDropdown() {
    final targetContext = _targetKey.currentContext;
    final renderBox = targetContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: renderBox.size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 24),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: const Color(0xffAED3FF)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.options
                  .asMap()
                  .entries
                  .map((entry) => Material(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          splashColor: const Color(0xffAED3FF),
                          highlightColor: const Color(0xffAED3FF),
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              width: double.infinity,
                              height: 44,
                              decoration: BoxDecoration(
                                  border: entry.key > 0
                                      ? const Border(
                                          top: BorderSide(
                                              width: 2,
                                              color: Color(0xffAED3FF)),
                                        )
                                      : null,
                                  borderRadius: entry.key == 0
                                      ? BorderRadius.circular(12)
                                      : null),
                              child: Text(widget.optionValues[entry.value]!)),
                          onTap: () {
                            widget.onSelect(entry.value);
                            _hideDropdown();
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
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
    String displayValue;
    if (widget.currentValue is Enum) {
      displayValue = widget.optionValues[(widget.currentValue as Enum)]!;
    } else if (widget.currentValue is String) {
      displayValue = widget.currentValue as String; // 그대로 사용
    } else {
      displayValue = widget.placeholder ?? '';
    }

    return Stack(
      children: [
        Positioned(
            child: Text(
          widget.label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        GestureDetector(
          onTap: _showDropdown,
          child: CompositedTransformTarget(
            link: _layerLink,
            child: Padding(
                padding: const EdgeInsets.only(top: 24),
                key: _targetKey,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    border:
                        Border.all(width: 2, color: const Color(0xffAED3FF)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(displayValue),
                      Image.asset(
                        'assets/icons/arrow_down.png',
                        width: 12,
                        height: 12,
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ],
    );
  }
}
