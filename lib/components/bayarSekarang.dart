import 'package:flutter/material.dart';
import 'package:kasir/components/dialogBayar.dart';
import 'package:kasir/provider/cart_provider.dart';
import 'package:provider/provider.dart';

class BayarSekarang extends StatefulWidget {
  const BayarSekarang({super.key});

  @override
  State<BayarSekarang> createState() => _BayarSekarangState();
}

class _BayarSekarangState extends State<BayarSekarang> {
  
  @override
  Widget build(BuildContext context) {
    int totalBelanja = context.watch<CartProvider>().totalBelanja;
    return Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Color.fromARGB(255, 255, 3, 3),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            textStyle: TextStyle(fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.w500)
          ),
          onPressed: () {
            if (totalBelanja > 0) {
              showGeneralDialog(
                context: context,
                barrierDismissible: false,
                barrierLabel: 'Tutup',
                transitionDuration: Duration(milliseconds: 500),
                pageBuilder: (context, animation, secondaryAnimation) {
                  return DialogBayar();
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
            } else {
              showDialog(context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    title: Text('Error', style: TextStyle( color: Colors.red, fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.bold),),
                    content: Text('Total belanja masih ${totalBelanja}', style: TextStyle(fontSize: 14, fontFamily: "Poppins"),),
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
          child: const Text("Bayar Sekarang", style: TextStyle(color: Colors.white),),
        ),
      );
  }
}