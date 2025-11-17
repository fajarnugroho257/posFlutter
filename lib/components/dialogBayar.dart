import 'package:flutter/material.dart';
import 'package:kasir/components/NumberPadFull.dart';
import 'package:kasir/provider/PrinterProvider.dart';
import 'package:kasir/provider/cart_provider.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class DialogBayar extends StatefulWidget {
  const DialogBayar({super.key});

  @override
  State<DialogBayar> createState() => _DialogBayarState();
}

class _DialogBayarState extends State<DialogBayar> {
  final TextEditingController pelangganController = TextEditingController();
  // final TextEditingController nominalController = TextEditingController();
  int kembalian = 0;

  @override
  void dispose() {
    pelangganController.dispose();
    // nominalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // ketika load pertama kali
    Future.microtask(() => Provider.of<PrinterProvider>(context, listen: false).loadSavedPrinter());
    // nominalController.addListener(() {
    //   if (nominalController.text == "0") {
    //     nominalController.clear();
    //   }
    // });
    // 
  }

  String input = '0';

  @override
  Widget build(BuildContext context) {
    
    String formatRupiah(num number) {
      return 'Rp ${number.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    }

    final ttlBelanja = context.watch<CartProvider>().totalBelanja;

    final printer = Provider.of<PrinterProvider>(context);
    
    Future<Map<String, dynamic>> cetakStruk(BuildContext context) async {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final cartItems = cartProvider.cartItems;
      // print(cartItems);
      final total = ttlBelanja;
      final transaksi = {
        'items': cartItems,
        'totalBelanja': total,
        // 'bayar' : int.parse(nominalController.text.replaceAll('.', '')),
        'bayar' : input,
        'kembalian' : kembalian,
        'pelanggan' : pelangganController.text,
      };
      // print(transaksi);
      Map<String, dynamic> status = await printer.printStrukKasir(transaksi);
      return status;
    }

    void _handlePress(String value) {
      setState(() {
        input += value;
        kembalian = int.parse(input) - ttlBelanja;
      });
    }
    void _handleClear() {
      setState(() {
        var jlh = input.length;
        if (jlh > 1) {
          input = input.substring(0, input.length - 1);
          kembalian = int.parse(input) - ttlBelanja;
        }
      });
    }

    void _handleConfirm() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nominal dikonfirmasi: $input')),
      );
    }

    void _handleDelete() {
      setState(() {
        var jlh = input.length;
        if (jlh > 1) {
          input = '0';
          kembalian = 0 - ttlBelanja;
        }
      });
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          child: SafeArea(
            bottom: false,
            child: Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Pembayaran', style: TextStyle(fontSize: 17, fontFamily: "Poppins", fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Nominal", style: TextStyle(fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.bold)),
                          Text(formatRupiah(int.parse(input) ), style: TextStyle(fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                    SizedBox(height: 8,),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tagihan", style: TextStyle(color: Colors.red, fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.bold)),
                          Text(formatRupiah(ttlBelanja), style: TextStyle(color: Colors.red, fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.black26,
                      thickness: 1,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Kembalian", style: TextStyle(color: Colors.green, fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.bold)),
                          Text(formatRupiah(kembalian), style: TextStyle(color: Colors.green, fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    // TextField(
                    //   controller: nominalController,
                    //   textAlign: TextAlign.right,
                    //   inputFormatters: [
                    //     MoneyInputFormatter(
                    //       thousandSeparator: ThousandSeparator.Period, // pakai titik (.)
                    //       mantissaLength: 0, // tidak ada desimal
                    //     ),
                    //   ],
                    //   style: TextStyle(fontSize: 13, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                    //   keyboardType: TextInputType.number,
                    //   decoration: InputDecoration(
                    //     hintText: 'Masukkan Nominal',
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    //   ),
                    //   onChanged: (value){
                    //     setState(() {
                    //       nominalController.value = value != "" ? nominalController.value : TextEditingValue(text: "0");
                    //       kembalian = int.parse(nominalController.text.replaceAll('.', '')) - int.parse((ttlBelanja.toString()).replaceAll('Rp ', '').replaceAll('.', ''));
                    //     });
                    //   },
                    // ),
                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: Text('*Wajib diisi', style: TextStyle(color: Colors.red, fontSize: 12, fontFamily: "Poppins",)),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 15,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.all(16),
                          ),
                          onPressed: () => _handleDelete(),
                          child: const Text('X', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(
                          width: MediaQuery.widthOf(context) * (65/100),
                          child: NumberPadFull(
                            onPressed: _handlePress,
                            onClear: _handleClear,
                            onConfirm: _handleConfirm,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      textAlign: TextAlign.right,
                      controller: pelangganController,
                      style: TextStyle(fontSize: 13, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'Nama Pelanggan (Opsional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('*Optional', style: TextStyle(color: Colors.green, fontSize: 12, fontFamily: "Poppins",)),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Divider(
                      color: Colors.black26,
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Color.fromARGB(255, 255, 3, 3),
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            textStyle: TextStyle(fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.w500)
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Batal", style: TextStyle(color: Colors.white),),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Color.fromARGB(255, 0, 149, 255),
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            textStyle: TextStyle(fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.w500)
                          ),
                          onPressed: () async {
                            if(kembalian < 0 || int.parse(input) == 0){
                              showDialog(context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Error', style: TextStyle(fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.bold),),
                                    content: Text('Nominal yang anda masukkan kurang dari total tagihan.', style: TextStyle(fontSize: 14, fontFamily: "Poppins"),),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('OK', style: TextStyle(fontFamily: "Poppins"),),
                                      ),
                                    ],
                                  );
                                }
                              );
                            } else {
                              Map<String, dynamic> status = await cetakStruk(context);
                              if(status['simpanData']){
                                Navigator.pop(context);
                                showDialog(context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Sukses', style: TextStyle( color: Colors.green, fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.bold),),
                                      content: Text('Data berhasil disimpan dilocal storage.', style: TextStyle(fontSize: 14, fontFamily: "Poppins"),),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('OK', style: TextStyle(fontFamily: "Poppins"),),
                                        ),
                                      ],
                                    );
                                  }
                                );
                              } else {
                                showDialog(context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Error', style: TextStyle(fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.bold),),
                                      content: Text('Data gagal disimpan.', style: TextStyle(fontSize: 14, fontFamily: "Poppins"),),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('OK', style: TextStyle(fontFamily: "Poppins"),),
                                        ),
                                      ],
                                    );
                                  }
                                );
                              }
                            }
                          },
                          child: Text("Bayar", style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ),
          ),
        ),
      ),
    );
  }
}