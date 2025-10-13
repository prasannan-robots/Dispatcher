import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/handset_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text(
          'TACTICAL SETTINGS',
          style: TextStyle(
            color: Colors.cyan,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.cyan),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan.withOpacity(0.0),
                  Colors.cyan.withOpacity(0.5),
                  Colors.cyan.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Consumer<HandsetProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('SIMULATION CONTROLS'),
                const SizedBox(height: 16),
                _buildSimulationCard(provider),
                const SizedBox(height: 32),
                _buildSectionHeader('SYSTEM STATUS'),
                const SizedBox(height: 16),
                _buildStatusCard(provider),
                const SizedBox(height: 32),
                _buildSectionHeader('ABOUT'),
                const SizedBox(height: 16),
                _buildAboutCard(),
                const SizedBox(height: 16), // Extra padding at bottom
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.cyan,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.cyan,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildSimulationCard(HandsetProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[900]!.withOpacity(0.8),
            Colors.black.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: provider.isSimulationEnabled
              ? Colors.green.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: provider.isSimulationEnabled
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: provider.isSimulationEnabled
                        ? Colors.green.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
                child: Icon(
                  provider.isSimulationEnabled ? Icons.play_arrow : Icons.pause,
                  color: provider.isSimulationEnabled
                      ? Colors.green
                      : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Movement Simulation',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      provider.isSimulationEnabled
                          ? 'Active - Units moving automatically'
                          : 'Inactive - Units are stationary',
                      style: TextStyle(
                        color: provider.isSimulationEnabled
                            ? Colors.green.withOpacity(0.8)
                            : Colors.grey.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: provider.isSimulationEnabled,
                onChanged: (value) {
                  provider.toggleSimulation();

                  // Show feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Simulation ENABLED - Units will move automatically'
                            : 'Simulation DISABLED - Units are now stationary',
                      ),
                      backgroundColor: value ? Colors.green : Colors.orange,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                activeColor: Colors.green,
                activeTrackColor: Colors.green.withOpacity(0.3),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.cyan.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.cyan.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SIMULATION INFO',
                      style: TextStyle(
                        color: Colors.cyan.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Teams move realistically around Kupwara sector (~10-15m steps)\n'
                  '• Movement updates every 2 seconds for smooth tracking\n'
                  '• Communication modes switch dynamically (VHF↔SAT↔GSM)\n'
                  '• Brief connectivity losses during mode transitions\n'
                  '• Simulation continues until manually disabled\n'
                  '• Perfect for recording realistic tactical operations',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(HandsetProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[900]!.withOpacity(0.8),
            Colors.black.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dashboard, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              const Text(
                'System Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatusRow(
            'Total Handsets',
            '${provider.handsets.length}',
            Colors.white,
          ),
          _buildStatusRow(
            'Online Units',
            '${provider.onlineHandsets.length}',
            Colors.green,
          ),
          _buildStatusRow(
            'Offline Units',
            '${provider.handsets.length - provider.onlineHandsets.length}',
            Colors.red,
          ),
          _buildStatusRow(
            'Simulation',
            provider.isSimulationEnabled ? 'ACTIVE' : 'INACTIVE',
            provider.isSimulationEnabled ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[900]!.withOpacity(0.8),
            Colors.black.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.military_tech, color: Colors.purple, size: 20),
              const SizedBox(width: 12),
              const Text(
                'BSF Ground System',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tactical Communication & Tracking System\n'
            'Kupwara Sector Operations\n'
            'Version 1.0 - Tactical Display',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
