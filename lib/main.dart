import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MaterialApp(home: BarcodeFolderRenamer()));
}

class BarcodeFolderRenamer extends StatefulWidget {
  const BarcodeFolderRenamer({super.key});

  @override
  State<BarcodeFolderRenamer> createState() => _BarcodeFolderRenamerState();
}

class _BarcodeFolderRenamerState extends State<BarcodeFolderRenamer> {
  String barcodeResult = '';
  String folderPath = '';
  String status = '';

  Future<void> scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        barcodeResult = result.rawContent;
      });

      if (barcodeResult.isNotEmpty) {
        await renameFolder(barcodeResult);
      }
    } catch (e) {
      setState(() {
        status = 'Erro ao escanear: \$e';
      });
    }
  }

  Future<void> renameFolder(String data) async {
    try {
      List<String> info = data.split(';');
      if (info.length < 4) {
        setState(() {
          status = 'Formato de código inválido';
        });
        return;
      }

      String newName = '\${info[0].replaceAll(' ', '')}_\${info[1]}_\${info[2]}_\${info[3]}';

      final dir = await getExternalStorageDirectory();
      if (dir == null) return;

      final oldFolder = Directory(p.join(dir.path, 'PastaProduto'));
      final newFolder = Directory(p.join(dir.path, newName));

      if (await oldFolder.exists()) {
        await oldFolder.rename(newFolder.path);
        setState(() {
          folderPath = newFolder.path;
          status = 'Pasta renomeada com sucesso!';
        });
      } else {
        setState(() {
          status = 'Pasta original não encontrada';
        });
      }
    } catch (e) {
      setState(() {
        status = 'Erro ao renomear: \$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Renomear Pasta via Código')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: scanBarcode,
              child: const Text('Escanear Código de Barras'),
            ),
            const SizedBox(height: 20),
            Text('Resultado: \$barcodeResult'),
            const SizedBox(height: 10),
            Text('Status: \$status'),
            const SizedBox(height: 10),
            Text('Nova pasta: \$folderPath'),
          ],
        ),
      ),
    );
  }
}
