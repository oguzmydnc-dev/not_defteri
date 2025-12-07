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
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
      ),
      themeMode: ThemeMode.system, // sistem temasıyla eşleşir
      home: const NotListesiSayfasi(),
    );
  }
}

// Not sınıfı
class Not {
  String baslik;
  String icerik;
  Color renk;
  bool sabit;

  Not({
    required this.baslik,
    required this.icerik,
    this.renk = Colors.yellow,
    this.sabit = false,
  });
}

// Grid arka plan widget'ı
class GridBackground extends StatelessWidget {
  final Widget child;
  final double gridSize;

  const GridBackground({required this.child, this.gridSize = 50, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(gridSize: gridSize),
      child: child,
    );
  }
}

class _GridPainter extends CustomPainter {
  final double gridSize;

  _GridPainter({required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(55, 158, 158, 158)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NotListesiSayfasi extends StatefulWidget {
  const NotListesiSayfasi({super.key});

  @override
  State<NotListesiSayfasi> createState() => _NotListesiSayfasiState();
}

class _NotListesiSayfasiState extends State<NotListesiSayfasi> {
  List<Not> notlar = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Not Defteri"),
      ),
      body: GridBackground(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: notlar.length,
            itemBuilder: (context, index) {
              final not = notlar[index];
              return Card(
                color: not.renk,
                elevation: not.sabit ? 8 : 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  onLongPress: () {
                    _notAyarlariniAc(index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          not.baslik,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          not.icerik,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _yeniNotEkle,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _yeniNotEkle() {
    final baslikCtrl = TextEditingController();
    final icerikCtrl = TextEditingController();
    Color secilenRenk = Colors.yellow;

    final renkler = [
      Colors.yellow,
      const Color.fromARGB(255, 163, 23, 13),
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.grey,
      Colors.black12,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Yeni Not'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: baslikCtrl,
                      decoration: const InputDecoration(hintText: 'Başlık'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: icerikCtrl,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(hintText: 'İçerik...'),
                    ),
                    const SizedBox(height: 15),
                    const Text("Renk Seç",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      children: renkler.map((r) {
                        return GestureDetector(
                          onTap: () {
                            setStateDialog(() => secilenRenk = r);
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: r,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: secilenRenk == r
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('İptal')),
                TextButton(
                  onPressed: () {
                    final baslik = baslikCtrl.text.trim();
                    final icerik = icerikCtrl.text.trim();
                    if (baslik.isNotEmpty || icerik.isNotEmpty) {
                      setState(() {
                        notlar.add(
                            Not(baslik: baslik, icerik: icerik, renk: secilenRenk));
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _notDuzenle(int index) {
    final not = notlar[index];
    final baslikCtrl = TextEditingController(text: not.baslik);
    final icerikCtrl = TextEditingController(text: not.icerik);
    Color secilenRenk = not.renk;

    final renkler = [
      Colors.yellow,
      const Color.fromARGB(255, 163, 23, 13),
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.grey,
      Colors.black12,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Notu Düzenle'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: baslikCtrl,
                      decoration: const InputDecoration(hintText: 'Başlık'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: icerikCtrl,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(hintText: 'İçerik...'),
                    ),
                    const SizedBox(height: 15),
                    const Text("Renk Seç",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: renkler.map((r) {
                        return GestureDetector(
                          onTap: () {
                            setStateDialog(() => secilenRenk = r);
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: r,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: secilenRenk == r
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('İptal')),
                TextButton(
                  onPressed: () {
                    setState(() {
                      not.baslik = baslikCtrl.text.trim();
                      not.icerik = icerikCtrl.text.trim();
                      not.renk = secilenRenk;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _notAyarlariniAc(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Not Ayarları'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  notlar.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('Sil'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _notDuzenle(index);
              },
              child: const Text('Düzenle'),
            ),
          ],
        );
      },
    );
  }
}
