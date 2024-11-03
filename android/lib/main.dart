import 'dart:convert';
import 'dart:io';

import 'package:android/screens/CameraScreen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Assignment App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future<List<String>> loadBatchNames() async {
    final directory = await getApplicationDocumentsDirectory();
    final batchDirectories = directory.listSync().whereType<Directory>();
    return batchDirectories.map((dir) => dir.path.split('/').last).toList();
  }

  Future<Map<String, List<Map<String, String>>>> loadAllBatchMetadata() async {
    List<String> batchNames = await loadBatchNames();
    Map<String, List<Map<String, String>>> allBatchesMetadata = {};

    for (final batch in batchNames) {
      List<Map<String, String>> metadata = await loadBatchImageMetadata(batch);
      if(metadata.isNotEmpty) {
        allBatchesMetadata[batch] = metadata;
      } // Store metadata by batch name
    }

    return allBatchesMetadata;
  }

  Future<List<Map<String, String>>> loadBatchImageMetadata(String batchName) async {
    final directory = await getApplicationDocumentsDirectory();
    final batchDirectory = Directory('${directory.path}/$batchName');
    final metadataFile = File('${batchDirectory.path}/image_metadata.json');

    if (await metadataFile.exists()) {
      String content = await metadataFile.readAsString();
      final List<dynamic> rawList = jsonDecode(content);
      return rawList.map((item) => Map<String, String>.from(item)).toList();
    } else {
      return [];
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera Assignment App"),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
                );
              },
              child: const Text("Start Camera"),
            ),
            Expanded(
              child: FutureBuilder<Map<String, List<Map<String, String>>>>(
                future: loadAllBatchMetadata(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No batches available'));
                  } else {
                    final allBatchesMetadata = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        children: allBatchesMetadata.entries.map((entry) {
                          final batchName = entry.key;
                          final imageMetadataList = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    batchName,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                GridView.builder(
                                  shrinkWrap: true, // Important to prevent unbounded height
                                  physics: const NeverScrollableScrollPhysics(), // Disable scrolling for inner grid
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                  ),
                                  itemCount: imageMetadataList.length,
                                  itemBuilder: (context, index) {
                                    final imageData = imageMetadataList[index];
                                    return GridTile(
                                      child: Image.file(
                                        File(imageData['path']!), // Use the correct path
                                        fit: BoxFit.cover,
                                      ),
                                      footer: GridTileBar(
                                        backgroundColor: Colors.black54,
                                        title: Text(imageData['metadata']!), // Adjust metadata field name accordingly
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
