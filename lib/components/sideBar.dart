import 'package:flutter/material.dart';
import 'package:kasir/services/auth_service.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 50,
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(child: Text("Menu Utama", style: TextStyle(fontFamily: "Poppins", fontSize: 15, fontWeight: FontWeight.bold),)),
            ),
          ),
          // Menu List
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Kasir'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Riwayat Transaksi'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/riwayat');
            },
          ),
          ListTile(
            leading: Icon(Icons.dataset),
            title: Text('Data Barang'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/data-barang');
            },
          ),
          ListTile(
            leading: Icon(Icons.print),
            title: Text('Printer'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/printer');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Keluar'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    title: Text('Keluar..!', style: TextStyle(color: Colors.red, fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.bold),),
                    content: Text('Apakah anda yakin akan keluar', style: TextStyle(fontSize: 14, fontFamily: "Poppins"),),
                    actions: [
                      TextButton(
                        onPressed: () async  {
                          // Navigator.pop(context);
                          await AuthService.logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text('OK', style: TextStyle(fontFamily: "Poppins"),),
                      ),
                    ],
                  );
                },
              );
              // Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}