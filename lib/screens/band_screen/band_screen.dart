import 'package:flutter/material.dart';
import 'package:lets_jam/screens/band_screen/gradient_screen.dart';

class BandScreen extends StatefulWidget {
  const BandScreen({super.key});

  @override
  State<BandScreen> createState() => _BandScreenState();
}

class _BandScreenState extends State<BandScreen> {
  @override
  Widget build(BuildContext context) {
    return const GradientSplitScreen();
  }
}
