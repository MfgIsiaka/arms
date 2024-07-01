import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

class PanoramaViewInit extends StatelessWidget {
  Map<String, dynamic> data;
  PanoramaViewInit(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data['controller']),
      ),
      body: PanoramaViewer(
        child: Image.file(data['image']),
      ),
    );
  }
}
