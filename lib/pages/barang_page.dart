import 'package:flutter/material.dart';
import 'package:kasir/components/sideBar.dart';
import 'package:hive/hive.dart';
import 'package:kasir/services/api_service.dart';

class BarangPage extends StatefulWidget {
  const BarangPage({super.key});

  @override
  State<BarangPage> createState() => _BarangPageState();
}

class _BarangPageState extends State<BarangPage> {
  List listDataMasterBarang = [];
  List tempListDataMasterBarang = [];

  @override
  void initState() {
    super.initState();
    loadBarang();
  }
  // 
  Future<void> loadBarang() async {
    // print("load");
    final box = Hive.box('dataBox');
    final dataBarang = box.get('dataBarang');
    print(dataBarang);
    setState(() {
      listDataMasterBarang = dataBarang;
      tempListDataMasterBarang = dataBarang;
    });
  }

  // String formatRupiah(num number) {
  //   return 'Rp ${number.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  // }

  String formatRupiah(num number) {
    int asInt = number.toInt();
    return 'Rp ${asInt.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  void handleSyncBarang () async {
    final box = Hive.box('dataBox');
    var loginToken = box.get('loginToken', defaultValue: "");
    print(loginToken);
    final response = await ApiService().postData('get-data-barang-by-token', {
      'token_value' : loginToken,
    });
    loadBarang();
  }

  @override
  Widget build(BuildContext context) {
    var no = 1;
  // print(listDataMasterBarang);
    return Scaffold(
      drawer: SideBar(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 149, 255),
        title: Center(
          child: Text('POS Kasir', 
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
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      style: TextStyle(fontFamily: "Poppins", fontSize: 12),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nama Barang',
                        labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12),
                        hintText: 'Barcode / Nama barang',
                        hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value.isNotEmpty) {
                            final hasil = listDataMasterBarang.where((data) =>
                              (data['barang_master']['barang_nama'].toLowerCase() +
                              data['barang_master']['barang_barcode'])
                              .contains(value.toLowerCase())
                            ).toList();

                            tempListDataMasterBarang = hasil;
                          } else {
                            tempListDataMasterBarang = listDataMasterBarang;
                          }
                        });
                      },
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
                        padding: EdgeInsets.all(4)
                      ),
                      onPressed: () => {
                        handleSyncBarang()
                      },
                      child: Icon(Icons.sync)
                    ),
                  )
                ],
              ),
              SizedBox(height: 10),
              Expanded(child:
                SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(color: Colors.grey),
                    columnWidths: const {
                      0: FixedColumnWidth(35),
                      1: FlexColumnWidth(),
                      2: FixedColumnWidth(80),
                      3: FixedColumnWidth(60),
                      4: FixedColumnWidth(80),
                      5: FixedColumnWidth(75),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color.fromARGB(255, 0, 149, 255)),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text('No', style: TextStyle(color: Colors.white, fontSize: 12,fontFamily: "Poppins"), textAlign: TextAlign.center),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text('Barang', style: TextStyle(color: Colors.white, fontSize: 12,fontFamily: "Poppins"), textAlign: TextAlign.center),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text('Harga', style: TextStyle(color: Colors.white, fontSize: 12,fontFamily: "Poppins"), textAlign: TextAlign.center),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text('Min Grosir', style: TextStyle(color: Colors.white, fontSize: 12,fontFamily: "Poppins"), textAlign: TextAlign.center),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text('Harga Grosir', style: TextStyle(color: Colors.white, fontSize: 12,fontFamily: "Poppins"), textAlign: TextAlign.center),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child:Text('Stok', style: TextStyle(color: Colors.white, fontSize: 12,fontFamily: "Poppins"), textAlign: TextAlign.center)
                          ),
                        ],
                      ),
                      ...tempListDataMasterBarang.map((item){
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
                              child: Text(item['barang_master']['barang_nama'] , style: TextStyle(fontSize: 12,fontFamily: "Poppins"),)
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(formatRupiah(int.parse(item['barang_master']['barang_harga_jual'])) , style: TextStyle(fontSize: 12,fontFamily: "Poppins"),),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(item['barang_master']['barang_grosir_pembelian'] , style: TextStyle(fontSize: 12,fontFamily: "Poppins"),),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(formatRupiah(int.parse(item['barang_master']['barang_grosir_harga_jual'])) , style: TextStyle(fontSize: 12,fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.green), textAlign: TextAlign.right,),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(item['barang_stok'] , style: TextStyle(fontSize: 12,fontFamily: "Poppins"),),
                              ),
                            ),
                          ]
                        );
                      })
                    ],
                  ),
                ) 
              )
              // sisanya tabel kamu nanti
            ],
          ),
        ),
      )
    );
  }
}