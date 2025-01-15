import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({super.key, this.height, this.images});

  final double? height;
  final List<String>? images;

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  Widget sliderWidget() {
    return CarouselSlider(
      carouselController: _controller,
      items: widget.images != null
          ? widget.images!.map(
              (image) {
                return Builder(
                  builder: (context) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                );
              },
            ).toList()
          : [
              Image.asset(
                'assets/images/detail_thumb_temp.png',
                fit: BoxFit.fill,
              )
            ],
      options: CarouselOptions(
        height: widget.height ?? 248,
        viewportFraction: 1.0,
        onPageChanged: (index, reason) {
          setState(() {
            _current = index;
          });
        },
      ),
    );
  }

  Widget sliderIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.images!.length, (index) => index + 1)
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
    return SizedBox(
      height: widget.height ?? 248,
      child: Stack(
        children: [
          sliderWidget(),
          if (widget.images != null && widget.images!.length > 1)
            sliderIndicator(),
        ],
      ),
    );
  }
}
