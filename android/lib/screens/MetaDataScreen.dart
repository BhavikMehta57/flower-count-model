import 'package:android/main.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MetadataScreen extends StatefulWidget {
  final List<File> images;
  const MetadataScreen({required this.images, super.key});

  @override
  State<MetadataScreen> createState() => _MetadataScreenState();
}

class _MetadataScreenState extends State<MetadataScreen> {

  List<File> images = [];
  List<String> metadata = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      images = widget.images;
      metadata = List.filled(widget.images.length, '', growable: true);
    });
  }

  Future<void> saveImagesWithMetadata(List<File> images, List<String> metadataList, String folderName) async {
    print("${images.length} ${metadataList.length}");
    final directory = await getApplicationDocumentsDirectory();
    final batchDirectory = Directory('${directory.path}/$folderName');
    if (!(await batchDirectory.exists())) {
      await batchDirectory.create();
    }
    final filePath = '${directory.path}/$folderName/image_metadata.json';
    final List<Map<String, String>> imageMetadataList = [];

    for (int i = 0; i < images.length; i++) {
      imageMetadataList.add({
        'path': images[i].path,
        'metadata': metadataList[i], // Assuming metadataList contains metadata for each image
      });
    }

    final file = File(filePath);
    await file.writeAsString(jsonEncode(imageMetadataList));
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(),
        ),
            (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Metadata")),
      body: ListView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.file(images[index], width: 50, height: 50),
            title: TextField(
              decoration: const InputDecoration(
                labelText: "Enter Metadata",
              ),
              onChanged: (value) {
                // Save metadata to be associated with the image.
                setState(() {
                  metadata[index] = value;
                });
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Remove image if not wanted.
                setState(() {
                  images.removeAt(index);
                  metadata.removeAt(index);
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Save all images with metadata.
          await saveImagesWithMetadata(images, metadata, DateTime.now().millisecondsSinceEpoch.toString());
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
