import 'package:flutter/material.dart';

class TappableImage extends StatefulWidget {
  final Function(Map<String, double>) onCoordinateSelected;

  const TappableImage({super.key, required this.onCoordinateSelected});

  @override
  State<TappableImage> createState() => _TappableImageState();
}

class _TappableImageState extends State<TappableImage> {
  final GlobalKey _imageKey = GlobalKey();
  Offset? _selectedPoint;

  void _handleTap(TapUpDetails details) {
    final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = details.localPosition;
    final size = box.size;

    final dxPercent = local.dx / size.width;
    final dyPercent = local.dy / size.height;

    final coords = {
      'lat': dyPercent,
      'lng': dxPercent,
    };

    setState(() {
      _selectedPoint = local;
    });

    widget.onCoordinateSelected(coords);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _handleTap,
      child: Stack(
        children: [
          Image.asset('assets/zaim_map.png', key: _imageKey),
          if (_selectedPoint != null)
            Positioned(
              left: _selectedPoint!.dx - 12,
              top: _selectedPoint!.dy - 24,
              child: const Icon(Icons.location_on, color: Colors.red),
            ),
        ],
      ),
    );
  }
}
