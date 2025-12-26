import 'package:flutter/material.dart';
import 'package:kasir/provider/PrinterProvider.dart';
import 'package:provider/provider.dart';


class DialogNota extends StatefulWidget {

  final Map<dynamic, dynamic> cartDetail;

  const DialogNota({
    Key? key,
    required this.cartDetail,
  }) : super(key: key);

  @override
  State<DialogNota> createState() => _DialogNotaState();
}

class _DialogNotaState extends State<DialogNota> {
  String formatRupiah(num number) {
    return 'Rp ${number.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  

   @override
  void initState() {
    super.initState();
    // ketika load pertama kali
    Future.microtask(() => Provider.of<PrinterProvider>(context, listen: false).loadSavedPrinter());
  }

  

  @override
  Widget build(BuildContext context) {

    final printer = Provider.of<PrinterProvider>(context);
  
    void handlePrintNota() async {
      print('cetakk');
      var resTotal = 0;
      // num total = (widget.cartDetail['cartData'] as List).fold(0, (acc, item) => acc + (item['qty'] * item['harga']));
      widget.cartDetail['cartData'].forEach((val) {
        resTotal += int.parse(val['subTotal']);
      });


      // params
      final transaksi = {
        'items': widget.cartDetail['cartData'],
        'totalBelanja': resTotal,
        'bayar' : int.parse(widget.cartDetail['bayar']),
        'kembalian' : widget.cartDetail['kembalian'],
        'pelanggan' : widget.cartDetail['pelanggan'],
      };
      // print(transaksi);
      // print('transaksi');
      Map<String, dynamic> status = await printer.printRiwayatNota(transaksi);
    }

  // 
    var no = 1;
    int grandTotal = 0;
    // print(cartDetail['cartData']);
    List<TableRow> rows = widget.cartDetail['cartData'].map<TableRow>((row) {
      grandTotal += int.parse(row['subTotal']);
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text((no++).toString(), style: TextStyle(fontSize: 12,fontFamily: "Poppins"),),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(row['barang_nama'], style: TextStyle(fontSize: 12,fontFamily: "Poppins"),),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(row['qty'].toString(), style: TextStyle(fontSize: 12,fontFamily: "Poppins"), textAlign: TextAlign.center,),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: AlignmentGeometry.centerRight,
                child: row['stGrosir'] == 'yes' ? 
                    Column(
                      children: [
                        Text(formatRupiah(int.parse(row['barang_grosir_harga_jual'])), style: TextStyle(fontSize: 12,fontFamily: "Poppins",)),
                        Text(formatRupiah(int.parse(row['harga'])), style: TextStyle(decoration: TextDecoration.lineThrough, decorationColor: Colors.red, fontSize: 12,fontFamily: "Poppins", color: Colors.red))
                      ],
                  )
                : Text(formatRupiah(int.parse(row['harga'])), style: TextStyle(fontSize: 12,fontFamily: "Poppins"))
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(formatRupiah(int.parse(row['subTotal'])), style: TextStyle(fontSize: 12,fontFamily: "Poppins"), textAlign: TextAlign.right,),
            ),
          ]
        );
      }
    ).toList();
    // add total belanja
    rows.add(
      TableRow(
        children: [
          SizedBox(),
          SizedBox(),
          SizedBox(),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Belanja", style: TextStyle(color: Colors.black, fontSize: 12,fontFamily: "Poppins", fontWeight: FontWeight.bold), textAlign: TextAlign.right,),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(formatRupiah(grandTotal), style: TextStyle(color: Colors.black, fontSize: 12,fontFamily: "Poppins", fontWeight: FontWeight.bold), textAlign: TextAlign.right,),
          ),
        ]
      )
    );
    // uang
    rows.add(
      TableRow(
        children: [
          SizedBox(),
          SizedBox(),
          SizedBox(),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Bayar", style: TextStyle(color: Colors.red, fontSize: 12,fontFamily: "Poppins", fontWeight: FontWeight.bold), textAlign: TextAlign.right,),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(formatRupiah(int.parse(widget.cartDetail['bayar'])), style: TextStyle(color: Colors.red, fontSize: 12,fontFamily: "Poppins", fontWeight: FontWeight.bold), textAlign: TextAlign.right,),
          ),
        ]
      )
    );
    // kembalian
    rows.add(
      TableRow(
        children: [
          SizedBox(),
          SizedBox(),
          SizedBox(),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Kembalian", style: TextStyle(color: Colors.green, fontSize: 12,fontFamily: "Poppins", fontWeight: FontWeight.bold), textAlign: TextAlign.right,),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(formatRupiah(widget.cartDetail['kembalian']), style: TextStyle(color: Colors.green, fontSize: 12,fontFamily: "Poppins", fontWeight: FontWeight.bold), textAlign: TextAlign.right,),
          ),
        ]
      )
    );
    return SizedBox.expand(
      child: Column(
        children: [
          SizedBox(height: 10,),
          Text("Nota : ${widget.cartDetail['tanggal']} / ${widget.cartDetail['jam']}", style: TextStyle(fontSize: 12,fontFamily: "Poppins", fontWeight: FontWeight.bold),),
          Text("Pelanggan : ${widget.cartDetail['pelanggan']}", style: TextStyle(fontSize: 12,fontFamily: "Poppins", fontWeight: FontWeight.bold),),
          Expanded(
            flex: 11,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(left: 25, right: 25, bottom: 25, top: 15),
              child: Table(
                border: TableBorder.all(color: Colors.grey),
                columnWidths: const {
                  0: FixedColumnWidth(35),
                  1: FlexColumnWidth(),
                  2: FixedColumnWidth(60),
                  3: FixedColumnWidth(95),
                  4: FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Color.fromARGB(255, 0, 149, 255)),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text('No', style: TextStyle(color: Colors.white, fontSize: 12,fontFamily: "Poppins" )),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text('Barang', style: TextStyle(color: Colors.white, fontSize: 12,fontFamily: "Poppins" )),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text('Qty', style: TextStyle(color: Colors.white, fontSize: 12,fontFamily: "Poppins" )),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text('Harga', style: TextStyle(color: Colors.white, fontSize: 12,fontFamily: "Poppins" )),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text('SubTotal', style: TextStyle(color: Colors.white, fontSize: 12,fontFamily: "Poppins" )),
                        ),
                      ),
                    ]
                  ),
                  ...rows,
                ]
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsetsGeometry.directional(start: 20, end: 20, bottom: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => { handlePrintNota() },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(5)
                      ),
                      backgroundColor: Colors.blueAccent
                    ),
                    child: Text('Cetak', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white),),
                  ),
                  ElevatedButton(
                    onPressed: () => { Navigator.pop(context) },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(5)
                      ),
                      backgroundColor: Colors.red
                    ),
                    child: Text('Tutup', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white),),
                  )
                ],
              ),
            ),
          )
        ],
      )
    );      
  }
}