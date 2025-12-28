import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothDeviceSelector extends StatefulWidget {
  final String? currentDeviceId;
  final String? currentDeviceName;
  final Function(String?, String?) onDeviceSelected;

  const BluetoothDeviceSelector({
    super.key,
    required this.currentDeviceId,
    required this.currentDeviceName,
    required this.onDeviceSelected,
  });

  @override
  State<BluetoothDeviceSelector> createState() =>
      _BluetoothDeviceSelectorState();
}

class _BluetoothDeviceSelectorState extends State<BluetoothDeviceSelector> {
  List<BluetoothDevice> _bondedDevices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndLoadBonded();
  }

  Future<void> _requestPermissionsAndLoadBonded() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    await _getBondedDevices();
  }

  Future<void> _getBondedDevices() async {
    setState(() => _isLoading = true);

    try {
      // ✅ Alle GEPAAREN Geräte laden
      final bondedDevices = await FlutterBluePlus.bondedDevices;
      if (mounted) {
        setState(() {
          _bondedDevices = bondedDevices;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Laden: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + Refresh
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bluetooth-Gerät (gepaart)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                TextButton.icon(
                  onPressed: _isLoading ? null : _getBondedDevices,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 16),
                  label: Text(_isLoading ? 'Laden...' : 'Aktualisieren'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ AKTUELLES GERÄT (aus Firebase)
            if (widget.currentDeviceName != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.bluetooth_connected,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.currentDeviceName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.currentDeviceId!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => widget.onDeviceSelected(null, null),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ✅ GEPAARTE GERÄTE LISTE
            if (_bondedDevices.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.link, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${_bondedDevices.length} gepaart${_bondedDevices.length != 1 ? 'e' : ''} Gerät${_bondedDevices.length != 1 ? 'e' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        itemCount: _bondedDevices.length,
                        itemBuilder: (context, index) {
                          final device = _bondedDevices[index];
                          final isSelected =
                              widget.currentDeviceId == device.remoteId.str;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: isSelected ? Colors.green[50] : null,
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.blue[100],
                                child: Icon(
                                  Icons.phone_android,
                                  color: Colors.blue[700],
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                device.platformName ?? 'Unbekannt',
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected ? Colors.green[800] : null,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  device.remoteId.str,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 24,
                                    )
                                  : const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                              onTap: () => _selectDevice(device),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            else if (!_isLoading)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Keine gepaarten Geräte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Geräte zuerst in den System-Bluetooth-Einstellungen koppeln\n(z.B. Auto, Kopfhörer)',
                      style: TextStyle(fontSize: 14, color: Colors.orange[800]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => openAppSettings(),
                      icon: const Icon(Icons.settings),
                      label: const Text('Zu Bluetooth-Einstellungen'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _selectDevice(BluetoothDevice device) {
    widget.onDeviceSelected(device.remoteId.str, device.platformName);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Text(
                '${device.platformName ?? 'Gerät'} für Auto-Tracking ausgewählt!',
              ),
            ],
          ),
          backgroundColor: Colors.green[50],
        ),
      );
    }
  }
}
