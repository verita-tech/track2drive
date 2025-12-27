import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
  final List<ScanResult> _scanResults =
      []; // ← ScanResult statt BluetoothDevice
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
  }

  Future<void> _scanDevices() async {
    setState(() {
      _isScanning = true;
      _scanResults.clear();
    });

    // ✅ flutter_blue_plus API
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));

    // Listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          _scanResults.addAll(results);
        });
      }
    });

    // Stop scan
    await Future.delayed(const Duration(seconds: 8));
    await FlutterBluePlus.stopScan();

    if (mounted) {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      // Kein echtes Connect nötig - nur ID speichern
      widget.onDeviceSelected(device.remoteId.str, device.platformName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${device.platformName ?? 'Gerät'} ausgewählt!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bluetooth-Gerät',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _scanDevices,
                  icon: _isScanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isScanning ? 'Scanne...' : 'Suchen'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Aktuelles Gerät
            if (widget.currentDeviceName != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bluetooth_connected, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.currentDeviceName!,
                            style: const TextStyle(fontWeight: FontWeight.w600),
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
                      icon: const Icon(Icons.delete),
                      onPressed: () => widget.onDeviceSelected(null, null),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Gefundene Geräte
            OutlinedButton.icon(
              onPressed: _isScanning ? null : () => _showDevicesDialog(),
              icon: const Icon(Icons.search),
              label: Text(widget.currentDeviceName ?? 'Gerät aus Liste wählen'),
            ),

            if (_scanResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_scanResults.length} Gerät${_scanResults.length != 1 ? 'e' : ''} gefunden',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: _scanResults.length,
                        itemBuilder: (context, index) {
                          final result = _scanResults[index];
                          final device = result.device;
                          final isSelected =
                              widget.currentDeviceId == device.remoteId.str;

                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              radius: 16,
                              child: Text('${result.rssi}'),
                            ),
                            title: Text(device.platformName ?? 'Unbekannt'),
                            subtitle: Text(device.remoteId.str),
                            trailing: isSelected
                                ? const Icon(Icons.check, color: Colors.green)
                                : IconButton(
                                    icon: const Icon(
                                      Icons.connect_without_contact,
                                    ),
                                    onPressed: () => _connectToDevice(device),
                                  ),
                            onTap: () => _connectToDevice(device),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDevicesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verfügbare Geräte'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: _scanResults.isEmpty
              ? const Center(
                  child: Text('Keine Geräte gefunden. Bitte "Suchen" drücken.'),
                )
              : ListView.builder(
                  itemCount: _scanResults.length,
                  itemBuilder: (context, index) {
                    final result = _scanResults[index];
                    final device = result.device;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        radius: 16,
                        child: Text('${result.rssi}'),
                      ),
                      title: Text(device.platformName ?? 'Unbekannt'),
                      subtitle: Text(device.remoteId.str),
                      onTap: () {
                        _connectToDevice(device);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );
  }
}
