import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:hive/hive.dart';

class PrinterProvider with ChangeNotifier {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  BluetoothDevice? _connectedDevice;
  List<BluetoothDevice> _availableDevices = [];

  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<BluetoothDevice> get availableDevices => _availableDevices;

  Future<void> scanDevices() async {
    try {
      final devices = await bluetooth.getBondedDevices();
      _availableDevices = devices;
      notifyListeners();
    } catch (e) {
      debugPrint("Error scanning printer: $e");
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    try {
      await bluetooth.connect(device);
      _connectedDevice = device;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('printer_name', device.name ?? '');
      await prefs.setString('printer_address', device.address ?? '');

      notifyListeners();
    } catch (e) {
      debugPrint("Error connecting: $e");
    }
  }

  Future<void> loadSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('printer_name');
    final address = prefs.getString('printer_address');
    if (address != null) {
      _connectedDevice = BluetoothDevice(name, address);
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    await bluetooth.disconnect();
    _connectedDevice = null;
    notifyListeners();
  }

  Future<void> testPrint() async {
    if (_connectedDevice == null) return;

    bluetooth.isConnected.then((isConnected) {
      if (isConnected!) {
        bluetooth.printNewLine();
        bluetooth.printCustom("=== TES CETAK ===", 3, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("Printer aktif dan siap digunakan.", 1, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("Terima kasih!", 1, 1);
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
  }

  String rupiah(int value) {
    final format = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    return format.format(value);
  }

  String newCartId() {
    final cartId = DateTime.now().toIso8601String().replaceAll(RegExp(r'\D'), '') + (1000 + Random().nextInt(9000)).toString();
    return cartId;
  }

  // Future<void> deleteCartItem(int id) async {
  //   var box = await Hive.openBox('cart');
    
  //   // Ambil semua item
  //   List cartItems = box.get('cart_items', defaultValue: []);
    
  //   // Hapus item dengan id tertentu
  //   cartItems.removeWhere((item) => item['id'] == id);
    
  //   // Simpan kembali list yang sudah difilter
  //   await box.put('cart_items', cartItems);
  // }

  Future<bool> simpanData(Map<String, dynamic> transaksi) async {
    // var
    // print(transaksi);
    final cartId = newCartId();
    bool success = false;
    final now = DateTime.now();
    final tanggal = DateFormat('yyyy-MM-dd').format(now);
    final jam = DateFormat('HH:mm:ss').format(now);
    final List items = transaksi['items'];
    final pelanggan = transaksi['pelanggan'];
    final totalBelanja = transaksi['totalBelanja'];
    final bayar = transaksi['bayar'];
    final kembalian = transaksi['kembalian'];
    final newData = items.map((item) {
      // print(item);
      return {
        'id': item['id'],
        'barang_id': item['barang_id'],
        'barang_nama': item['barang_master']['barang_nama'],
        'barang_harga_beli': item['barang_master']['barang_harga_beli'],
        'qty': item['qty'],
        'harga': item['barang_master']['barang_harga_jual'],
        'subTotal': item['subTotal'],
        'barang_barcode': item['barang_master']['barang_barcode'],
        'barang_grosir_harga_jual': item['barang_master']['barang_grosir_harga_jual'],
        'stGrosir': item['stGrosir'],        
      };
    }).toList();
    // process
    try {
      // print(newData);
      var box = await Hive.openBox('transactions');
      var key = await box.add({
        'cartId': cartId,
        'tanggal': tanggal,
        'jam': jam,
        'cartData': newData,
        'pelanggan': pelanggan,
        'totalBelanja': totalBelanja,
        'bayar': bayar,
        'kembalian': kembalian,
        'stUpload' : false,
      });
      if (key is int) {
        success = true;
        print("Sukses meyimpan data");
      }
    } catch (e) {
      success = false; // gagal
      print('Gagal menyimpan data: $e');
    }
    // var box = await Hive.openBox('transactions');
    // List transaksiList = box.values.toList();
    // print(transaksiList);
    // List cart = box.get('cart_items', defaultValue: []);
    // print(cart);
    return success;
  }

  // Cetak struk kasir rapi untuk printer 58mm
  Future<Map<String, dynamic>> printStrukKasir(Map<String, dynamic> transaksi) async {
    bool sukses  = await simpanData(transaksi);
    bool stSimpanData = false;
    // 
    if(sukses){
      // status simpan data
      stSimpanData = true;
      // print(transaksi);
      // bool? isConnected = await bluetooth.isConnected;
      // if (isConnected == true) {
      //   bluetooth.printCustom("TOKO SAMEERA", 3, 1);
      //   bluetooth.printCustom("SAMEERA 1", 1, 1);
      //   bluetooth.printCustom(DateFormat('MM/dd/yyyy, hh:mm:ss a').format(DateTime.now()), 0, 1);
      //   bluetooth.printCustom("=============================", 1, 1);
      //   bluetooth.printCustom("| Item          |Qty|  Price |", 0, 0);
      //   bluetooth.printCustom("=============================", 1, 1);

      //   for (var item in transaksi['items']) {
      //     final nama = item['barang_master']['barang_nama'];
      //     final harga = item['barang_master']['barang_harga_jual'];
      //     final qty = item['qty'];
      //     final subtotal = item['subTotal'];
      //     // Baris nama barang (bisa panjang, pindah baris)
      //     bluetooth.printCustom("| ${nama}", 0, 0);
      //     // Baris harga + qty + subtotal, rata kanan
      //     final hargaStr = rupiah(int.parse(harga)).padRight(9);
      //     final qtyStr = qty.toString().padLeft(2);
      //     final subStr = rupiah(int.parse(subtotal)).padLeft(10);
      //     bluetooth.printCustom("| ${hargaStr} |$qtyStr| $subStr |", 0, 0);
      //   }

      //   bluetooth.printCustom("=============================", 1, 1);
      //   bluetooth.printCustom("| Total".padRight(22) + rupiah(transaksi['total']).padLeft(10) + " |", 0, 0);
      //   bluetooth.printCustom("-----------------------------", 1, 1);
      //   bluetooth.printCustom("| Bayar".padRight(22) + rupiah(transaksi['bayar']).padLeft(10) + " |", 0, 0);
      //   bluetooth.printCustom("| Kembalian".padRight(19) + rupiah(transaksi['kembalian']).padLeft(10) + " |", 0, 0);
      //   bluetooth.printCustom("=============================", 1, 1);
      //   bluetooth.printCustom("     Terimakasih", 2, 1);
      //   bluetooth.printNewLine();
      //   bluetooth.paperCut();
      //   // print(transaksi['bayar']);
      //   // print(transaksi['kembalian']);
      // } else {
      //   print("Printer belum terkoneksi!");
      // }
    } else {
      stSimpanData = false;
      print('Simpan data gagal!');
    }
    return {
      'simpanData': stSimpanData
    };
  }
}
