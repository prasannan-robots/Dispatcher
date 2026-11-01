import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/handset.dart';
import '../providers/handset_provider.dart';

// Platform-specific imports
import 'package:usb_serial/usb_serial.dart'
    if (dart.library.html) 'serial_web_stub.dart';

class SerialService {
  StreamSubscription? _subscription;
  UsbPort? _usbPort;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<List<String>> getAvailablePorts() async {
    if (kIsWeb) {
      return ['Web Simulator Port'];
    } else if (Platform.isAndroid) {
      final devices = await UsbSerial.listDevices();
      return devices.map((d) => d.deviceName).toList();
    } else {
      // For desktop, implement later
      return [];
    }
  }

  Future<bool> connect(String portName, HandsetProvider provider) async {
    try {
      if (kIsWeb) {
        // For web, just simulate connection
        _isConnected = true;
        return true;
      } else if (Platform.isAndroid) {
        final devices = await UsbSerial.listDevices();
        final device = devices.firstWhere((d) => d.deviceName == portName);
        _usbPort = await device.create();
        if (_usbPort == null) return false;
        await _usbPort!.open();
        _subscription = _usbPort!.inputStream!.listen((Uint8List data) {
          _processData(utf8.decode(data), provider);
        });
      } else {
        // For desktop, implement later
        return false;
      }
      _isConnected = true;
      return true;
    } catch (e) {
      debugPrint('Error connecting to serial: $e');
      return false;
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _usbPort?.close();
    _isConnected = false;
  }

  void _processData(String data, HandsetProvider provider) {
    // Assume data is JSON like {"id": "handset1", "lat": 12.34, "lng": 56.78, "mode": "satellite"}
    try {
      final json = jsonDecode(data);
      final id = json['id'];
      final lat = json['lat'];
      final lng = json['lng'];
      final modeStr = json['mode'];
      TransmissionMode mode;
      switch (modeStr) {
        case 'vhf':
          mode = TransmissionMode.vhf;
          break;
        case 'satellite':
          mode = TransmissionMode.satellite;
          break;
        case 'gsm':
          mode = TransmissionMode.gsm;
          break;
        default:
          mode = TransmissionMode.vhf;
      }
      provider.updateHandset(id, lat, lng, mode);
    } catch (e) {
      debugPrint('Error processing data: $e');
    }
  }
}
