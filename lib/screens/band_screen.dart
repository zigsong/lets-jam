import 'package:flutter/material.dart';

class BandScreen extends StatefulWidget {
  const BandScreen({super.key});

  @override
  State<BandScreen> createState() => _BandScreenState();
}

class _BandScreenState extends State<BandScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Coming Soon'),
      ),
    );
  }
}
