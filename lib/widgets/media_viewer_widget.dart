import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MediaViewerWidget extends StatefulWidget {
  final String mediaUrl;
  final double height;
  final double width;
  final BoxFit fit;

  const MediaViewerWidget({
    Key? key,
    required this.mediaUrl,
    this.height = 200,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<MediaViewerWidget> createState() => _MediaViewerWidgetState();
}

class _MediaViewerWidgetState extends State<MediaViewerWidget> {
  VideoPlayerController? _videoController;
  WebViewController? _webViewController;
  bool _isVideo = false;
  bool _isYouTube = false;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _youtubeVideoId;

  @override
  void initState() {
    super.initState();
    _checkMediaType();
  }

  void _checkMediaType() {
    final url = widget.mediaUrl.toLowerCase();
    
    // Check if it's a YouTube video
    if (_isYouTubeUrl(url)) {
      _isYouTube = true;
      _youtubeVideoId = _extractYouTubeVideoId(widget.mediaUrl);
      _initializeYouTubePlayer();
    }
    // Check if the URL is a regular video
    else if (url.endsWith('.mp4') || 
        url.endsWith('.mov') || 
        url.endsWith('.avi') || 
        url.endsWith('.webm') ||
        url.contains('video')) {
      _isVideo = true;
      _initializeVideoPlayer();
    }
  }

  bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com') || 
           url.contains('youtu.be') || 
           url.contains('youtube-nocookie.com');
  }

  String? _extractYouTubeVideoId(String url) {
    // Handle youtube.com/watch?v=VIDEO_ID format
    final regex1 = RegExp(r'[?&]v=([^&]+)');
    final match1 = regex1.firstMatch(url);
    if (match1 != null) {
      return match1.group(1);
    }
    
    // Handle youtu.be/VIDEO_ID format
    final regex2 = RegExp(r'youtu\.be/([^?]+)');
    final match2 = regex2.firstMatch(url);
    if (match2 != null) {
      return match2.group(1);
    }
    
    // Handle youtube.com/embed/VIDEO_ID format
    final regex3 = RegExp(r'embed/([^?]+)');
    final match3 = regex3.firstMatch(url);
    if (match3 != null) {
      return match3.group(1);
    }
    
    return null;
  }

  void _initializeYouTubePlayer() {
    if (_youtubeVideoId == null) {
      setState(() {
        _hasError = true;
      });
      return;
    }
    
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadRequest(
        Uri.parse('https://www.youtube.com/embed/$_youtubeVideoId?autoplay=1&loop=1&playlist=$_youtubeVideoId'),
      );
    
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _videoController = VideoPlayerController.network(widget.mediaUrl);
      await _videoController!.initialize();
      setState(() {
        _isInitialized = true;
      });
      // Auto-play the video
      _videoController!.play();
      _videoController!.setLooping(true);
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      print('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: widget.height,
        width: widget.width,
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 40, color: Colors.grey[600]),
              SizedBox(height: 8),
              Text('Failed to load media', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    if (_isYouTube) {
      if (!_isInitialized || _webViewController == null) {
        return Container(
          height: widget.height,
          width: widget.width,
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      }

      return Container(
        height: widget.height,
        width: widget.width,
        child: WebViewWidget(controller: _webViewController!),
      );
    } else if (_isVideo) {
      if (!_isInitialized) {
        return Container(
          height: widget.height,
          width: widget.width,
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      }

      return Container(
        height: widget.height,
        width: widget.width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            // Play/Pause overlay
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _videoController!.value.isPlaying ? 0.0 : 0.7,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Display as image (PNG, JPG, etc.)
      return Image.network(
        widget.mediaUrl,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => Container(
          height: widget.height,
          width: widget.width,
          color: Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 40, color: Colors.grey[600]),
                SizedBox(height: 8),
                Text('Failed to load image', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      );
    }
  }
}