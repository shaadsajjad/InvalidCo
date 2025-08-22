import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Sample extends StatefulWidget {
  const Sample({super.key});

  @override
  State<Sample> createState() => _SampleState();
}

class _SampleState extends State<Sample> {
  List<String> images = [];
  List<bool> selectedImages = [];

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
    _getImages();
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
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Grid of images
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
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

          // Floating download button
          if (anySelected)
            Positioned(
              bottom: 20, // adjust vertical position
              left: (MediaQuery.of(context).size.width -310) /2,// center
              child: Material(
                elevation: 8, // gives 3D shadow
                borderRadius: BorderRadius.circular(44),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF66FFB6),
                    minimumSize: Size(310, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {},
                  child:  Text("Download",style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Colors.black
                    
                  ),),
                  
                ),
              ),
            ),
        ],
      ),
    );
  }
}
