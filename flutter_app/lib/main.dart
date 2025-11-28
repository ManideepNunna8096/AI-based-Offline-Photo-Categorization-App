import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(PhotoCategorizerApp());

class PhotoCategorizerApp extends StatefulWidget {
  @override
  _PhotoCategorizerAppState createState() => _PhotoCategorizerAppState();
}

class _PhotoCategorizerAppState extends State<PhotoCategorizerApp> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _images;
  String _result = '';
  String _serverIP = '';
  bool _isConnected = false;
  bool _isUploading = false;

  final List<Map<String, dynamic>> _categorizedResults = [];

  // ===== PERMISSIONS (Step 2) =====
  Future<void> _askPermission() async {
    // Android 11+ “All files access”
    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }

    // Classic storage & gallery access (covers older versions + Photos)
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    if (await Permission.photos.isDenied) {
      await Permission.photos.request();
    }

    // If permanently denied, open settings
    if (await Permission.manageExternalStorage.isPermanentlyDenied ||
        await Permission.storage.isPermanentlyDenied ||
        await Permission.photos.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  // ===== Connect to Flask manually =====
  Future<void> _connectToServer() async {
    if (_serverIP.isEmpty) {
      setState(() => _result = "Enter your Flask server IP address first.");
      return;
    }

    try {
      final response = await http
          .get(Uri.parse('http://$_serverIP:5000/ping'))
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        setState(() {
          _isConnected = true;
          _result = "✅ Connected to Flask server!";
        });
      } else {
        setState(() => _result = "❌ Flask not responding (HTTP ${response.statusCode}).");
      }
    } catch (_) {
      setState(() => _result = "❌ Could not reach Flask server.");
    }
  }

  // ===== Pick & Upload Multiple Images =====
  Future<void> _pickAndUploadImages() async {
    await _askPermission();

    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles == null || pickedFiles.isEmpty) return;

    setState(() {
      _images = pickedFiles;
      _result = "Uploading ${pickedFiles.length} images...";
      _isUploading = true;
      _categorizedResults.clear();
    });

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://$_serverIP:5000/upload_multiple'),
    );

    for (final img in pickedFiles) {
      request.files.add(
        await http.MultipartFile.fromPath('files', img.path, filename: basename(img.path)),
      );
    }

    try {
      final streamed = await request.send();
      if (streamed.statusCode == 200) {
        final respData = await http.Response.fromStream(streamed);
        final List<dynamic> jsonResponse = jsonDecode(respData.body);

        for (int i = 0; i < jsonResponse.length; i++) {
          final item = jsonResponse[i] as Map<String, dynamic>;
          final category = (item['scene'] as String?)?.trim().isNotEmpty == true
              ? item['scene'] as String
              : "Uncategorized";

          await _saveToPhoneFolder(pickedFiles[i], category);

          _categorizedResults.add({
            'path': pickedFiles[i].path,
            'category': category,
          });
        }

        setState(() {
          _isUploading = false;
          _result = "✅ Images successfully categorized and saved!";
        });
      } else {
        setState(() {
          _isUploading = false;
          _result = "❌ Server error: ${streamed.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _result = "❌ Upload failed: $e";
      });
    }
  }

  // ===== Save categorized images to public Pictures/PhotoCategorizer =====
  Future<void> _saveToPhoneFolder(XFile img, String category) async {
    // Public Pictures target
    final outDir = Directory('/storage/emulated/0/Pictures/PhotoCategorizer/$category');

    if (!await outDir.exists()) {
      await outDir.create(recursive: true);
    }

    final destPath = '${outDir.path}/${basename(img.path)}';
    try {
      await File(img.path).copy(destPath);
      // (Optional) you can add a toast/snackbar here
      // to show destPath to the user
      debugPrint("✅ Saved ${img.name} to $destPath");
    } on FileSystemException catch (e) {
      // Give a clear message if permission still blocked
      throw Exception(
          "PathAccessException: Cannot copy file to '$destPath' (reason: ${e.osError}). "
              "Please allow 'All files access' for this app in Settings.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.purple.shade50,
        appBar: AppBar(
          title: const Text("Offline Photo Categorizer"),
          backgroundColor: Colors.deepPurple,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() {
                _categorizedResults.clear();
                _images = null;
                _result = '';
                _isConnected = false;
              }),
              tooltip: 'Reset',
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  onChanged: (val) => _serverIP = val.trim(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter server IP (e.g. 10.50.24.70)',
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _connectToServer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Connect"),
                ),
                const SizedBox(height: 20),

                if (_isUploading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  const Text("Processing images...", style: TextStyle(fontSize: 14)),
                ],

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _isConnected && !_isUploading ? _pickAndUploadImages : null,
                  icon: const Icon(Icons.image),
                  label: const Text("Select Multiple Images"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  _result,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 20),

                if (_categorizedResults.isNotEmpty)
                  Column(
                    children: _categorizedResults.map((item) {
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                File(item['path'] as String),
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "📸 Category: ${item['category']}",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}






