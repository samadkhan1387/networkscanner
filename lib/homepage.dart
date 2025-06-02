import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> scannedDevices = [];
  bool isScanning = false;

  Future<void> scanNetwork() async {
    setState(() {
      isScanning = true;
      scannedDevices.clear();
    });

    final info = NetworkInfo();
    final ip = await info.getWifiIP();
    if (ip == null) {
      setState(() {
        isScanning = false;
      });
      return;
    }

    final subnet = ip.substring(0, ip.lastIndexOf('.'));
    final scanner = LanScanner();
    final hosts = await scanner.quickIcmpScanAsync(subnet);

    for (var host in hosts) {
      final ipAddr = host.internetAddress.address;

      // ✅ Add 4370 to the list of ports to check
      final openPorts = await scanPorts(ipAddr,
          [21, 22, 23, 53, 80, 135, 139, 443, 445, 514, 515, 902, 912, 4370]);

      scannedDevices.add({
        'ip': ipAddr,
        'ports': openPorts,
      });

      setState(() {}); // Update UI after each IP scan
    }

    setState(() {
      isScanning = false;
    });
  }

  Future<List<int>> scanPorts(String ip, List<int> ports) async {
    List<int> openPorts = [];

    for (var port in ports) {
      try {
        final socket = await Socket.connect(ip, port,
            timeout: const Duration(milliseconds: 500));
        openPorts.add(port);
        socket.destroy();
      } catch (_) {
        // Port closed, do nothing
      }
    }

    return openPorts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF01081C),
        // leading: IconButton(
        //   icon: const Icon(Icons.menu, color: Color(0xFF12e19f), size: 25),
        //   onPressed: () {
        //     // Menu action
        //   },
        // ),
        title: Image.asset('assets/appbar.png', height: 35),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt,
                size: 30, color: Color(0xFF12e19f)),
            onPressed: () {
              setState(() {
                scannedDevices.clear();
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isScanning ? null : scanNetwork,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF01081C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isScanning
                        ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF12e19f),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Scanning...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF12e19f),
                          ),
                        ),
                      ],
                    )
                        : const Text(
                      'Scan Network',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF12e19f),
                      ),
                    ),

                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: scannedDevices.isEmpty && !isScanning
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/search.png', // replace with your actual logo asset
                    height: 150,
                  ),
                  const SizedBox(height: 0),
                  const Text(
                    'No scan results yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              itemCount: scannedDevices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final device = scannedDevices[index];
                final ip = device['ip'];
                final ports = device['ports'] as List<int>;
                return Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF01081C), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset('assets/ip.png', width: 20, height: 20),
                                const SizedBox(width: 6),
                                Text(
                                  ip,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF01081C),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset('assets/port.png',
                                    width: 20, height: 20),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    ports.isNotEmpty
                                        ? 'Ports: ${ports.join(', ')}'
                                        : 'No open ports found',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ports.isNotEmpty
                                          ? Colors.black87
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
