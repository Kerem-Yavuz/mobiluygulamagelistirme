import 'package:flutter/material.dart';

class MapWithPoints extends StatelessWidget {
  final List<Map<String, dynamic>> points; // {'id': 1, 'dx': 0.5, 'dy': 0.4}
  final void Function(String id) onPointTapped;

  const MapWithPoints({
    super.key,
    required this.points,
    required this.onPointTapped,
  });

  static const double imageOriginalWidth = 717.0;
  static const double imageOriginalHeight = 1452.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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

        return Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 60.0),
          child: InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
          maxScale: 5.0,
          minScale: 1.0,
          child: SizedBox(
            width: containerWidth,
            height: containerHeight,
            child: Stack(
              children: [
                Positioned(
                  left: offsetX,
                  top: offsetY,
                  width: displayedWidth,
                  height: displayedHeight,
                  child: Image.network(
                    'https://rldxceqyinumedzfptnq.supabase.co/storage/v1/object/public/images/zaim_map.png',
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => const Center(child: Text('Görsel yüklenemedi')),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  )
                ),
                ...points.map((point) {
                  final dx = (point['dx'] as double) * displayedWidth + offsetX;
                  final dy = (point['dy'] as double) * displayedHeight + offsetY;

                  return Positioned(
                    left: dx - 12,
                    top: dy - 24,
                    child: GestureDetector(
                      onTap: () => onPointTapped(point['id']),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        );
      },
    );
  }
}
