import 'dart:math' as math;
import 'package:flutter/material.dart';

class TappableImage extends StatefulWidget {
  final Function(Map<String, double>) onCoordinateSelected;
  final Map<String, double>? initialPoint;

  const TappableImage({
    super.key,
    required this.onCoordinateSelected,
    this.initialPoint,
  });

  @override
  State<TappableImage> createState() => _TappableImageState();
}

class _TappableImageState extends State<TappableImage> {
  final TransformationController _transformationController = TransformationController();
  final GlobalKey _imageKey = GlobalKey();

  Offset? _selectedPointPercent;

  static const double imageOriginalWidth = 717.0;
  static const double imageOriginalHeight = 1452.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialPoint != null) {
        setState(() {
          _selectedPointPercent = Offset(
            widget.initialPoint!['lng'] ?? 0.0,
            widget.initialPoint!['lat'] ?? 0.0,
          );
        });
      }
    });
  }

  void _handleTap(TapUpDetails details) {
    final matrix = _transformationController.value;
    final tapPosition = details.localPosition;

    final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final containerSize = box.size;

    final parentBox = context.findRenderObject() as RenderBox?;
    if (parentBox == null) return;
    final parentSize = parentBox.size;

    final imageRatio = imageOriginalWidth / imageOriginalHeight;
    final containerRatio = parentSize.width / parentSize.height;

    double displayedWidth, displayedHeight;

    if (containerRatio > imageRatio) {
      displayedHeight = parentSize.height;
      displayedWidth = displayedHeight * imageRatio;
    } else {
      displayedWidth = parentSize.width;
      displayedHeight = displayedWidth / imageRatio;
    }

    final offsetX = (parentSize.width - displayedWidth) / 2;
    final offsetY = (parentSize.height - displayedHeight) / 2;

    final adjustedPosition = Offset(tapPosition.dx - offsetX, tapPosition.dy - offsetY);

    if (adjustedPosition.dx < 0 ||
        adjustedPosition.dy < 0 ||
        adjustedPosition.dx > displayedWidth ||
        adjustedPosition.dy > displayedHeight) {
      return;
    }

    final dxPercent = adjustedPosition.dx / displayedWidth;
    final dyPercent = adjustedPosition.dy / displayedHeight;

    setState(() {
      _selectedPointPercent = Offset(dxPercent, dyPercent);
    });
    widget.onCoordinateSelected({'lng': dxPercent, 'lat': dyPercent});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _handleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        maxScale: 1.0,
        minScale: 1.0,
        child: LayoutBuilder(
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

            return Stack(
              children: [
                Positioned(
                  left: offsetX,
                  top: offsetY,
                  width: displayedWidth,
                  height: displayedHeight,
                  child: Image.network(
                    'https://rldxceqyinumedzfptnq.supabase.co/storage/v1/object/public/images/zaim_map.png',
                    key: _imageKey,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Text('Görsel yüklenemedi')),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
                if (_selectedPointPercent != null)
                  Positioned(
                    left: offsetX + _selectedPointPercent!.dx * displayedWidth - 12,
                    top: offsetY + _selectedPointPercent!.dy * displayedHeight - 24,
                    child: const Icon(Icons.location_on, color: Color(0xFFA63D40)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
