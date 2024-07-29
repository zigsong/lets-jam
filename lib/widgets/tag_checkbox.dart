import 'package:flutter/material.dart';

class TagCheckbox extends StatefulWidget {
  final dynamic value;
  final String label;
  final Function(bool isChecked) onChange; // Notice the variable type

  const TagCheckbox(
      {super.key,
      required this.value,
      required this.label,
      required this.onChange});

  @override
  State<TagCheckbox> createState() => _TagCheckboxState();
}

class _TagCheckboxState extends State<TagCheckbox> {
  bool _isChecked = false;

  void _toggleCheckbox() {
    setState(() {
      _isChecked = !_isChecked;
    });
    widget.onChange(_isChecked);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCheckbox,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isChecked ? Colors.amber[700] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: _isChecked
              ? Border.all(color: Colors.amber.shade700)
              : Border.all(color: Colors.black),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: _isChecked ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
