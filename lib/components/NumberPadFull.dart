import 'package:flutter/material.dart';

class NumberPadFull extends StatelessWidget {
  final Function(String) onPressed;
  final Function() onClear;
  final Function() onConfirm;
  

  const NumberPadFull({
    super.key,
    required this.onPressed,
    required this.onClear,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    // Daftar tombol angka 1–9
    final List<String> numbers = List.generate(9, (index) => '${index + 1}');

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3, // 3 kolom
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: orientation == Orientation.portrait ? 3.2 : 5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Tombol 1–9
        ...numbers.map((num) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(8),
            ),
            onPressed: () => onPressed(num),
            child: Text(num, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          );
        }),

        // Tombol C (Clear)
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(16),
          ),
          onPressed: onClear,
          child: const Text('C', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),

        // Tombol 0
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(16),
          ),
          onPressed: () => onPressed('0'),
          child: const Text('0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),

        // Tombol 000
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(16),
          ),
          onPressed: () => onPressed('000'),
          child: const Text('000', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
