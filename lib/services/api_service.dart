import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ApiService{
  // final String baseUrl = "http://127.0.0.1:8000/api";
  // String baseUrl = "http://192.168.1.7:8000/api";
  final String baseUrl = "https://sameeramart.com/app-pos/api";
  
  Future<List<dynamic>> getData(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200){
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat data');
    }
  }

  Future<Map<String, dynamic>> postData(String endpoint, Map<String, dynamic> body) async {
    // print(baseUrl);
    try {
      final box = Hive.box('dataBox');
      // print(body['token_value']);
      // print(baseUrl);
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
            'Content-Type': 'application/json',
          },
        body: jsonEncode(body),
      );
      // print(response.body);
      if (response.statusCode == 200){
        var responBody = jsonDecode(response.body);
        var dataBarang = responBody['data']['data_barang'];
        var dataKasir = responBody['data']['kasir_data'];
        final now = DateTime.now();
        final tanggal = DateFormat('yyyy-MM-dd H:m:s').format(now);
        // 
        await box.put('loginToken', body['token_value']);
        await box.put('dataBarang', dataBarang);
        await box.put('cabang_nama', responBody['data']['cabang_nama']);
        await box.put('token_date', responBody['data']['token_date']);
        await box.put('cabang_id', responBody['data']['cabang_id'].toString());
        await box.put('dataKasir', dataKasir);
        await box.put('updateAt', tanggal);
        print('Data berhasil disimpan ke Hive!');

        return jsonDecode(response.body);
      } else {
        // throw Exception('Gagal memuat data');
        const data = {
          "status" : false,
          "message" : "Token tidak ditemukan",
        };
        return data;
      }
    } catch (e) {
      var data = {
        "status" : false,
        // "message" : "Terjadi kesalahan..!",
        "message" : e.toString(),
        
      };
      return data;
    }    
  }

  Future<Map<String, dynamic>> syncBarang(String endpoint, Map<String, dynamic> body) async {
    // print(baseUrl);
    try {
      final box = Hive.box('dataBox');
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
            'Content-Type': 'application/json',
          },
        body: jsonEncode(body),
      );
      // print(response.body);
      if (response.statusCode == 200){
        var responBody = jsonDecode(response.body);
        var dataBarang = responBody['data']['data_barang'];
        final now = DateTime.now();
        final tanggal = DateFormat('yyyy-MM-dd H:m:s').format(now);
        // 
        await box.put('loginToken', body['token_value']);
        await box.delete('dataBarang');
        await box.put('updateAt', tanggal);
        // insert lagi
        await box.put('dataBarang', dataBarang);
        print('Data stok barang berhasil diupdate');

        return jsonDecode(response.body);
      } else {
        // throw Exception('Gagal memuat data');
        const data = {
          "status" : false,
          "message" : "Token tidak ditemukan",
        };
        return data;
      }
    } catch (e) {
      var data = {
        "status" : false,
        // "message" : "Terjadi kesalahan..!",
        "message" : e.toString(),
        
      };
      return data;
    }    
  }

  Future<Map<String, dynamic>> postTransaksi(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      // Debug log
      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Pastikan selalu return Map
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        // kalau server kirim error (422, 500, dsb)
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
        } catch (_) {}
        
        // fallback jika body bukan JSON valid
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Terjadi kesalahan: $e",
      };
    }
  }


}