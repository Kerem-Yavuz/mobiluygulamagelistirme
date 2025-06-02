

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobiluygulamagelistirme/appbar.dart';

class MapWithSinglePoint extends StatelessWidget {
  final double normalizedLat; // from 0 to 1
  final double normalizedLng; // from 0 to 1

  const MapWithSinglePoint({
    super.key,
    required this.normalizedLat,
    required this.normalizedLng,
  });

  static const double imageOriginalWidth = 717.0;
  static const double imageOriginalHeight = 1452.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "MapDetail"),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final containerWidth = constraints.maxWidth;
          final containerHeight = constraints.maxHeight;

          final imageRatio = imageOriginalWidth / imageOriginalHeight;
          final containerRatio = containerWidth / containerHeight;

          double displayedWidth, displayedHeight;

          if (containerRatio > imageRatio) {
            displayedHeight = containerHeight;
            displayedWidth = displayedHeight * imageRatio;
          } else {
            displayedWidth = containerWidth;
            displayedHeight = displayedWidth / imageRatio;
          }

          final offsetX = (containerWidth - displayedWidth) / 2;
          final offsetY = (containerHeight - displayedHeight) / 2;

          final double left = normalizedLng * displayedWidth + offsetX;
          final double top = normalizedLat * displayedHeight + offsetY;

          return Stack(
            children: [
              Positioned(
                left: offsetX,
                top: offsetY,
                width: displayedWidth,
                height: displayedHeight,
                child: Image.asset(
                  'assets/zaim_map.png',
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                left: left - 16, // center the icon horizontally (icon size 32)
                top: top - 32,   // position icon vertically (icon size 32)
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 32,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}