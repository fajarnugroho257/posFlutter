import 'package:flutter/material.dart';
import 'package:kasir/components/bayarSekarang.dart';
import 'package:kasir/components/manualScan.dart';
import 'package:kasir/components/selectoption.dart';
import 'package:kasir/components/sideBar.dart';
import 'package:kasir/components/tableCart.dart';
import 'package:kasir/provider/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';



class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

  String formatRupiah(num number) {
    return 'Rp${number.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
  
class _HomepageState extends State<Homepage> {
  
  String pilihan = 'barcode';

  void ubahPilihan(String status) {
    setState(() {
      pilihan = status;
    });
  }
  String cabang_nama = '';

  final box = Hive.box('dataBox');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_nama_cabang();
  }

  void get_nama_cabang() {
    setState(() {
      cabang_nama = box.get('cabang_nama', defaultValue: "");
    });
  }

  @override
  Widget build(BuildContext context) {
    var totalBelanja =  context.watch<CartProvider>().totalBelanja;
    return Scaffold(
      drawer: SideBar(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 149, 255),
        title: Center(
          child: Text(cabang_nama, 
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w300,
            )
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // === Bagian atas: tombol mode ===
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => ubahPilihan('barcode'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pilihan == 'barcode' ? Colors.blue : Colors.white,
                      foregroundColor: pilihan == 'barcode' ? Colors.white : Colors.black,
                    ),
                    child: const Text("BARCODE"),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => ubahPilihan('manual'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pilihan == 'manual' ? Colors.blue : Colors.white,
                      foregroundColor: pilihan == 'manual' ? Colors.white : Colors.black,
                    ),
                    child: const Text("MANUAL"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // === Input / Select Option ===
            pilihan == 'barcode'
                ? ManualScan()
                : SelectOption(),

            const SizedBox(height: 10),

            // === Total Belanja ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Total Belanja: ${formatRupiah(totalBelanja)}",
                style: TextStyle(fontSize: 14, fontFamily: "Poppins", fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // === Tabel barang (scrollable) ===
            Expanded(
              child: SingleChildScrollView(
                child: TableCart(), // <-- pastikan ini bukan ListView lagi
              ),
            ),

            const SizedBox(height: 10),

            // === Tombol Bayar (fixed di bawah) ===
            // SizedBox(
            //   width: double.infinity,
            //   height: 50,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       // aksi bayar
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.green,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //     ),
            //     child: const Text(
            //       "BAYAR SEKARANG",
            //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),
            BayarSekarang(),
          ],
        ),
      ),
    ),

      // bottomNavigationBar: Container( // ini FOOTER
      //   color: Colors.blue,
      //   height: 50,
      //   // child: ,
      //   child: Align(
      //     alignment: Alignment.bottomRight,
      //     child: Padding(padding: EdgeInsets.only(right: 16, bottom: 15), 
      //       child: Text(
      //       'POS Kasir - 2025',
      //       style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontSize: 11, fontWeight: FontWeight.bold),
      //     ),
      //     ),
      //   ),
      // ),
    );
  }
}