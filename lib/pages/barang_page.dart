import 'package:flutter/material.dart';
import 'package:kasir/components/sideBar.dart';
import 'package:hive/hive.dart';
import 'package:kasir/services/api_service.dart';
import 'package:intl/intl.dart';


class BarangPage extends StatefulWidget {
  const BarangPage({super.key});

  @override
  State<BarangPage> createState() => _BarangPageState();
}

class _BarangPageState extends State<BarangPage> {
  bool isLoading = false;
  List listDataMasterBarang = [];
  List tempListDataMasterBarang = [];
  String updateAt = '';

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
    final resUpdateAt = box.get('updateAt');
    setState(() {
      updateAt = resUpdateAt;
      listDataMasterBarang = dataBarang;
      tempListDataMasterBarang = dataBarang;
    });
  }

  String formatRupiah(num number) {
    return 'Rp ${number.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String formatTanggal(String tanggal) {
    tanggal = tanggal.trim();
    DateTime dt = DateFormat("yyyy-MM-dd HH:mm:ss").parse(tanggal);
    return DateFormat('d MMMM yyyy HH:mm', 'id_ID').format(dt);
  }

  void handleSyncBarang () async {
    final box = Hive.box('dataBox');
    try {
      setState(() => isLoading = true);
      var loginToken = box.get('loginToken', defaultValue: "");
      print(loginToken);
      final response = await ApiService().syncBarang('get-data-barang-by-token', {
        'token_value' : loginToken,
      });
      loadBarang();
    } catch (e) {
      print(e);
    } finally {
      setState(() => isLoading = false);
    }
  }

  final TextEditingController inputController = TextEditingController();
  @override
  void dispose() {
    focusNode.dispose();
    inputController.dispose();
    super.dispose();
  }

  // handle input search
  FocusNode focusNode = FocusNode();
  void handleClearFilter() async {
    await loadBarang();
    inputController.clear();
    FocusScope.of(context).requestFocus(focusNode);
  }



  @override
  Widget build(BuildContext context) {
    var no = 1;
    return Stack(
      children: [
        Scaffold(
          drawer: SideBar(),
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 0, 149, 255),
            title: Center(
              child: Text('Data Barang', 
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
                  Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Text('Last Update : ${formatTanggal(updateAt)}' , style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))
                  ),
                  SizedBox(height: 3,),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: focusNode,
                          controller: inputController,
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
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.all(4)
                          ),
                          onPressed: () => {
                            handleClearFilter()
                          },
                          child: Icon(Icons.close, color: Colors.white,)
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
                ],
              ),
            ),
          )
        ),
        if (isLoading)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ]
    );
  }
}