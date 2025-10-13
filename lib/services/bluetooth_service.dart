import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../models/handset.dart';
import '../providers/handset_provider.dart';

class BluetoothService {
  BluetoothConnection? _connection;
  StreamSubscription? _subscription;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<List<BluetoothDevice>> getAvailableDevices() async {
    final devices = <BluetoothDevice>[];
    try {
      final bondedDevices = await FlutterBluetoothSerial.instance
          .getBondedDevices();
      devices.addAll(bondedDevices);
    } catch (e) {
      debugPrint('Error getting Bluetooth devices: $e');
    }
    return devices;
  }

  Future<bool> connect(BluetoothDevice device, HandsetProvider provider) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _isConnected = true;

      _subscription = _connection!.input!.listen((Uint8List data) {
        _processData(utf8.decode(data), provider);
      });

      return true;
    } catch (e) {
      debugPrint('Error connecting to Bluetooth device: $e');
      return false;
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _connection?.close();
    _isConnected = false;
  }

  void _processData(String data, HandsetProvider provider) {
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
      debugPrint('Error processing Bluetooth data: $e');
    }
  }

  Future<void> sendData(String data) async {
    if (_connection != null && _isConnected) {
      _connection!.output.add(utf8.encode(data));
      await _connection!.output.allSent;
    }
  }
}
