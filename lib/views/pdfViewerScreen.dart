import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inspect/checklist.dart';
import 'package:inspect/views/historial.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final File pdfFile;


  const PdfViewerScreen({
    super.key,
    required this.pdfFile,

  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista previa del PDF'),
      ),
      body: Column(
        children: [
          Expanded(child: SfPdfViewer.file(widget.pdfFile)),
          
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const Checklist()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Nueva inspección'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistorialInspeccionesScreen()),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Ver historial'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
