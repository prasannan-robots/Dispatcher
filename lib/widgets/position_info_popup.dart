import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/handset.dart';

class PositionInfoPopup extends StatelessWidget {
  final PositionHistory position;
  final String handsetId;

  const PositionInfoPopup({
    super.key,
    required this.position,
    required this.handsetId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D1117),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF00D4FF), width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: 320,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF00D4FF),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Position Data - $handsetId',
                      style: const TextStyle(
                        color: Color(0xFF00D4FF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF00D4FF),
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Coordinates
              _buildInfoRow(
                'Coordinates',
                '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
                Icons.gps_fixed,
              ),
              const SizedBox(height: 12),

              // Timestamp
              _buildInfoRow(
                'Timestamp',
                position.formattedTimestamp,
                Icons.access_time,
              ),
              const SizedBox(height: 12),

              // Transmission Mode
              _buildInfoRow(
                'Transmission Mode',
                position.modeDisplayName,
                _getModeIcon(position.mode),
              ),
              const SizedBox(height: 12),

              // Transmission Method
              _buildInfoRow(
                'Received Via',
                position.transmissionMethod,
                Icons.settings_input_antenna,
              ),

              // Signal Strength (if available)
              if (position.signalStrength != null) ...[
                const SizedBox(height: 12),
                _buildSignalStrengthRow(),
              ],

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      // Copy coordinates to clipboard
                      final coordinates =
                          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
                      await Clipboard.setData(ClipboardData(text: coordinates));

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Coordinates copied: $coordinates'),
                            backgroundColor: const Color(0xFF00D4FF),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.copy,
                      color: Color(0xFF00D4FF),
                      size: 16,
                    ),
                    label: const Text(
                      'Copy Coords',
                      style: TextStyle(
                        color: Color(0xFF00D4FF),
                        fontFamily: 'Courier',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[400], size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontFamily: 'Courier',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignalStrengthRow() {
    final strength = position.signalStrength!;
    final strengthPercent = (strength / 100).clamp(0.0, 1.0);

    Color strengthColor;
    if (strengthPercent > 0.7) {
      strengthColor = Colors.green;
    } else if (strengthPercent > 0.4) {
      strengthColor = Colors.orange;
    } else {
      strengthColor = Colors.red;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.signal_cellular_alt, color: Colors.grey[400], size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Signal Strength',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontFamily: 'Courier',
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.grey[800],
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: strengthPercent,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: strengthColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${strength.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: strengthColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getModeIcon(TransmissionMode mode) {
    switch (mode) {
      case TransmissionMode.vhf:
        return Icons.radio;
      case TransmissionMode.satellite:
        return Icons.satellite_alt;
      case TransmissionMode.gsm:
        return Icons.cell_tower;
    }
  }
}
