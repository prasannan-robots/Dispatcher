import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/handset_provider.dart';
import '../models/handset.dart';

class SimpleMapScreen extends StatelessWidget {
  const SimpleMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HandsetProvider>(
      builder: (context, provider, child) {
        return Container(
          color: Colors.grey[200],
          child: Stack(
            children: [
              // Simple grid background
              CustomPaint(painter: GridPainter(), size: Size.infinite),
              // Center marker
              const Center(
                child: Icon(Icons.my_location, color: Colors.blue, size: 30),
              ),
              // Handset markers
              ...provider.onlineHandsets.map((handset) {
                if (handset.latitude == null || handset.longitude == null) {
                  return const SizedBox.shrink();
                }

                // Simple positioning based on lat/lng
                final x =
                    (handset.longitude! + 180) / 360; // Normalize longitude
                final y =
                    (90 - handset.latitude!) /
                    180; // Normalize latitude (inverted)

                return Positioned(
                  left: MediaQuery.of(context).size.width * x - 20,
                  top: MediaQuery.of(context).size.height * y - 20,
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: _getColorForMode(handset.mode),
                        size: 40,
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          handset.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              // Controls
              Positioned(
                top: 10,
                right: 10,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Legend:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        _legendItem(Colors.red, 'VHF'),
                        _legendItem(Colors.green, 'Satellite'),
                        _legendItem(Colors.orange, 'GSM'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, color: color, size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Color _getColorForMode(TransmissionMode mode) {
    switch (mode) {
      case TransmissionMode.vhf:
        return Colors.red;
      case TransmissionMode.satellite:
        return Colors.green;
      case TransmissionMode.gsm:
        return Colors.orange;
    }
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    const spacing = 50.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
