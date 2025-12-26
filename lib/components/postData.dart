import 'package:flutter/material.dart';
import 'package:kasir/services/api_service.dart';
import 'package:hive/hive.dart';


class PostData extends StatelessWidget {
  PostData({super.key, required this.postTransaksi, required this.cabang_id, required this.dataKasir, required this.onSuccess, required this.statusLoading});
  final List postTransaksi;
  final String cabang_id;
  final Map<dynamic, dynamic> dataKasir;
  final Function() onSuccess;
  final Function(bool status) statusLoading;

  final box = Hive.box('dataBox');

  Future<Map<String, dynamic>> handlePostData (context) async {
    var box = await Hive.openBox('transactions');
    List transaksiList = box.values.toList();
    // data non upload
    List<Map<dynamic, dynamic>> datasUploadFalse = [];
    for(var datas in postTransaksi){
      if (datas['stUpload'] == false) {
        datasUploadFalse.add(datas);
      }
    }
    if (datasUploadFalse.isEmpty) {
      return {
        'status' : false,
        'message' : 'Semua data sudah dipost ke server.',
      };
    }
    // print(datasUploadFalse);
    try {
      await statusLoading(true);
      final response = await ApiService().postTransaksi('post-data-transaksi', {
        'cabang_id' : cabang_id,
        'postTransaksi' : datasUploadFalse,
        'user_id': dataKasir['user_id']
      });
      if(response['success'] == true){
        // print(response);
        final resPostTransaksi = response['postTransaksi'];
        for (var item in resPostTransaksi){
          final index = transaksiList.indexWhere((data) => data['cartId'] == item['cartId']);
          // 
          if (index != -1) {
            final key = box.keyAt(index); // ambil key Hive berdasarkan index
            final data = box.get(key);
            // update field
            data['stUpload'] = true;
            // simpan balik ke Hive
            await box.put(key, data);
            // perbaharui state
          }
        }
        // jalankan state di home
        await onSuccess();
        await statusLoading(false);
        // 
        return {
          'status' : true,
          'message' : 'Berhasil diupload sebanyak ${resPostTransaksi.length} Data',
        };
      } else {
        return {
          'status' : false,
          'message' : 'Gagal diupload keserver',
        };
      }
    } catch (e) {
      return {
          'status' : false,
          'message' : e.toString(),
        };
    }   
  }  

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: 'Tutup',
          transitionDuration: Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) {
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Kirim Data penjualan ke database', style: TextStyle(fontFamily: "Poppins"),),
                              // Text('Jumlah data ${postTransaksi.length}', style: TextStyle(fontFamily: "Poppins"),),
                              // Text('Post data hanya tersedia 1 kali tiap hari / 1 token 1 Post data', style: TextStyle(fontFamily: "Poppins"),),
                              SizedBox(height: 10,),
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
                                      final status = await handlePostData(context);
                                      if (status['status']) {
                                        Navigator.of(context, rootNavigator: true).pop();
                                        // show dialog
                                        showDialog(context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              title: Text('Sukses', style: TextStyle(fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.green),),
                                              content: Text(status['message'], style: TextStyle(fontSize: 14, fontFamily: "Poppins"),),
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
                                        Navigator.of(context, rootNavigator: true).pop();
                                        showDialog(context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              title: Text('Error', style: TextStyle(fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.red),),
                                              content: Text(status['message'], style: TextStyle(fontSize: 14, fontFamily: "Poppins"),),
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
                                    },
                                    child: Text("Upload", style: TextStyle(color: Colors.white),),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    )
                  )
            );
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            // animasi slide dari atas
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, -1), // dari atas ke bawah
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        backgroundColor: Colors.red,

      ),
      child: SizedBox(
        width: 65,
        child: Row(
          children: [
            Icon(Icons.upload, color: Colors.white),
            Text('Upload', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white),)
          ],
        ),
      )
    );
  }
}