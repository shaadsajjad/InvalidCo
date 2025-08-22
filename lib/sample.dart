import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class Sample extends StatefulWidget {
  const Sample({super.key});

  @override
  State<Sample> createState() => _SampleState();
}

class _SampleState extends State<Sample> {
  List<String> images = [];
  List<bool> selectedImages = [];

  Future<void> _requestPermission() async {
    if (await Permission.photos.request().isGranted ||
        await Permission.storage.request().isGranted) {
      _getImages();
    } else {
      debugPrint("Permission denied");
    }
  }

  Future<void> _getImages() async {
    const channel = MethodChannel('flutter_channel');
    try {
      final result = await channel.invokeMethod<List<dynamic>>('getImages');
      setState(() {
        images = result?.cast<String>() ?? [];
        selectedImages = List<bool>.filled(images.length, false);
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to get images: ${e.message}");
    }
  }

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    bool anySelected = selectedImages.contains(true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Photos"),
        centerTitle: true,
      ),
      body: images.isEmpty
          ? const Center(child: Text("No images found"))
          : Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: GridView.builder(
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedImages[index] = !selectedImages[index];
                    });
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(images[index]),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                        ),
                      ),
                      if (selectedImages[index])
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter:
                            ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              color: Colors.black.withOpacity(0.2),
                            ),
                          ),
                        ),
                      if (selectedImages[index])
                        const Center(
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.greenAccent,
                            size: 40,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (anySelected)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66FFB6),
                    minimumSize: const Size(310, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    const channel = MethodChannel('flutter_channel');
                    List<String> selectedPaths = [];

                    for (int i = 0; i < images.length; i++) {
                      if (selectedImages[i]) {
                        selectedPaths.add(images[i]);
                      }
                    }

                    try {
                      for (String path in selectedPaths) {
                        await channel
                            .invokeMethod('saveImage', {"path": path});
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                            Text("Images downloaded successfully!")),
                      );
                      setState(() {
                        selectedImages =
                        List<bool>.filled(images.length, false);
                        _getImages();
                      });
                    } on PlatformException catch (e) {
                      debugPrint("Failed to download: ${e.message}");
                    }
                  },
                  child: const Text(
                    "Download",
                    style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
