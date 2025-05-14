import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadCenterScreen extends StatefulWidget {
  const DownloadCenterScreen({super.key});

  @override
  State<DownloadCenterScreen> createState() => _DownloadCenterScreenState();
}

class _DownloadCenterScreenState extends State<DownloadCenterScreen> {
  int selectedCategory = 0; // 0 for Datasheets, 1 for User Manuals
  int selectedBrand = 0; // Index for selected brand

   List<Map<String, String>> brands = [];

  final List<String> documentCategories = [
    "Product Datasheets",
    "Product User Manuals"
  ];

  List<DocumentSnapshot> documents = [];
  bool isLoading=true;
  @override
  void initState() {
    super.initState();
    getBrandsData();
  }
  getBrandsData()  async {
    brands=await getBrands();
    fetchDocuments();
    setState(() {

    });

  }
  Future<List<Map<String, String>>> getBrands() async {
    List<Map<String, String>> brands = [];

    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('brands').orderBy('timestamp',descending: false).get();

      for (var doc in querySnapshot.docs) {
        brands.add({
          'id': doc.id, // Document ID
          'name': doc['name'] ?? '', // Assuming 'name' field exists
          'imageUrl': doc['imageUrl'] ?? '', // Assuming 'logo' field exists
        });
      }

      print("Brands: $brands"); // Debugging
      return brands;
    } catch (e) {
      print("Error fetching brands: $e");
      return [];
    }
  }

  Future<void> fetchDocuments() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('downloads').orderBy('watt', descending: true)
        .where("brand", isEqualTo: brands[selectedBrand]["name"])
        .where("category", isEqualTo: documentCategories[selectedCategory])
        .get();

    setState(() {
      isLoading=false;
      documents = snapshot.docs;
    });
  }

  Future<void> _viewOrDownloadFile(String url, String fileName, BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Loading...", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        },
      );

      // Get temporary directory to store the file for viewing
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = "${tempDir.path}/$fileName";
      File tempFile = File(tempPath);
      
      // Check if file already exists in temp directory
      bool fileExists = await tempFile.exists();
      
      if (!fileExists) {
        // Download the file
        await Dio().download(url, tempPath);
      }
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Open the file
      final result = await OpenFile.open(tempPath);
      if (result.type != ResultType.done) {
        // If opening fails, show error
        _showSnackBar(context, "Could not open file: ${result.message}");
      }
    } catch (e) {
      // Close loading dialog if open
      Navigator.pop(context);
      _showSnackBar(context, "Error opening file: ${e.toString()}");
      print("Error viewing file: $e");
    }
  }

  Future<void> downloadFile(String url, String fileName, BuildContext context) async {
    if (Platform.isAndroid) {
      await _androidDownload(url, fileName, context);
    } else if (Platform.isIOS) {
      await _iosDownload(url, fileName, context);
    }
  }
  Future<void> _iosDownload(String url, String fileName, BuildContext context) async {
    try {
      // iOS doesn't require storage permissions for app directories
      final directory = await getApplicationDocumentsDirectory();
      final savePath = "${directory.path}/$fileName";

      // Download using Dio
      await Dio().download(url, savePath);

      // Show success message with file location info
      _showSnackBar(
        context,
        "Download complete! Access files in: Files app → Browse → On My iPhone → Primax",
      );

      // Optional: Refresh file list if using a file browser
      // if (Platform.isIOS) await refreshFileSystem();

    } catch (e) {
      _showSnackBar(context, "Download failed: ${e.toString()}");
      print("iOS Download Error: $e");
    }
  }
  void openDownloadedFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      print("Open file result: ${result.message}");
    } catch (e) {
      print("Error opening file: $e");
    }
  }

  Future<void> _androidDownload(String url, String fileName, BuildContext context) async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;

      if (sdkVersion != null && sdkVersion < 29) {
        // Legacy Android handling
        // if (!await _requestStoragePermission()) return;
                  final status = await Permission.storage.request();
                  if (!status.isGranted) {
                    _showSnackBar(context, "Storage permission denied!");
                    return;
                  }

        final directory = await getExternalStorageDirectory();
        final savePath = "${directory!.path}/$fileName";
        await Dio().download(url, savePath);
        _showSnackBar(context, "Download completed: $fileName");
      } else {
        // Android 10+ using DownloadManager
        final taskId = await FlutterDownloader.enqueue(
          url: url,
          savedDir: (await getExternalStorageDirectory())!.path,
          fileName: fileName,
          showNotification: true,
          openFileFromNotification: true,
          saveInPublicStorage: true,
        );

        _showSnackBar(context, "Download started - check notifications");
      }
    } catch (e) {
      _showSnackBar(context, "Download error: ${e.toString()}");
      print("Download Error: $e");
    }
  }
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          "Download Center",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child:isLoading ? Center(child: CircularProgressIndicator()): Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                "Choose Brand",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: brands.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return ChoiceChip(
                      showCheckmark: false,
                      label: Row(
                        children: [
                          Image.network(brands[index]["imageUrl"]!,
                              width: 40, height: 50),
                          const SizedBox(width: 8),
                          Text(brands[index]["name"]!),
                        ],
                      ),
                      selected: selectedBrand == index,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedBrand = index;
                        });
                        fetchDocuments();
                      },
                      color: WidgetStateProperty.all(Colors.grey.shade100),
                      backgroundColor: Colors.white,
                      selectedColor: Colors.blue.withOpacity(0.2),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: selectedBrand == index
                              ? Colors.green
                              : Colors.grey.shade200,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Document Category",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(documentCategories.length, (index) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = index;
                        });
                        fetchDocuments();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: selectedCategory == index
                                  ? Colors.blue
                                  : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                          color: selectedCategory == index
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            documentCategories[index],
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: selectedCategory == index
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: documents.isEmpty
                    ? const Center(child: Text("No Files Available"))
                    : GridView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    var data = documents[index].data() as Map<String, dynamic>;
                    return GestureDetector(
                      // Make entire item tappable to view file
                      onTap: () => _viewOrDownloadFile(data['file_url'], data['file_name'], context),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              data['image'],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
                                      SizedBox(height: 8),
                                      Text(data['file_name'], 
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 10),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              left:0,
                              child:Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 40.0),
                                    child: Text(
                                      data['file_name'],
                                      style: TextStyle(color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ))
                          ),

                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => downloadFile(data['file_url'], data['file_name'], context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 6),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF47C6EB), Color(0xFF54E88C)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(12)),
                                ),
                                child: SvgPicture.asset(
                                  height: 25,
                                  width: 25,
                                  'assets/icons/ic_download.svg',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
