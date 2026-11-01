import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/handset_provider.dart';
import '../models/handset.dart';
import '../services/serial_service.dart';
import '../services/bluetooth_service.dart';
import '../widgets/position_info_popup.dart';
import 'settings_page.dart';

class TacticalDisplay extends StatefulWidget {
  const TacticalDisplay({super.key});

  @override
  State<TacticalDisplay> createState() => _TacticalDisplayState();
}

class _TacticalDisplayState extends State<TacticalDisplay> {
  final MapController _mapController = MapController();
  final SerialService _serialService = SerialService();
  final BluetoothService _bluetoothService = BluetoothService();
  bool _showLeftPane = true;
  bool _isSatelliteView = true;
  bool _showHistoricalPaths = true;

  // Kupwara coordinates for simulation
  final double kupwaraLat = 34.5236;
  final double kupwaraLng = 74.2551;

  @override
  void initState() {
    super.initState();

    // Add Kupwara area handsets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HandsetProvider>(context, listen: false);
      _addKupwaraHandsets(provider);
    });
  }

  void _addKupwaraHandsets(HandsetProvider provider) {
    // Clear existing handsets
    provider.clearHandsets();

    // Add multiple handsets around Kupwara area
    final handsets = [
      Handset(
        id: 'KUP-001',
        name: 'Alpha Team',
        latitude: kupwaraLat + 0.002,
        longitude: kupwaraLng + 0.001,
        mode: TransmissionMode.vhf,
        isOnline: true,
      ),
      Handset(
        id: 'KUP-002',
        name: 'Bravo Team',
        latitude: kupwaraLat - 0.001,
        longitude: kupwaraLng + 0.003,
        mode: TransmissionMode.satellite,
        isOnline: true,
      ),
      Handset(
        id: 'KUP-003',
        name: 'Charlie Team',
        latitude: kupwaraLat + 0.003,
        longitude: kupwaraLng - 0.002,
        mode: TransmissionMode.gsm,
        isOnline: true,
      ),
      Handset(
        id: 'KUP-004',
        name: 'Delta Team',
        latitude: kupwaraLat - 0.002,
        longitude: kupwaraLng - 0.001,
        mode: TransmissionMode.vhf,
        isOnline: false,
      ),
      Handset(
        id: 'KUP-005',
        name: 'Echo Team',
        latitude: kupwaraLat + 0.001,
        longitude: kupwaraLng + 0.004,
        mode: TransmissionMode.satellite,
        isOnline: true,
      ),
    ];

    for (final handset in handsets) {
      provider.addHandset(handset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Row(
        children: [
          // Left Pane - Handset List
          if (_showLeftPane) _buildLeftPane(),
          // Map Area
          Expanded(child: _buildMapArea()),
        ],
      ),
    );
  }

  Widget _buildLeftPane() {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[900]!.withValues(alpha: 0.95),
            Colors.black.withValues(alpha: 0.98),
          ],
        ),
        border: Border(
          right: BorderSide(color: Colors.cyan.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildHandsetList()),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan.withValues(alpha: 0.2), Colors.blue.withValues(alpha: 0.1)],
        ),
        border: Border(bottom: BorderSide(color: Colors.cyan.withValues(alpha: 0.3))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.military_tech, color: Colors.cyan, size: 20),
              const SizedBox(width: 8),
              const Text(
                'BSF TACTICAL COMMAND',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'KUPWARA SECTOR',
            style: TextStyle(
              color: Colors.cyan.withValues(alpha: 0.8),
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandsetList() {
    return Consumer<HandsetProvider>(
      builder: (context, provider, child) {
        final handsets = provider.handsets;
        return ListView.builder(
          itemCount: handsets.length,
          itemBuilder: (context, index) {
            final handset = handsets[index];
            return _buildHandsetCard(handset);
          },
        );
      },
    );
  }

  Widget _buildHandsetCard(Handset handset) {
    final isOnline = handset.isOnline;
    final statusColor = isOnline ? Colors.green : Colors.red;
    final modeColor = _getModeColor(handset.mode);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOnline
              ? statusColor.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.5)),
          ),
          child: Icon(
            isOnline ? Icons.radio : Icons.portable_wifi_off,
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(
          handset.name,
          style: TextStyle(
            color: isOnline ? Colors.white : Colors.grey[400],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              handset.id,
              style: TextStyle(
                color: Colors.cyan.withValues(alpha: 0.7),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: modeColor,
                    shape: BoxShape.circle,
                    border: handset.hasRecentModeChange
                        ? Border.all(color: Colors.yellow, width: 1)
                        : null,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  handset.mode.name.toUpperCase(),
                  style: TextStyle(
                    color: handset.hasRecentModeChange
                        ? Colors.yellow
                        : modeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (handset.hasRecentModeChange) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.sync, color: Colors.yellow, size: 10),
                ],
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'LAT',
                  handset.latitude?.toStringAsFixed(6) ?? 'N/A',
                ),
                _buildInfoRow(
                  'LNG',
                  handset.longitude?.toStringAsFixed(6) ?? 'N/A',
                ),
                _buildInfoRow('STATUS', isOnline ? 'ONLINE' : 'OFFLINE'),
                _buildInfoRow('LAST SEEN', _formatTime(handset.lastSeen)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.cyan.withValues(alpha: 0.3))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('SETTINGS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.withValues(alpha: 0.2),
                    foregroundColor: Colors.purple,
                    side: BorderSide(color: Colors.purple.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _connectSerial,
                  icon: Icon(
                    _serialService.isConnected ? Icons.usb : Icons.usb_off,
                    size: 16,
                  ),
                  label: Text(
                    _serialService.isConnected ? 'DISCONNECT' : 'USB',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _serialService.isConnected
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    foregroundColor: _serialService.isConnected
                        ? Colors.green
                        : Colors.grey,
                    side: BorderSide(
                      color:
                          (_serialService.isConnected
                                  ? Colors.green
                                  : Colors.grey)
                              .withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _connectBluetooth,
                  icon: Icon(
                    _bluetoothService.isConnected
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth,
                    size: 16,
                  ),
                  label: Text(
                    _bluetoothService.isConnected ? 'BT ON' : 'BT OFF',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _bluetoothService.isConnected
                        ? Colors.blue.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    foregroundColor: _bluetoothService.isConnected
                        ? Colors.blue
                        : Colors.grey,
                    side: BorderSide(
                      color:
                          (_bluetoothService.isConnected
                                  ? Colors.blue
                                  : Colors.grey)
                              .withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapArea() {
    return Stack(
      children: [
        Consumer<HandsetProvider>(
          builder: (context, provider, child) {
            final markers = <Marker>[];
            for (final handset in provider.handsets) {
              if (handset.latitude != null && handset.longitude != null) {
                markers.add(
                  Marker(
                    point: LatLng(handset.latitude!, handset.longitude!),
                    child: _buildHandsetMarker(handset),
                  ),
                );
              }
            }

            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(kupwaraLat, kupwaraLng),
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: _isSatelliteView
                      ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.groundsystem.dispatcher',
                  maxZoom: 18,
                ),
                // Historical paths layer
                if (_showHistoricalPaths) ..._buildHistoricalPaths(),
                MarkerLayer(markers: markers),
              ],
            );
          },
        ),
        // Top Controls
        Positioned(top: 16, left: 16, child: _buildMapControls()),
        // Toggle Left Pane Button
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            onPressed: () {
              setState(() {
                _showLeftPane = !_showLeftPane;
              });
            },
            backgroundColor: Colors.cyan.withValues(alpha: 0.2),
            child: Icon(
              _showLeftPane ? Icons.chevron_left : Icons.chevron_right,
              color: Colors.cyan,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHandsetMarker(Handset handset) {
    final isOnline = handset.isOnline;
    final markerColor = isOnline ? _getModeColor(handset.mode) : Colors.grey;
    final hasRecentModeChange = handset.hasRecentModeChange;

    return SizedBox(
      width: 30,
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Yellow glow for recent mode changes
          if (hasRecentModeChange)
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.yellow.withValues(alpha: 0.3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          // Pulsing effect for online handsets
          if (isOnline)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: markerColor.withValues(alpha: 0.15),
              ),
            ),
          // Main marker - just the icon, no text to avoid overflow
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: markerColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: hasRecentModeChange ? Colors.yellow : Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.radio, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Map Type Toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isSatelliteView ? Icons.satellite_alt : Icons.map,
                color: Colors.cyan,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                _isSatelliteView ? 'SATELLITE' : 'STANDARD',
                style: const TextStyle(
                  color: Colors.cyan,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSatelliteView = !_isSatelliteView;
                  });
                },
                child: Container(
                  width: 40,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _isSatelliteView
                        ? Colors.cyan.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.3),
                    border: Border.all(
                      color: _isSatelliteView ? Colors.cyan : Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: _isSatelliteView
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isSatelliteView ? Colors.cyan : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Historical Paths Toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timeline,
                color: _showHistoricalPaths ? Colors.orange : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'PATHS',
                style: TextStyle(
                  color: _showHistoricalPaths ? Colors.orange : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showHistoricalPaths = !_showHistoricalPaths;
                  });
                },
                child: Container(
                  width: 40,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _showHistoricalPaths
                        ? Colors.orange.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.3),
                    border: Border.all(
                      color: _showHistoricalPaths ? Colors.orange : Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: _showHistoricalPaths
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _showHistoricalPaths
                            ? Colors.orange
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Sector Info
          Text(
            'TACTICAL VIEW',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getModeColor(TransmissionMode mode) {
    switch (mode) {
      case TransmissionMode.vhf:
        return Colors.red;
      case TransmissionMode.satellite:
        return Colors.green;
      case TransmissionMode.gsm:
        return Colors.orange;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'NOW';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  void _connectSerial() async {
    if (_serialService.isConnected) {
      _serialService.disconnect();
      setState(() {});
      return;
    }

    final ports = await _serialService.getAvailablePorts();
    if (!mounted) return;

    if (ports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No serial ports available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await _serialService.connect(
      ports.first,
      Provider.of<HandsetProvider>(context, listen: false),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Connected to serial port' : 'Failed to connect',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
    setState(() {});
  }

  void _connectBluetooth() async {
    if (_bluetoothService.isConnected) {
      _bluetoothService.disconnect();
      setState(() {});
      return;
    }

    final devices = await _bluetoothService.getAvailableDevices();
    if (!mounted) return;

    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Bluetooth devices available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await _bluetoothService.connect(
      devices.first,
      Provider.of<HandsetProvider>(context, listen: false),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Connected to Bluetooth' : 'Failed to connect'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
    setState(() {});
  }

  List<Widget> _buildHistoricalPaths() {
    final handsets = Provider.of<HandsetProvider>(
      context,
      listen: false,
    ).handsets;
    final paths = <Widget>[];

    for (int i = 0; i < handsets.length; i++) {
      final handset = handsets[i];
      if (handset.positionHistory.isEmpty) continue;

      final pathColor = _getModeColor(handset.mode);

      // Add polyline if there are at least 2 points
      if (handset.positionHistory.length >= 2) {
        final points = handset.positionHistory
            .map((pos) => LatLng(pos.latitude, pos.longitude))
            .toList();

        paths.add(
          PolylineLayer(
            polylines: [
              Polyline(
                points: points,
                strokeWidth: 3.0,
                color: pathColor.withValues(alpha: 0.7),
                gradientColors: [
                  pathColor.withValues(alpha: 0.3),
                  pathColor.withValues(alpha: 0.8),
                ],
              ),
            ],
          ),
        );
      }

      // Add interactive markers for each position history point
      final historyMarkers = <Marker>[];
      for (int j = 0; j < handset.positionHistory.length; j++) {
        final position = handset.positionHistory[j];
        final isLatest = j == handset.positionHistory.length - 1;

        historyMarkers.add(
          Marker(
            point: LatLng(position.latitude, position.longitude),
            child: GestureDetector(
              onTap: () => _showPositionInfo(context, position, handset.id),
              child: Container(
                width: isLatest ? 12 : 8,
                height: isLatest ? 12 : 8,
                decoration: BoxDecoration(
                  color: isLatest ? pathColor : pathColor.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: isLatest ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isLatest
                    ? Icon(Icons.circle, color: Colors.white, size: 4)
                    : null,
              ),
            ),
          ),
        );
      }

      if (historyMarkers.isNotEmpty) {
        paths.add(MarkerLayer(markers: historyMarkers));
      }
    }

    return paths;
  }

  void _showPositionInfo(
    BuildContext context,
    PositionHistory position,
    String handsetId,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          PositionInfoPopup(position: position, handsetId: handsetId),
    );
  }

  @override
  void dispose() {
    _serialService.disconnect();
    _bluetoothService.disconnect();
    super.dispose();
  }
}
