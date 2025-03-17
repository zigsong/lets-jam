import 'package:flutter/material.dart';
import 'package:lets_jam/models/session_enum.dart';

Map<SessionEnum, String> sessionImagesDefault = {
  SessionEnum.vocalM: 'assets/images/session_selector/vocal_m.png',
  SessionEnum.vocalF: 'assets/images/session_selector/vocal_fm.png',
  SessionEnum.drum: 'assets/images/session_selector/drum.png',
  SessionEnum.keyboard: 'assets/images/session_selector/keyboard.png',
  SessionEnum.bass: 'assets/images/session_selector/bass.png',
  SessionEnum.guitar: 'assets/images/session_selector/guitar.png',
};

Map<SessionEnum, String> sessionImagesActive = {
  SessionEnum.vocalM: 'assets/images/session_selector/vocal_m_active.png',
  SessionEnum.vocalF: 'assets/images/session_selector/vocal_fm_active.png',
  SessionEnum.drum: 'assets/images/session_selector/drum_active.png',
  SessionEnum.keyboard: 'assets/images/session_selector/keyboard_active.png',
  SessionEnum.bass: 'assets/images/session_selector/bass_active.png',
  SessionEnum.guitar: 'assets/images/session_selector/guitar_active.png',
};

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
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    child: Container(
                      width: 80,
                      height: 80,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                          alignment: AlignmentDirectional.bottomEnd,
                          children: [
                            widget.selectedSessions.contains(session)
                                ? Image.asset(sessionImagesActive[session]!)
                                : Image.asset(sessionImagesDefault[session]!),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 10, bottom: 10),
                              child: Text(
                                sessionMap[session]!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ]),
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
