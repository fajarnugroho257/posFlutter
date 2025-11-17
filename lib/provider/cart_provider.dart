import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier  {
  List<Map<dynamic, dynamic>> cartItems = [];

  addToCart(Map<dynamic, dynamic> item) {
    item['controller'] = TextEditingController(text: item['qty'].toString());
    final index = cartItems.indexWhere((row) => row['id'] == item['id']);
    if (index == -1) {
      // Barang belum ada → tambahkan baru dengan qty = 1
      final newItem = {...item, 'qty': 1};
      newItem['stGrosir'] = 'no';
      cartItems.insert(0, newItem);
      notifyListeners();
      // print(cartItems);
      return {
        'status': true,
        'message' : 'Data berhasil dimasukkan kekeranjang'
      };
    } else {
      notifyListeners();
      return {
        'status': false,
        'message' : 'data sudah ada dikeranjang'
      };
      // Barang sudah ada → tambahkan qty lama
      // cartItems[index]['qty'] = (cartItems[index]['qty'] ?? 1) + 1;
    }
    // notifyListeners();
  }

  void updateQty(int id, int qty) {
    final index = cartItems.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      final harga = int.parse(cartItems[index]['barang_master']['barang_harga_jual']);
      final hargaGrosir = int.parse(cartItems[index]['barang_master']['barang_grosir_harga_jual']);
      final int grosirPembelian = int.parse(cartItems[index]['barang_master']['barang_grosir_pembelian']);
      cartItems[index]['qty'] = qty;
      // string
      if (qty >= grosirPembelian ) {
        cartItems[index]['subTotal'] = (hargaGrosir * qty).toString();
        cartItems[index]['stGrosir'] = "yes";
      } else {
        cartItems[index]['subTotal'] = (harga * qty).toString();
        cartItems[index]['stGrosir'] = "no";
      }
      // print(cartItems);
      notifyListeners(); // penting agar UI langsung rebuild
    }
  }

  void removeFromCart(Map<dynamic, dynamic> item) {
    cartItems.remove(item);
    notifyListeners();
  }

  int get totalBelanja {
    return cartItems.fold(0, (sum, item) => sum + (int.tryParse(item['subTotal']) ?? 0));
  }
  
  void clearCart() {
    cartItems.clear();
    notifyListeners();
  }
}