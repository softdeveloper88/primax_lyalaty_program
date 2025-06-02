import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
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

// Data class to track download status for each item
class DownloadItem {
  final String fileName;
  final String url;
  String? taskId;
  String? filePath;
  int progress = 0;
  bool isDownloading = false;
  bool isComplete = false;
  bool hasError = false;
  String? errorMessage;

  DownloadItem({
    required this.fileName,
    required this.url,
  });
}

class DownloadCenterScreen extends StatefulWidget {
  const DownloadCenterScreen({super.key});

  @override
  State<DownloadCenterScreen> createState() => _DownloadCenterScreenState();
}

class _DownloadCenterScreenState extends State<DownloadCenterScreen> {
  // For FlutterDownloader callback
  final ReceivePort _port = ReceivePort();
  
  // Maps to track download progress and status
  Map<String, DownloadItem> _downloadItems = {};
  
  int selectedCategory = 0; // 0 for Datasheets, 1 for User Manuals
  int selectedBrand = 0; // Index for selected brand
  List<Map<String, String>> brands = [];
  List<DocumentSnapshot> documents = [];
  bool isLoading=true;
  
  // Stream controller for better progress updates
  StreamController<Map<String, DownloadItem>> _progressController = StreamController<Map<String, DownloadItem>>.broadcast();
  Stream<Map<String, DownloadItem>> get progressStream => _progressController.stream;

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
    
    // Create a timer to refresh the UI periodically
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (mounted && _downloadItems.isNotEmpty) {
        // Push the current progress to the stream
        _progressController.add(Map.from(_downloadItems));
      }
    });
    
    getBrandsData();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    _progressController.close();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'download_isolate');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    
    _port.listen((dynamic data) {
      String id = data[0];
      int statusInt = data[1];
      int progress = data[2];
      
      // Convert int status to DownloadTaskStatus
      DownloadTaskStatus status = DownloadTaskStatus.values[statusInt];

      // Find which file this taskId belongs to
      String? fileName;
      for (var entry in _downloadItems.entries) {
        if (entry.value.taskId == id) {
          fileName = entry.key;
          break;
        }
      }

      if (fileName != null) {
        // Using mounted check to avoid calling setState after dispose
        if (mounted) {
          setState(() {
            _downloadItems[fileName]!.progress = progress;
            
            if (status == DownloadTaskStatus.complete) {
              _downloadItems[fileName]!.isComplete = true;
              _downloadItems[fileName]!.isDownloading = false;
              _onDownloadComplete(id, fileName);
            } else if (status == DownloadTaskStatus.failed) {
              _downloadItems[fileName]!.hasError = true;
              _downloadItems[fileName]!.isDownloading = false;
              _downloadItems[fileName]!.errorMessage = "Download failed";
            }
          });
          
          // Push the update to the stream for real-time UI updates
          _progressController.add(Map.from(_downloadItems));
        }
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('download_isolate');
  }

  void _onDownloadComplete(String taskId, String? fileName) async {
    // Handle the case if fileName is null
    if (fileName == null) return;
    
    // Get the download task info
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
      query: "SELECT * FROM task WHERE task_id = '$taskId'",
    );
    
    if (tasks != null && tasks.isNotEmpty) {
      final task = tasks.first;
      final filePath = task.savedDir + "/" + (task.filename ?? "");
      
      setState(() {
        _downloadItems[fileName]!.filePath = filePath;
      });
    }
  }
  final List<String> documentCategories = [
    "Product Datasheets",
    "Product User Manuals"
  ];
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
      // Create or update the download item entry
      if (!_downloadItems.containsKey(fileName)) {
        _downloadItems[fileName] = DownloadItem(fileName: fileName, url: url);
      }
      
      // If already downloading, don't start again
      if (_downloadItems[fileName]!.isDownloading) {
        return;
      }
      
      // Mark as downloading
      setState(() {
        _downloadItems[fileName]!.isDownloading = true;
        _downloadItems[fileName]!.progress = 0;
        _downloadItems[fileName]!.hasError = false;
        _downloadItems[fileName]!.isComplete = false;
      });
      
      // iOS version check
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      final iosVersion = iosInfo.systemVersion;
      
      // For iOS 13+, save to a location accessible by Files app
      Directory saveDirectory;
      double? majorVersion = double.tryParse(iosVersion?.split('.')[0] ?? "0");
      
      if (majorVersion != null && majorVersion >= 13.0) {
        // For iOS 13+, create a folder in the app's documents directory that's shared with Files app
        final documentDirectory = await getApplicationDocumentsDirectory();
        saveDirectory = Directory("${documentDirectory.path}/Downloads");
        
        // Ensure the Downloads directory exists
        if (!await saveDirectory.exists()) {
          await saveDirectory.create(recursive: true);
        }
      } else {
        // For older iOS versions, use standard documents directory
        saveDirectory = await getApplicationDocumentsDirectory();
      }
      
      // Handle duplicate files by checking if file already exists
      String finalFileName = fileName;
      String baseName;
      String extension;
      int counter = 1;
      
      // Handle filename with or without extension
      if (fileName.contains('.')) {
        baseName = fileName.substring(0, fileName.lastIndexOf('.'));
        extension = fileName.substring(fileName.lastIndexOf('.'));
      } else {
        baseName = fileName;
        extension = '';
      }
      
      // Check if file exists and create a unique name if needed
      File tempFile = File("${saveDirectory.path}/$finalFileName");
      while (await tempFile.exists()) {
        finalFileName = "${baseName}_$counter$extension";
        tempFile = File("${saveDirectory.path}/$finalFileName");
        counter++;
      }
      
      final savePath = "${saveDirectory.path}/$finalFileName";

      // Configure Dio options for reliable downloading
      final dio = Dio();
      dio.options.responseType = ResponseType.bytes;
      dio.options.followRedirects = true;
      dio.options.receiveTimeout = const Duration(minutes: 5);
      
      // Download using Dio with progress tracking
      final response = await dio.download(
        url, 
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Use mounted check to prevent setState after dispose
            if (mounted) {
              int progress = (received / total * 100).round();
              // Update progress directly on the item
              setState(() {
                _downloadItems[fileName]!.progress = progress;
              });
            }
          }
        },
        options: Options(
          headers: {
            // Add any necessary headers for iOS downloads
            "Connection": "keep-alive",
          },
        ),
      );

      // Check download success
      if (response.statusCode == 200) {
        // Update status to complete
        if (mounted) {
          setState(() {
            _downloadItems[fileName]!.isComplete = true;
            _downloadItems[fileName]!.isDownloading = false;
            _downloadItems[fileName]!.filePath = savePath;
          });
        }
        
        // Show success message with clear instructions for users
        if (majorVersion != null && majorVersion >= 13.0) {
          _showSnackBar(context, "File '$finalFileName' downloaded successfully! Open Files app > On My iPhone/iPad > Primax > Downloads to access it.");
        } else {
          _showSnackBar(context, "File '$finalFileName' downloaded successfully!");
        }
      } else {
        throw Exception("Download failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloadItems[fileName]!.isDownloading = false;
          _downloadItems[fileName]!.hasError = true;
          _downloadItems[fileName]!.errorMessage = e.toString();
        });
      }
      _showSnackBar(context, "Download failed: ${e.toString()}");
      print("iOS Download Error: $e");
    }
  }
  void openDownloadedFile(String filePath) async {
    try {
      // Check if file exists before attempting to open
      final file = File(filePath);
      if (!await file.exists()) {
        _showSnackBar(context, "File not found. It may have been moved or deleted.");
        return;
      }
      
      // Try to open the file with appropriate handling for different platforms
      final result = await OpenFile.open(
        filePath,
        type: _getFileType(filePath), // Specify file type based on extension
      );
      
      if (result.type != ResultType.done) {
        print("Open file result: ${result.message}");
        
        // Handle common issues
        if (result.message.contains("No app associated")) {
          _showSnackBar(context, "No app found to open this file type.");
        } else {
          _showSnackBar(context, "Could not open file: ${result.message}");
        }
      }
    } catch (e) {
      print("Error opening file: $e");
      _showSnackBar(context, "Error opening file: ${e.toString()}");
    }
  }
  
  // Helper method to determine file MIME type
  String? _getFileType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'txt':
        return 'text/plain';
      default:
        return null; // Let the system determine the type
    }
  }
  
  // This method was removed since open_file 3.5.10 doesn't support UTI parameter

  Future<void> _androidDownload(String url, String fileName, BuildContext context) async {
    try {
      // Create or update the download item entry
      if (!_downloadItems.containsKey(fileName)) {
        _downloadItems[fileName] = DownloadItem(fileName: fileName, url: url);
      }
      
      // If already downloading, don't start again
      if (_downloadItems[fileName]!.isDownloading) {
        return;
      }
      
      // Mark as downloading
      setState(() {
        _downloadItems[fileName]!.isDownloading = true;
        _downloadItems[fileName]!.progress = 0;
        _downloadItems[fileName]!.hasError = false;
        _downloadItems[fileName]!.isComplete = false;
      });
      
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;

      // Request appropriate permissions based on Android version
      bool permissionGranted = false;
      
      if (sdkVersion != null) {
        if (sdkVersion >= 33) { // Android 13+
          // For Android 13+ (API 33+), need media permissions
          final downloads = await Permission.mediaLibrary.request();
          permissionGranted = downloads.isGranted;
        } else if (sdkVersion >= 29) { // Android 10-12
          // For Android 10-12, we need storage permission
          final status = await Permission.storage.request();
          permissionGranted = status.isGranted;
        } else { // Android 9 and below
          // For older Android versions
          final status = await Permission.storage.request();
          permissionGranted = status.isGranted;
        }
      }
      
      if (!permissionGranted) {
        setState(() {
          _downloadItems[fileName]!.isDownloading = false;
          _downloadItems[fileName]!.hasError = true;
          _downloadItems[fileName]!.errorMessage = "Permission denied";
        });
        _showSnackBar(context, "Storage permission denied! Please grant permission in settings.");
        return;
      }

      // Get the appropriate download directory based on Android version
      Directory? directory;
      if (sdkVersion != null && sdkVersion >= 29) {
        // For Android 10+, use app's files directory or Downloads directory
        directory = await getApplicationDocumentsDirectory();
      } else {
        // For older Android versions, use external storage
        directory = await getExternalStorageDirectory();
      }
      
      if (directory == null) {
        setState(() {
          _downloadItems[fileName]!.isDownloading = false;
          _downloadItems[fileName]!.hasError = true;
          _downloadItems[fileName]!.errorMessage = "Could not access storage directory";
        });
        _showSnackBar(context, "Could not access storage directory");
        return;
      }

      // Ensure the directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Use FlutterDownloader with appropriate parameters for each Android version
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: directory.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: false, // We'll handle this ourselves
        saveInPublicStorage: sdkVersion != null && sdkVersion < 29, // Only use public storage for older Android versions
        headers: {}, // Add any required headers for the download
        requiresStorageNotLow: false,
      );

      // Store the task ID for progress tracking
      if (taskId != null) {
        setState(() {
          _downloadItems[fileName]!.taskId = taskId;
        });
      } else {
        throw Exception("Failed to start download task");
      }
    } catch (e) {
      setState(() {
        _downloadItems[fileName]!.isDownloading = false;
        _downloadItems[fileName]!.hasError = true;
        _downloadItems[fileName]!.errorMessage = e.toString();
      });
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
                          // Bottom bar for download controls and progress
                          Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: Builder(
                              builder: (context) {
                                final fileName = data['file_name'];
                                final downloadItem = _downloadItems[fileName];
                                final isDownloading = downloadItem?.isDownloading ?? false;
                                final isComplete = downloadItem?.isComplete ?? false;
                                final hasError = downloadItem?.hasError ?? false;
                                final progress = downloadItem?.progress ?? 0;

                                if (isDownloading) {
                                  // Use StreamBuilder for real-time progress updates
                                  return StreamBuilder<Map<String, DownloadItem>>(
                                    stream: progressStream,
                                    initialData: _downloadItems,
                                    builder: (context, snapshot) {
                                      // Get the latest progress value
                                      final items = snapshot.data;
                                      final currentItem = items?[fileName];
                                      final currentProgress = currentItem?.progress ?? 0;
                                      
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(12),
                                              bottomRight: Radius.circular(12)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            LinearProgressIndicator(
                                              value: currentProgress > 0 ? 
                                                    currentProgress / 100 : 0.01,
                                              backgroundColor: Colors.grey.shade600,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                  const Color(0xFF54E88C)),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              "Downloading: $currentProgress%",
                                              style: TextStyle(
                                                  color: Colors.white, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  );
                                } else if (isComplete) {
                                  // Show open button when download is complete
                                  return Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(12)),
                                    ),
                                    child: Row(
                                      children: [
                                        // File name area
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            child: Text(
                                              fileName,
                                              style: TextStyle(color: Colors.white),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        // Open button
                                        GestureDetector(
                                          onTap: () {
                                            if (downloadItem?.filePath != null) {
                                              openDownloadedFile(downloadItem!.filePath!);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 15),
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Color(0xFF47C6EB), Color(0xFF54E88C)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.only(
                                                  bottomRight: Radius.circular(12)),
                                            ),
                                            child: Text(
                                              "OPEN",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (hasError) {
                                  // Show retry button if there was an error
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 10),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(12)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Download Failed",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        GestureDetector(
                                          onTap: () => downloadFile(data['file_url'], fileName, context),
                                          child: Text(
                                            "RETRY",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  // Default download button
                                  return Row(
                                    children: [
                                      // File info area
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(12)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 6.0, right: 6.0),
                                            child: Text(
                                              fileName,
                                              style:
                                                  TextStyle(color: Colors.white),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Download button
                                      GestureDetector(
                                        onTap: () => downloadFile(data['file_url'], fileName, context),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 12),
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF47C6EB),
                                                Color(0xFF54E88C)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(12)),
                                          ),
                                          child: SvgPicture.asset(
                                            height: 25,
                                            width: 25,
                                            'assets/icons/ic_download.svg',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
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
