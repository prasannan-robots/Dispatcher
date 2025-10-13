// Web stub for USB Serial functionality
// This provides empty implementations for web platform compatibility

import 'dart:async';
import 'dart:typed_data';

class UsbPort {
  Stream<Uint8List>? get inputStream => null;

  Future<void> open() async {
    // Web stub - no-op
  }

  void close() {
    // Web stub - no-op
  }
}

class UsbDevice {
  String get deviceName => 'Web Simulator Device';
  Future<UsbPort?> create() async => UsbPort();
}

class UsbSerial {
  static Future<List<UsbDevice>> listDevices() async {
    return <UsbDevice>[];
  }
}
