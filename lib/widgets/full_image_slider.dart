import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class FullImageSlider extends StatefulWidget {
  const FullImageSlider({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  final List<String> images;
  final int initialIndex;

  @override
  State<FullImageSlider> createState() => _FullImageSliderState();
}

class _FullImageSliderState extends State<FullImageSlider> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  Widget sliderWidget(Size size, int index) {
    if (widget.images.length > 1) {
      return CarouselSlider(
        carouselController: _controller,
        items: widget.images.map(
          (image) {
            return Builder(
              builder: (context) {
                return Center(
                  child: Image.network(
                    image,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.contain,
                  ),
                );
              },
            );
          },
        ).toList(),
        options: CarouselOptions(
          height: size.height,
          enlargeCenterPage: false,
          enableInfiniteScroll: true,
          viewportFraction: 1.0,
          initialPage: index,
          onPageChanged: (index, reason) {
            setState(() {
              _current = index;
            });
          },
        ),
      );
    }

    return Center(
      child: Image.network(
        widget.images[0],
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget sliderIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.images.length, (index) => index + 1)
            .asMap()
            .entries
            .map((entry) {
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: Container(
              width: 8,
              height: 8,
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.white.withOpacity(_current == entry.key ? 0.9 : 0.4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          sliderWidget(size, widget.initialIndex),
          if (widget.images.length > 1) sliderIndicator(),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
