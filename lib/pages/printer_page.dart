// import 'package:flutter/material.dart';
// import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
// import 'package:intl/intl.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PrinterPage extends StatefulWidget {
//   const PrinterPage({super.key});

//   @override
//   State<PrinterPage> createState() => _PrinterPageState();
// }

// class _PrinterPageState extends State<PrinterPage> {
//   final PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
//   List<PrinterBluetooth> _devices = [];
//   bool _isScanning = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkPermissions();
//   }

//   Future<void> _checkPermissions() async {
//     await [
//       Permission.bluetooth,
//       Permission.bluetoothScan,
//       Permission.bluetoothConnect,
//       Permission.location,
//     ].request();
//   }

//   void _scanForPrinters() {
//     setState(() {
//       _isScanning = true;
//       _devices = [];
//     });

//     _printerManager.startScan(const Duration(seconds: 4));
//     _printerManager.scanResults.listen((devices) {
//       setState(() {
//         _devices = devices;
//         _isScanning = false;
//       });
//     });
//   }

//   Future<void> _saveSelectedPrinter(PrinterBluetooth printer) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('printer_name', printer.name ?? '');
//     await prefs.setString('printer_address', printer.address ?? '');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Printer tersimpan: ${printer.name ?? "Unknown"}')),
//     );
//   }

//   Future<void> _printTest(PrinterBluetooth printer) async {
//     _printerManager.selectPrinter(printer);

//     final profile = await CapabilityProfile.load();
//     final generator = Generator(PaperSize.mm58, profile);
//     final now = DateTime.now();
//     final date = DateFormat('dd/MM/yyyy HH:mm').format(now);

//     List<int> bytes = [];

//     bytes += generator.text(
//       'TOKO MAKMUR',
//       styles: PosStyles(
//         align: PosAlign.center,
//         bold: true,
//         height: PosTextSize.size2,
//         width: PosTextSize.size2,
//       ),
//     );
//     bytes += generator.text('Jl. Sudirman No. 12, Yogyakarta',
//         styles: PosStyles(align: PosAlign.center));
//     bytes += generator.text('Telp: 0812-3456-7890',
//         styles: PosStyles(align: PosAlign.center));
//     bytes += generator.hr();

//     bytes += generator.row([
//       PosColumn(
//           text: 'Kasir: Fajar', width: 6, styles: PosStyles(align: PosAlign.left)),
//       PosColumn(text: date, width: 6, styles: PosStyles(align: PosAlign.right)),
//     ]);
//     bytes += generator.hr();

//     bytes += generator.row([
//       PosColumn(text: 'Barang', width: 6, styles: PosStyles(bold: true)),
//       PosColumn(text: 'Qty', width: 2, styles: PosStyles(bold: true)),
//       PosColumn(
//           text: 'Harga',
//           width: 4,
//           styles: PosStyles(align: PosAlign.right, bold: true)),
//     ]);
//     bytes += generator.hr();

//     bytes += generator.row([
//       PosColumn(text: 'Indomie Goreng', width: 6),
//       PosColumn(text: '2', width: 2),
//       PosColumn(
//           text: '6.000', width: 4, styles: PosStyles(align: PosAlign.right)),
//     ]);
//     bytes += generator.row([
//       PosColumn(text: 'Teh Pucuk', width: 6),
//       PosColumn(text: '1', width: 2),
//       PosColumn(
//           text: '4.000', width: 4, styles: PosStyles(align: PosAlign.right)),
//     ]);
//     bytes += generator.row([
//       PosColumn(text: 'Aqua 600ml', width: 6),
//       PosColumn(text: '3', width: 2),
//       PosColumn(
//           text: '9.000', width: 4, styles: PosStyles(align: PosAlign.right)),
//     ]);
//     bytes += generator.hr();

//     bytes += generator.row([
//       PosColumn(
//           text: 'Total',
//           width: 8,
//           styles: PosStyles(
//               bold: true, align: PosAlign.left, height: PosTextSize.size2)),
//       PosColumn(
//           text: 'Rp 19.000',
//           width: 4,
//           styles: PosStyles(
//               bold: true, align: PosAlign.right, height: PosTextSize.size2)),
//     ]);

//     bytes += generator.hr(ch: '=', linesAfter: 1);
//     bytes += generator.text('Terima kasih telah berbelanja!',
//         styles: PosStyles(align: PosAlign.center));
//     bytes += generator.text(
//         'Barang yang sudah dibeli tidak dapat dikembalikan',
//         styles: PosStyles(align: PosAlign.center, bold: false));
//     bytes += generator.feed(2);
//     bytes += generator.cut();

//     final result = await _printerManager.printTicket(bytes);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(result.msg)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pilih Printer Bluetooth'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _scanForPrinters,
//           ),
//         ],
//       ),
//       body: _isScanning
//           ? const Center(child: CircularProgressIndicator())
//           : _devices.isEmpty
//               ? const Center(child: Text('Tidak ada printer ditemukan'))
//               : ListView.builder(
//                   itemCount: _devices.length,
//                   itemBuilder: (context, index) {
//                     final printer = _devices[index];
//                     return Card(
//                       margin:
//                           const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       child: ListTile(
//                         leading: const Icon(Icons.print),
//                         title: Text(printer.name ?? 'Unknown'),
//                         subtitle: Text(printer.address ?? ''),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             ElevatedButton(
//                               onPressed: () async {
//                                 await _saveSelectedPrinter(printer);
//                               },
//                               child: const Text('Pilih'),
//                             ),
//                             const SizedBox(width: 6),
//                             ElevatedButton(
//                               onPressed: () => _printTest(printer),
//                               child: const Text('Tes Print'),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _scanForPrinters,
//         icon: const Icon(Icons.search),
//         label: const Text('Scan Printer'),
//       ),
//     );
//   }
// }
