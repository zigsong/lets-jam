import 'package:flutter/material.dart';
import 'package:lets_jam/models/session_enum.dart';

class SessionSelector extends StatefulWidget {
  final List<SessionEnum> selectedSessions;
  final Function(SessionEnum session) onChange;

  const SessionSelector(
      {super.key, required this.selectedSessions, required this.onChange});

  @override
  State<SessionSelector> createState() => _SessionSelectorState();
}

class _SessionSelectorState extends State<SessionSelector> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: SessionEnum.values
              .map((session) => Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: GestureDetector(
                    child: Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: const Color(0xffBFFFAF),
                          borderRadius: BorderRadius.circular(12),
                          border: widget.selectedSessions.contains(session)
                              ? Border.all(
                                  color: const Color(0xffFF60F9),
                                  width: 3,
                                )
                              : null),
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text(sessionMap[session]!)),
                    ),
                    onTap: () {
                      setState(() {
                        widget.onChange(session);
                      });
                    },
                  )))
              .toList()),
    );
  }
}
