import 'package:flutter/material.dart';
import 'package:kasir/components/sideBar.dart';
import 'package:kasir/provider/PrinterProvider.dart';
import 'package:provider/provider.dart';

class PrinterSettingPage extends StatefulWidget {
  const PrinterSettingPage({super.key});

  @override
  State<PrinterSettingPage> createState() => _PrinterSettingPageState();
}

class _PrinterSettingPageState extends State<PrinterSettingPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<PrinterProvider>(context, listen: false).loadSavedPrinter());
  }

  @override
  Widget build(BuildContext context) {
    final printer = Provider.of<PrinterProvider>(context);
    return Scaffold(
      drawer: SideBar(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 149, 255),
        title: Center(
          child: Text('Printer', 
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(2, 1),
                  blurRadius: 2
                )
              ],
            )
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: 
            [
              ElevatedButton.icon(
                onPressed: () => printer.scanDevices(),
                icon: const Icon(Icons.search),
                label: const Text("Scan Printer Bluetooth"),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: printer.availableDevices.length,
                  itemBuilder: (context, index) {
                    final device = printer.availableDevices[index];
                    return ListTile(
                      title: Text(device.name ?? "Tidak diketahui"),
                      subtitle: Text(device.address ?? ""),
                      trailing: printer.connectedDevice?.address == device.address
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () => printer.connect(device),
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: printer.testPrint,
                icon: const Icon(Icons.print),
                label: const Text("Tes Cetak"),
              ),
              ElevatedButton.icon(
                onPressed: printer.disconnect,
                icon: const Icon(Icons.print),
                label: const Text("Reset"),
              ),
            ],
          ),
        )
      )
    );
    // return Scaffold(
    //   appBar: AppBar(title: const Text("Pengaturan Printer")),
    //   body: Padding(
    //     padding: const EdgeInsets.all(16),
    //     child: Column(
    //       children: [
    //         ElevatedButton.icon(
    //           onPressed: () => printer.scanDevices(),
    //           icon: const Icon(Icons.search),
    //           label: const Text("Scan Printer Bluetooth"),
    //         ),
    //         const SizedBox(height: 12),
    //         Expanded(
    //           child: ListView.builder(
    //             itemCount: printer.availableDevices.length,
    //             itemBuilder: (context, index) {
    //               final device = printer.availableDevices[index];
    //               return ListTile(
    //                 title: Text(device.name ?? "Tidak diketahui"),
    //                 subtitle: Text(device.address ?? ""),
    //                 trailing: printer.connectedDevice?.address == device.address
    //                     ? const Icon(Icons.check, color: Colors.green)
    //                     : null,
    //                 onTap: () => printer.connect(device),
    //               );
    //             },
    //           ),
    //         ),
    //         ElevatedButton.icon(
    //           onPressed: printer.testPrint,
    //           icon: const Icon(Icons.print),
    //           label: const Text("Tes Cetak"),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
