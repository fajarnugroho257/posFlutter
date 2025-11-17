import 'package:flutter/material.dart';
import 'package:kasir/provider/cart_provider.dart';
import 'package:provider/provider.dart';

class TableCart extends StatefulWidget {
  const TableCart({super.key});

  @override
  State<TableCart> createState() => _TableCartState();
}

class _TableCartState extends State<TableCart> {

  String formatRupiah(num number) {
    return 'Rp${number.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {

    final provCart = Provider.of<CartProvider>(context);
    // nomor urut
    var no = 1;
    return Column(
      children: [
        Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const {
            0: FixedColumnWidth(35),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
            // 2: FixedColumnWidth(90),
            3: FixedColumnWidth(85),
            4: FlexColumnWidth(),
            5: FixedColumnWidth(35),
          },
          children: [
            const TableRow(
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
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text('X', style: TextStyle(color: Colors.white, fontSize: 12,fontFamily: "Poppins" )),
                  ),
                ),
              ],
            ),
            // Isi tabel dari variabel
            ...provCart.cartItems.map((row) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text((no++).toString()   , style: TextStyle(fontSize: 12,fontFamily: "Poppins"),),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(row['barang_master']['barang_nama'] ?? '', style: TextStyle(fontSize: 12,fontFamily: "Poppins"),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          child: SizedBox(
                            width: 25,
                            height: 25,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                                color: Colors.red
                              ),
                              child: Align(
                                alignment: AlignmentGeometry.center,
                                child: Text("-", style: TextStyle(fontSize: 18,fontFamily: "Poppins", fontWeight: FontWeight.bold))
                              ),
                            ),
                          ),
                          onTap: () {
                            final newQty = (row['qty'] - 1).clamp(1, 9999);
                            Provider.of<CartProvider>(context, listen: false).updateQty(row['id'], newQty);
                          },
                        ),
                        SizedBox(
                          width: 25,
                          height: 25,
                          child: Container(
                            decoration: BoxDecoration(
                              border: BoxBorder.symmetric(horizontal: BorderSide(width: 1, color: Colors.black12)),
                            ),
                            child: Align(
                              alignment: AlignmentGeometry.center,
                              child: Text(row['qty'].toString(), style: TextStyle(fontSize: 12,fontFamily: "Poppins", fontWeight: FontWeight.bold)),
                            ),
                          )
                        ),
                        GestureDetector(
                          child: SizedBox(
                            width: 25,
                            height: 25,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                                color: Colors.green
                              ),
                              child: Align(
                                alignment: AlignmentGeometry.center,
                                child: Text("+", style: TextStyle(fontSize: 18,fontFamily: "Poppins", fontWeight: FontWeight.bold))
                              ),
                            ),
                          ),
                          onTap: () {
                            final newQty = (row['qty'] + 1).clamp(1, 9999);
                            Provider.of<CartProvider>(context, listen: false).updateQty(row['id'], newQty);
                          },
                        ),
                      ],
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: row['stGrosir'] == 'yes' ? 
                            Column(
                              children: [
                                Text(formatRupiah(int.parse(row['barang_master']['barang_grosir_harga_jual'])), style: TextStyle(fontSize: 12,fontFamily: "Poppins",), textAlign: TextAlign.right, ),
                                Text(formatRupiah(int.parse(row['barang_master']['barang_harga_jual'])), style: TextStyle(decoration: TextDecoration.lineThrough, decorationColor: Colors.red, fontSize: 12,fontFamily: "Poppins", color: Colors.red), textAlign: TextAlign.right, )
                              ],
                            )
                            : Text(formatRupiah(int.parse(row['barang_master']['barang_harga_jual'])), style: TextStyle(fontSize: 12,fontFamily: "Poppins"), textAlign: TextAlign.right, )
                      ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(formatRupiah(int.parse(row['subTotal'])), style: TextStyle(fontSize: 12,fontFamily: "Poppins"),),
                      ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Provider.of<CartProvider>(context, listen: false).removeFromCart(row);
                      },
                      child: const Icon(Icons.delete, size: 27, color: Colors.red),
                    ),
                  ),
                ],
              );
            }),
          ],
        )
      ],
    );
  }
}