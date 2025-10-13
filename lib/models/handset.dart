class PositionHistory {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final TransmissionMode mode;
  final String transmissionMethod; // 'USB', 'Bluetooth', 'Simulation'
  final double? signalStrength; // Optional signal strength
  final String? additionalData; // Any extra packet data

  PositionHistory({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.mode,
    this.transmissionMethod = 'Simulation',
    this.signalStrength,
    this.additionalData,
  });

  String get formattedTimestamp =>
      '${timestamp.day.toString().padLeft(2, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.year} '
      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';

  String get modeDisplayName {
    switch (mode) {
      case TransmissionMode.vhf:
        return 'VHF Radio';
      case TransmissionMode.satellite:
        return 'Satellite';
      case TransmissionMode.gsm:
        return 'GSM Network';
    }
  }
}

class Handset {
  final String id;
  final String name;
  double? latitude;
  double? longitude;
  TransmissionMode mode;
  bool isOnline;
  DateTime lastSeen;
  DateTime? lastModeChange;
  final List<PositionHistory> positionHistory = [];

  Handset({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
    this.mode = TransmissionMode.vhf,
    this.isOnline = false,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  void updateLocation(
    double lat,
    double lng, {
    String transmissionMethod = 'Simulation',
    double? signalStrength,
  }) {
    latitude = lat;
    longitude = lng;
    lastSeen = DateTime.now();
    isOnline = true;

    // Add to position history (keep last 100 positions)
    positionHistory.add(
      PositionHistory(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        mode: mode,
        transmissionMethod: transmissionMethod,
        signalStrength: signalStrength,
      ),
    );

    // Limit history to prevent memory issues
    if (positionHistory.length > 100) {
      positionHistory.removeAt(0);
    }
  }

  void updateMode(TransmissionMode newMode) {
    if (mode != newMode) {
      lastModeChange = DateTime.now();
    }
    mode = newMode;
    lastSeen = DateTime.now();
  }

  void setOffline() {
    isOnline = false;
  }

  bool get hasRecentModeChange {
    if (lastModeChange == null) return false;
    return DateTime.now().difference(lastModeChange!).inSeconds < 10;
  }
}

enum TransmissionMode { vhf, satellite, gsm }
