import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:kasir/provider/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

class SelectOption extends StatefulWidget {
  const SelectOption({super.key});

  @override
  State<SelectOption> createState() => _SelectOptionState();
}

class _SelectOptionState extends State<SelectOption> {
  // data option
  List daftarBarang = [];

  @override
  void initState() {
    super.initState();
    loadBarang();
  } 

  Future<void> loadBarang() async {
    final box = Hive.box('dataBox');
    // set 
    setState(() {
      daftarBarang = box.get('dataBarang', defaultValue: []);
    });
  }

  String? selectedValue;
  
  // array temp cart
  final List<String> selectedList = [];

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    // print(daftarBarang);

    return DropdownButtonHideUnderline(
      child: daftarBarang.isEmpty ? const Center(child: Text('Data belum ada di Hive')) : 
      // Text("hai")
      DropdownButton2<String>(
        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.only(left: 1, right: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.black26,
            ),
            color: Colors.white,
          ),
          elevation: 2,
        ),
        isExpanded: true,
        hint: const Text('Pilih barang...', style: TextStyle(fontSize: 12, fontFamily: "Poppins")),
        // value: selectedValue,
        items: daftarBarang.map((item) {
          return DropdownMenuItem<String>(
            value: item['id'].toString(),
            child: Text(
              item['barang_master']['barang_barcode'] + " | " + item['barang_master']['barang_nama'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.black,
                fontFamily: "Poppins"
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            // print(value);
            var data = daftarBarang.firstWhere((element) => element['id'].toString() == value);
            // set default
            data['subTotal'] = data['barang_master']['barang_harga_jual'];
            data['qty'] = 1;
            var respon = Provider.of<CartProvider>(context, listen: false).addToCart(
              data
            );
            if(respon['status']){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${data['barang_master']['barang_nama']} berhasil ditambah', style: TextStyle(fontFamily: "Poppins"),),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ),
              );
            } else {
              showDialog(context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Error', style: TextStyle(fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.red),),
                    content: Text('${data['barang_master']['barang_nama']} sudah tersedia di keranjang silahkan untuk menambah QTY', style: TextStyle(fontSize: 14, fontFamily: "Poppins"),),
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
          });
        },
        // Fitur Search
        dropdownSearchData: DropdownSearchData(
          searchController: searchController,
          searchInnerWidgetHeight: 50,
          searchInnerWidget: Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              autofocus: true,
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari Barang...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: TextStyle(fontSize: 11, fontFamily: "Poppins")
            ),
          ),
          searchMatchFn: (dropdownItem, searchValue) {
            final data = daftarBarang.firstWhere(
              (item) => item['id'].toString() == dropdownItem.value,
            );
            final nama = data['barang_master']?['barang_nama']?.toString().toLowerCase() ?? '';
            final barcode = data['barang_master']?['barang_barcode']?.toString().toLowerCase() ?? '';
            final cari = searchValue.toLowerCase();
            // return true kalau cocok di nama atau barcode
            return nama.contains(cari) || barcode.contains(cari);
          },
        ),
        // clear search ketika dropdown ditutup
        onMenuStateChange: (isOpen) {
          if (!isOpen) {
            searchController.clear();
          }
        },
      ),
    );
  }
}