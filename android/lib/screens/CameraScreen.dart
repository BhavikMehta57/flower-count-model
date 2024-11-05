import 'dart:async';
import 'dart:ffi';
import 'package:android/components/AppColors.dart';
import 'package:android/components/AppWidget.dart';
import 'package:android/screens/MetaDataScreen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Timer _timer;
  int _interval = 1; // Default interval for capturing images.
  bool isLoadingCameras = true;
  bool _isCapturing = false;
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController.initialize();
    setState(() {
      isLoadingCameras = false;
    });
  }

  void _startCapturing() {
    setState(() {
      _isCapturing = true;
    });

    _timer = Timer.periodic(Duration(seconds: _interval), (timer) async {
      if (_isCapturing) {
        try {
          final image = await _cameraController.takePicture();
          final directory = await getApplicationDocumentsDirectory();
          final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
          final newImage = await File(image.path).copy(imagePath);
          setState(() {
            _images.add(newImage);
          });
        } catch (e) {
          print("Error capturing image: $e");
        }
      }
    });
  }

  void _stopCapturing() {
    _timer.cancel();
    setState(() {
      _isCapturing = false;
    });
    print(_images.length);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MetadataScreen(images: _images,)),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColorPrimary,
        title: text("Camera"),
      ),
      body: isLoadingCameras ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Expanded(
            child: _cameraController.value.isInitialized
                ? CameraPreview(_cameraController)
                : const Center(child: CircularProgressIndicator()),
          ),
          Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: shadowButton(_isCapturing ? "Stop Capturing" : "Start Capturing", () {_isCapturing ? _stopCapturing() : _startCapturing();})),
                  SizedBox(width: 20,),
                  Expanded(child: text("Count: ${_images.length}"))
                ],
              )
          ),
        ],
      ),
    );
  }
}
