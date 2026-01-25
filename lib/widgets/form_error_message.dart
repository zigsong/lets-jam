import 'package:flutter/material.dart';

class FormErrorMessage extends StatelessWidget {
  final String message;

  const FormErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 13.5,
                height: 13.5,
                child: Image.asset('assets/icons/info.png')),
            const SizedBox(width: 7),
            Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
