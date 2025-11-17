import 'package:flutter/material.dart';
import 'package:kasir/services/api_service.dart';
import 'package:kasir/pages/home_page.dart';
import 'package:kasir/services/auth_service.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {

  final TextEditingController tokenValue = TextEditingController();
    
  @override
  Widget build(BuildContext context) {

    Future<void> handleLogin() async {
    if (tokenValue.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('token tidak boleh kosong!', style: TextStyle(fontFamily: "Poppins"),),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      try {
        final token = tokenValue.text;
        final response = await ApiService().postData('get-data-barang-by-token', {
          'token_value' : token,
        });
        // print(response);
        if (response["status"] == "success") {
          await AuthService.login();
          print("login ke home");
          // Navigator.pushReplacementNamed(context, '/home');
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Homepage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'], style: TextStyle(fontFamily: "Poppins"),),
              backgroundColor: Colors.red,
              duration: Duration(milliseconds: 4000),
            ),
          );
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 149, 255),
      body: Center(
        child: 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(50),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Selamat Datang", style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 20, 20, 20),
                      fontFamily: 'Poppins',
                      fontStyle: FontStyle.normal
                    ),
                  ),
                  SizedBox(height: 10),
                  Image.asset('assets/images/login-image.png', width: 100, height: 100),
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: TextField(
                      style: TextStyle(fontFamily: "Poppins"),
                      controller: tokenValue,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Kode token toko anda'
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 0, 149, 255),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: handleLogin,
                    child: const Text('Login', 
                      style: TextStyle(color: Color.fromARGB(255, 255, 255, 255),
                      fontFamily: 'Poppins',
                      )
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}