import 'package:flutter/material.dart';

class ScrollTracker {
  final ScrollController controller = ScrollController();
  bool isScrolled = false;

  void listen(VoidCallback onScrollChange) {
    controller.addListener(() {
      if (controller.offset > 100 && !isScrolled) {
        print('스크롤 on');
        isScrolled = true;
        onScrollChange();
      } else if (controller.offset <= 100 && isScrolled) {
        print('스크롤 off');
        isScrolled = false;
        onScrollChange();
      }
    });
  }

  void dispose() {
    controller.dispose();
  }
}
