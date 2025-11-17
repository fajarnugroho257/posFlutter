import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kasir/components/dialogNota.dart';
import 'package:kasir/components/postData.dart';
import 'package:kasir/components/sideBar.dart';
import 'package:kasir/provider/PrinterProvider.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';


class RiwayatTransaksi extends StatefulWidget {
  const RiwayatTransaksi({super.key});

  @override
  State<RiwayatTransaksi> createState() => _RiwayatTransaksiState();
}

class _RiwayatTransaksiState extends State<RiwayatTransaksi> {

  String formatRupiah(num number) {
    return 'Rp ${number.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  final box = Hive.box('dataBox');

  List dataTransaksi = [];
  String cabang_id = '';
  Map<dynamic, dynamic> dataKasir = {};

  Future<void> getDataTransaksi() async {
    var box = await Hive.openBox('transactions');
    List transaksiList = box.values.toList();
    setState(() {
      dataTransaksi = List.from(transaksiList.reversed);
    });
  }
  @override
  void initState() {
    super.initState();
    getDataTransaksi();
    get_nama_cabang();
  }

  void get_nama_cabang() {
    setState(() {
      cabang_id = box.get('cabang_id', defaultValue: "");
      dataKasir = box.get('dataKasir', defaultValue: "");
      // cabang_nama = box.get('cabang_nama', defaultValue: "");
    });
  }

  void handleSuccess() {
    getDataTransaksi();
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(15),
          child: OrientationBuilder(
            builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;
              return Column(
                children: [
                  Align(
                    alignment: AlignmentGeometry.centerRight,
                    child: PostData(postTransaksi: dataTransaksi, cabang_id: cabang_id, dataKasir: dataKasir, onSuccess: handleSuccess),
                  ),
                  SizedBox(height: 10,),
                  Expanded(
                    child: isLandscape
                    ?
                    SizedBox(
                      width: MediaQuery.widthOf(context),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            const Color.fromARGB(255, 0, 149, 255),
                          ),
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                          ),
                          dataTextStyle: const TextStyle(
                            fontSize: 12,
                            fontFamily: "Poppins",
                          ),
                          columns: const [
                            DataColumn(label: Text("No")),
                            DataColumn(label: Text("Tanggal")),
                            DataColumn(label: Text("Pelanggan")),
                            DataColumn(label: Text("Total")),
                            DataColumn(label: Text("Cash")),
                            DataColumn(label: Text("Kembali")),
                            DataColumn(label: Text("Nota")),
                          ],
                          rows: List<DataRow>.generate(
                            dataTransaksi.length,
                            (index) {
                              final item = dataTransaksi[index];
                              return DataRow(
                                cells: [
                                  DataCell(Text((index + 1).toString())),
                                  DataCell(
                                    Text("${item['tanggal']} Jam: ${item['jam']}"),
                                  ),
                                  DataCell(Text(item['pelanggan'].toString())),
                                  DataCell(
                                    Text(
                                      formatRupiah(item['totalBelanja']),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      formatRupiah(int.parse(item['bayar'])),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      formatRupiah(item['kembalian']),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  DataCell(
                                    GestureDetector(
                                      onTap: () {
                                        var detail = dataTransaksi.firstWhere(
                                          (val) => val['cartId'] == item['cartId'],
                                        );
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Dialog(
                                              insetPadding: const EdgeInsets.all(30),
                                              child: SizedBox.expand(
                                                child: DialogNota(cartDetail: detail),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: const Icon(Icons.receipt_long, size: 25),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    )
                   : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            const Color.fromARGB(255, 0, 149, 255),
                          ),
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                          ),
                          dataTextStyle: const TextStyle(
                            fontSize: 12,
                            fontFamily: "Poppins",
                          ),
                          columns: const [
                            DataColumn(label: Text("No")),
                            DataColumn(label: Text("Tanggal")),
                            DataColumn(label: Text("Pelanggan")),
                            DataColumn(label: Text("Total")),
                            DataColumn(label: Text("Cash")),
                            DataColumn(label: Text("Kembali")),
                            DataColumn(label: Text("Nota")),
                            DataColumn(label: Text("Upload")),
                          ],
                          rows: List<DataRow>.generate(
                            dataTransaksi.length,
                            (index) {
                              final item = dataTransaksi[index];
                              final stUpload = item['stUpload'] ? 'YES' : 'NO';
                              return DataRow(
                                cells: [
                                  DataCell(Text((index + 1).toString())),
                                  DataCell(
                                    Text("${DateFormat('dd-MM-yyyy').format(DateTime.parse(item['tanggal']))} Jam: ${item['jam']}"),
                                  ),
                                  DataCell(Text(item['pelanggan'].toString())),
                                  DataCell(
                                    Text(
                                      formatRupiah(item['totalBelanja']),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      formatRupiah(int.parse(item['bayar'])),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      formatRupiah(item['kembalian']),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  DataCell(
                                    GestureDetector(
                                      onTap: () async {
                                        var detail = await dataTransaksi.firstWhere(
                                          (val) => val['cartId'] == item['cartId'],
                                        );
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadiusGeometry.circular(10)
                                              ),
                                              insetPadding: const EdgeInsets.all(30),
                                              child: SizedBox.expand(
                                                child: DialogNota(cartDetail: detail),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: const Icon(Icons.receipt_long, size: 25),
                                    ),
                                  ),
                                  DataCell(
                                    Align(
                                      alignment: Alignment.center,
                                      child: item['stUpload'] ?
                                        Container(
                                          padding: EdgeInsets.all(2),
                                          color: Colors.green,
                                          child: Text(stUpload,
                                            style: TextStyle(color: Colors.white),
                                          )
                                        )
                                        : 
                                        Container(
                                          padding: EdgeInsets.all(2),
                                          color: Colors.red,
                                          child: Text(stUpload,
                                            style: TextStyle(color: Colors.white),
                                          )
                                        ),
                                    ),
                                    
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
          ),
        ),
      )
    );
  }
}