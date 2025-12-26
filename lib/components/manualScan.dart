import 'package:flutter/material.dart';
import 'package:kasir/provider/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

class ManualScan extends StatefulWidget {
  const ManualScan({super.key});

  @override
  State<ManualScan> createState() => _ManualScanState();
}

class _ManualScanState extends State<ManualScan> {
  // data option
  List daftarBarang = [];

  Future<void> loadBarang() async {
    final box = Hive.box('dataBox');
    // set 
    setState(() {
      daftarBarang = box.get('dataBarang', defaultValue: []);
    });
  }

  @override
  void initState() {
    super.initState();
    loadBarang();
  } 

  int jml = 0;
  handleInput(String val) {
    jml = val.length;
    if (jml >= 10) {
      final hasil = daftarBarang.firstWhere((data) => data['barang_master']['barang_barcode'] == val);
      if(!hasil.isEmpty){
        // set default
        hasil['subTotal'] = hasil['barang_master']['barang_harga_jual'];
        hasil['qty'] = 1;
        var respon = Provider.of<CartProvider>(context, listen: false).addToCart(
          hasil
        );
        if(respon['status']){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${hasil['barang_master']['barang_nama']} berhasil ditambah', style: TextStyle(fontFamily: "Poppins"),),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
          handleClearInput();
          return true;
        } else {
          showDialog(context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                title: Text('Error', style: TextStyle(fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.red),),
                content: Text('${hasil['barang_master']['barang_nama']} sudah tersedia di keranjang silahkan untuk menambah QTY', style: TextStyle(fontSize: 14, fontFamily: "Poppins"),),
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
          handleClearInput();
          return false;
        }
        // print(respon);
      } else {
        print('tidak ada');
      }
    }
  }

  // handle text search
  final TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  void handleClearInput() {
    searchController.clear();
    FocusScope.of(context).requestFocus(focusNode);
  }

  @override
  Widget build(BuildContext context) {    
    return Row(
      children: [
        Expanded(
          child: TextField(
          // readOnly: true,
            focusNode: focusNode,
            controller: searchController,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: TextStyle(fontFamily: "Poppins"),
            decoration: InputDecoration(
              border: OutlineInputBorder()
            ),
            onChanged: handleInput,
          ),
        ),
        SizedBox(width: 5,),
        SizedBox(
          height: 48,
          width: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: EdgeInsets.all(4),
              backgroundColor: Colors.red
            ),
            onPressed: () => {
              handleClearInput()
            },
            child: Icon(Icons.close, color: Colors.white)
          ),
        )
      ]
    );
  }
}