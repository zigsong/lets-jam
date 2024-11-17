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
                        color: widget.selectedSessions.contains(session)
                            ? const Color(0xffBFFFAF)
                            : const Color(0xffBFBFBF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            sessionMap[session]!,
                            style: TextStyle(
                                color: widget.selectedSessions.contains(session)
                                    ? Colors.black
                                    : Colors.white),
                          )),
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
