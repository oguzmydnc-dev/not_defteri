import 'package:flutter/material.dart';
import '../models/not_model.dart';

class NotDialog extends StatefulWidget {
  final Not? not;

  const NotDialog({super.key, this.not});

  @override
  State<NotDialog> createState() => _NotDialogState();
}

class _NotDialogState extends State<NotDialog> {
  late TextEditingController baslikCtrl;
  late TextEditingController icerikCtrl;
  late bool sabit;
  late Color renk;

  final renkler = [
    Colors.yellow,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    baslikCtrl = TextEditingController(text: widget.not?.baslik ?? '');
    icerikCtrl = TextEditingController(text: widget.not?.icerik ?? '');
    sabit = widget.not?.sabit ?? false;
    renk = widget.not?.renk ?? Colors.yellow;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.not == null ? 'Yeni Not' : 'Notu Düzenle'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: baslikCtrl,
              decoration: const InputDecoration(hintText: 'Başlık'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: icerikCtrl,
              decoration: const InputDecoration(hintText: 'İçerik'),
              maxLines: null,
            ),
            Row(
              children: [
                const Icon(Icons.push_pin),
                Checkbox(
                  value: sabit,
                  onChanged: (v) => setState(() => sabit = v!),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: renkler.map((r) {
                return GestureDetector(
                  onTap: () => setState(() => renk = r),
                  child: CircleAvatar(
                    backgroundColor: r,
                    child: renk == r
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.not != null)
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text(
              "Sil",
              style: TextStyle(color: Colors.red),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              Not(
                baslik: baslikCtrl.text.trim(),
                icerik: icerikCtrl.text.trim(),
                renk: renk,
                sabit: sabit,
              ),
            );
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
