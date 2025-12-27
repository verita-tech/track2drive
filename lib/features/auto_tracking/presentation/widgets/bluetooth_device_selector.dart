import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
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
  BluetoothConnection? _connection;
  List<BluetoothDevice> _devices = [];
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
    setState(() => _isScanning = true);
    _devices.clear();

    FlutterBluetoothSerial.instance
        .startDiscovery()
        .listen((r) {
          setState(() {
            _devices.add(r.device);
          });
        })
        .onDone(() {
          setState(() => _isScanning = false);
        });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      widget.onDeviceSelected(device.address, device.name);
      _connection?.close();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Verbindung fehlgeschlagen: $e')));
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
            OutlinedButton.icon(
              onPressed: _isScanning ? null : () => _showDevicesDialog(),
              icon: const Icon(Icons.search),
              label: Text(widget.currentDeviceName ?? 'Gerät aus Liste wählen'),
            ),
            if (_devices.isNotEmpty)
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
                      '${_devices.length} Gerät${_devices.length != 1 ? 'e' : ''} gefunden',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: _devices.length,
                        itemBuilder: (context, index) {
                          final device = _devices[index];
                          final isSelected =
                              widget.currentDeviceId == device.address;
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              isSelected
                                  ? Icons.bluetooth_connected
                                  : Icons.bluetooth,
                              color: isSelected ? Colors.green : null,
                            ),
                            title: Text(device.name ?? 'Unbekannt'),
                            subtitle: Text(device.address),
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
          child: _devices.isEmpty
              ? const Center(child: Text('Keine Geräte gefunden'))
              : ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return ListTile(
                      leading: const Icon(Icons.bluetooth),
                      title: Text(device.name ?? 'Unbekannt'),
                      subtitle: Text(device.address),
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
