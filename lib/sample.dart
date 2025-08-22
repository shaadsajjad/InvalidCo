import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
class Sample extends StatefulWidget {
  const Sample({super.key});

  @override
  State<Sample> createState() => _SampleState();
}

class _SampleState extends State<Sample> {
  List<String> images = [];

  Future<void> _getImages() async {
    const channel = MethodChannel('flutter_channel');
    try {
      final result = await channel.invokeMethod<List<dynamic>>('getImages');
      setState(() {
        images = result?.cast<String>() ?? [];
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to get images: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Photos"),
      centerTitle: true,),
      body: Column(
        children: [
          if (images.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(images[index]),
                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image);
                        },
                      ),
                    );
                  },
                ),
              )

            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _getImages,
              child: const Text("Load Images"),
            ),
          ),
        ],
      ),
    );
  }
}
