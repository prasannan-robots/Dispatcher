import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/handset.dart';

class HandsetProvider with ChangeNotifier {
  final List<Handset> _handsets = [];
  bool _isSimulationEnabled = false;
  Timer? _simulationTimer;

  List<Handset> get handsets => _handsets;
  bool get isSimulationEnabled => _isSimulationEnabled;

  List<Handset> get onlineHandsets =>
      _handsets.where((h) => h.isOnline).toList();

  void addHandset(Handset handset) {
    _handsets.add(handset);
    notifyListeners();
  }

  void updateHandset(String id, double lat, double lng, TransmissionMode mode) {
    final handset = _handsets.firstWhere((h) => h.id == id);
    handset.updateLocation(lat, lng);
    handset.updateMode(mode);
    notifyListeners();
  }

  void setHandsetOffline(String id) {
    final handset = _handsets.firstWhere((h) => h.id == id);
    handset.setOffline();
    notifyListeners();
  }

  Handset? getHandsetById(String id) {
    try {
      return _handsets.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearHandsets() {
    _handsets.clear();
    notifyListeners();
  }

  void toggleSimulation() {
    _isSimulationEnabled = !_isSimulationEnabled;

    if (_isSimulationEnabled) {
      _startSimulation();
    } else {
      _stopSimulation();
    }

    notifyListeners();
  }

  void _startSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _simulateMovement();
    });
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  void _simulateMovement() {
    final random = Random();

    for (final handset in _handsets) {
      if (handset.isOnline &&
          handset.latitude != null &&
          handset.longitude != null) {
        // Much slower movement - only ~10-20 meters per update
        final latOffset =
            (random.nextDouble() - 0.5) * 0.0003; // ~15m at this latitude
        final lngOffset = (random.nextDouble() - 0.5) * 0.0003;

        final newLat = handset.latitude! + latOffset;
        final newLng = handset.longitude! + lngOffset;

        // Keep within reasonable bounds around Kupwara
        final clampedLat = newLat.clamp(34.52, 34.53);
        final clampedLng = newLng.clamp(74.25, 74.26);

        handset.updateLocation(
          clampedLat,
          clampedLng,
          transmissionMethod: 'Simulation',
          signalStrength:
              random.nextDouble() * 100, // Random signal strength 0-100
        );

        // Simulate communication mode transitions based on tactical scenarios
        _simulateCommModeTransition(handset, random);

        handset.lastSeen = DateTime.now();
      }
    }

    notifyListeners();
  }

  void _simulateCommModeTransition(Handset handset, Random random) {
    // 5% chance per update cycle to change communication mode
    if (random.nextDouble() < 0.05) {
      TransmissionMode newMode;

      // Simulate realistic transitions based on tactical scenarios
      switch (handset.mode) {
        case TransmissionMode.vhf:
          // VHF units might switch to satellite for long-range comms
          // or to GSM if moving to civilian areas
          newMode = random.nextBool()
              ? TransmissionMode.satellite
              : TransmissionMode.gsm;
          break;

        case TransmissionMode.satellite:
          // Satellite units might drop to VHF for local coordination
          // or switch to GSM to conserve battery/avoid detection
          newMode = random.nextBool()
              ? TransmissionMode.vhf
              : TransmissionMode.gsm;
          break;

        case TransmissionMode.gsm:
          // GSM units might switch to VHF for secure military comms
          // or to satellite if GSM coverage is poor
          newMode = random.nextBool()
              ? TransmissionMode.vhf
              : TransmissionMode.satellite;
          break;
      }

      // Apply the mode change
      handset.updateMode(newMode);

      // Simulate brief connectivity loss during transition
      if (random.nextDouble() < 0.3) {
        // 30% chance of brief disconnect
        handset.setOffline();

        // Come back online after a short delay (simulated by next update cycle)
        Timer(const Duration(seconds: 1), () {
          if (_handsets.contains(handset)) {
            handset.isOnline = true;
            handset.lastSeen = DateTime.now();
            notifyListeners();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _stopSimulation();
    super.dispose();
  }
}
