import 'package:flutter/material.dart';
import 'package:lets_jam/models/level_enum.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/tag.dart';

class ExploreFilterSheet extends StatefulWidget {
  const ExploreFilterSheet({super.key});

  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle =
        const TextStyle(fontSize: 13, fontWeight: FontWeight.w600);

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          )),
      child: Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('세션', style: labelStyle),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: SessionEnum.values.map((session) {
                          return Row(
                            children: [
                              Tag(
                                text: sessionMap[session] ?? '',
                                border: Border.all(
                                  color: ColorSeed.meticulousGrayLight.color,
                                ),
                                bgColor: Colors.white,
                                fgColor: Colors.black,
                              ),
                              if (session != SessionEnum.values.last)
                                const SizedBox(width: 8),
                            ],
                          );
                        }).toList(),
                      )
                    ],
                  )),
              Divider(
                height: 10,
                thickness: 0.5,
                color: ColorSeed.boldOrangeMedium.color,
              ),
              Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('레벨', style: labelStyle),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: LevelEnum.values.map((level) {
                          return Row(
                            children: [
                              Tag(
                                text: levelMap[level] ?? '',
                                border: Border.all(
                                  color: ColorSeed.meticulousGrayLight.color,
                                ),
                                bgColor: Colors.white,
                                fgColor: Colors.black,
                              ),
                              if (level != LevelEnum.values.last)
                                const SizedBox(width: 8),
                            ],
                          );
                        }).toList(),
                      )
                    ],
                  )),
              Divider(
                height: 5,
                thickness: 0.5,
                color: ColorSeed.boldOrangeMedium.color,
              ),
              Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                  child: Column(
                    children: [
                      Text('지역', style: labelStyle),
                    ],
                  )),
            ],
          )
        ],
      ),
    );
  }
}
