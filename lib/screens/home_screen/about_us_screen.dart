import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

import '../../widgets/comman_back_button.dart';

class AboutUsScreen extends StatefulWidget {
  final String url;
  final String title;

  const AboutUsScreen({
    Key? key,
    required this.url,
    this.title = 'About Us',
  }) : super(key: key);

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  double _loadingProgress = 0.0;

  // App color scheme
  final Color seedColor = Color(0xFF1EA3D0);
  final Color primaryColor = Color(0xFF4AB255);
  final Color onPrimaryColor = Colors.white;
  final Color secondaryColor = Color(0xFF1EA3D0);
  final Color onSecondaryColor = Color(0xFF33384B);

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = '${error.description}';
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<bool> _onWillPop() async {
    if (await _webViewController.canGoBack()) {
      _webViewController.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: CommonBackButton(onPressed: ()=>Navigator.pop(context)),
          title: Text(widget.title,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),),
          centerTitle: true,
          // backgroundColor: primaryColor,
          iconTheme: IconThemeData(color: onPrimaryColor),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh,color: Colors.black,),
              onPressed: () {
                _webViewController.reload();
              },
            ),
          ],
          // systemOverlayStyle: SystemUiOverlayStyle(
          //   statusBarColor: Colors.white,
          //   statusBarIconBrightness: Brightness.light,
          // ),
        ),
        body: Stack(
          children: [
            // WebView
            WebViewWidget(controller: _webViewController),

            // Loading Indicator
            if (_isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo or App Icon (optional)
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: secondaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.info_outline,
                          size: 60,
                          color: secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: onSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                          value: _loadingProgress,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_loadingProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: onSecondaryColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Error View
            if (_hasError)
              Container(
                color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Oops! Something went wrong',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: onSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: onSecondaryColor.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _hasError = false;
                              _isLoading = true;
                            });
                            _webViewController.reload();
                          },
                          icon: Icon(Icons.refresh),
                          label: Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: onPrimaryColor,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
