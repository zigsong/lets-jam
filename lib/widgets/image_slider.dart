import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:lets_jam/widgets/full_image_slider.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({super.key, this.height, this.images});

  final double? height;
  final List<String>? images;

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

double imageHeight = 267;

class _ImageSliderState extends State<ImageSlider> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  void showFullImageSliderModal(
      BuildContext context, List<String> images, int index) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '이미지 보기',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FullImageSlider(
          images: images,
          initialIndex: index,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  Widget sliderWidget() {
    if (widget.images != null && widget.images!.length > 1) {
      return GestureDetector(
        onTap: () {
          showFullImageSliderModal(context, widget.images!, _current);
        },
        child: CarouselSlider(
          carouselController: _controller,
          items: widget.images!.map(
            (image) {
              return Builder(
                builder: (context) {
                  return Image.network(
                    image,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  );
                },
              );
            },
          ).toList(),
          options: CarouselOptions(
            height: widget.height ?? imageHeight,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
      );
    }

    if (widget.images != null && widget.images!.length == 1) {
      return GestureDetector(
        onTap: () {
          showFullImageSliderModal(context, widget.images!, 1);
        },
        child: Image.network(
          widget.images![0],
          width: MediaQuery.of(context).size.width,
          height: imageHeight,
          fit: BoxFit.cover,
        ),
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: imageHeight,
      child: Image.asset(
        'assets/images/post_default_img.png',
        fit: BoxFit.cover,
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
      height: widget.height ?? imageHeight,
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
