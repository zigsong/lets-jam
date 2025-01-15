import 'package:flutter/material.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class BottomAppBarItem extends StatefulWidget {
  final Widget defaultIcon;
  final Widget activeIcon;
  final String label;
  final bool isActive;
  final Function() onPressed;

  const BottomAppBarItem(
      {super.key,
      required this.isActive,
      required this.defaultIcon,
      required this.activeIcon,
      required this.label,
      required this.onPressed});

  @override
  State<BottomAppBarItem> createState() => _BottomAppBarItemState();
}

class _BottomAppBarItemState extends State<BottomAppBarItem> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 28,
              height: 28,
              child: widget.isActive ? widget.activeIcon : widget.defaultIcon,
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                  fontSize: 10,
                  color: widget.isActive
                      ? ColorSeed.boldOrangeMedium.color
                      : ColorSeed.meticulousGrayMedium.color),
            ),
          ],
        ),
      ),
    );
  }
}
