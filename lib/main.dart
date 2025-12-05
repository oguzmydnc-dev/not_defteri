import 'package:flutter/material.dart';

void main() {
  runApp(const NotDefteriApp());
}

class NotDefteriApp extends StatelessWidget {
  const NotDefteriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Not Defteri',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const NotListesiSayfasi(),
    );
  }
}

class NotListesiSayfasi extends StatefulWidget {
  const NotListesiSayfasi({super.key});

  @override
  State<NotListesiSayfasi> createState() => _NotListesiSayfasiState();
}

class _NotListesiSayfasiState extends State<NotListesiSayfasi> {
  List<String> notlar = []; // Basit bir not listesi

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Not Defteri"),
      ),
      body: ListView.builder(
        itemCount: notlar.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(notlar[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _yeniNotEkle,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _yeniNotEkle() {
    setState(() {
      notlar.add("Yeni Not ${notlar.length + 1}");
    });
  }
}
