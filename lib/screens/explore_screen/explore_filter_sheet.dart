import 'package:flutter/material.dart';

class ExploreFilterSheet extends StatefulWidget {
  const ExploreFilterSheet({super.key});

  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          )),
      child: const Wrap(
        children: [
          Column(
            children: [
              Text('세션'),
              Text('레벨'),
              Text('지역'),
            ],
          )
        ],
      ),
    );
  }
}
