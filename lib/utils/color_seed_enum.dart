import 'package:flutter/material.dart';

enum ColorSeed {
  boldOrangeStrong('Bold Orange Strong', Color(0xffFC5C2B)),
  boldOrangeMedium('Bold Orange Medium', Color(0xffFC784F)),
  boldOrangeRegular('Bold Orange Regular', Color(0xffFD9E81)),
  boldOrangeLight('Bold Orange Light', Color(0xffFFECE6)),

  joyfulYellowStrong('Joyful Yellow Strong', Color(0xffFFF231)),
  joyfulYellowMedium('Joyful Yellow Medium', Color(0xffFFF566)),
  joyfulYellowRegular('Joyful Yellow Regular', Color(0xffFFFAB3)),
  joyfulYellowLight('Joyful Yellow Light', Color(0xffFFFDE6)),

  organizedBlackMedium('Organized Black Medium', Color(0xff222222)),
  organizedBlackLight('Organized Black Light', Color(0xff4D4D4D)),

  meticulousGrayMedium('Meticulous Gray Medium', Color(0xffA0A0A0)),
  meticulousGrayLight('Meticulous Gray Light', Color(0xffD9D9D9));

  const ColorSeed(this.label, this.color);

  final String label;
  final Color color;
}
