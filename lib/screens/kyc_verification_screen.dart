import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// Screen 1: KYC Verification Screen (Full Screen)
class KYCVerificationScreen extends StatefulWidget {
  const KYCVerificationScreen({super.key});

  @override
  KYCVerificationScreenState createState() => KYCVerificationScreenState();
}

class KYCVerificationScreenState extends State<KYCVerificationScreen> with WidgetsBindingObserver {
  InAppWebViewController? _controller;
  bool _permissionsRequested = false;
  bool _isLoading = true;
  PullToRefreshController? _pullToRefreshController;
  double _progress = 0;
  bool _isFaceFinderPage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        await _handleRefresh();
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pullToRefreshController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed && _isFaceFinderPage) {
      print("📱 App resumed - checking permissions for FaceFinder");
      _checkAndHandlePermissions();
    }
  }

  Future<void> _checkAndHandlePermissions() async {
    if (!_isFaceFinderPage) return;

    print("🔍 Checking current permission status...");
    
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;
    final locationStatus = await Permission.location.status;

    print("📷 Camera: $cameraStatus");
    print("🎤 Microphone: $microphoneStatus");
    print("📍 Location: $locationStatus");

    List<String> newlyGranted = [];
    if (cameraStatus.isGranted) newlyGranted.add('Camera');
    if (microphoneStatus.isGranted) newlyGranted.add('Microphone');
    if (locationStatus.isGranted) newlyGranted.add('Location');

    List<String> stillDenied = [];
    if (!cameraStatus.isGranted) stillDenied.add('Camera');
    if (!microphoneStatus.isGranted) stillDenied.add('Microphone');
    if (!locationStatus.isGranted) stillDenied.add('Location');

    if (newlyGranted.isNotEmpty && _controller != null) {
      print("✅ Some permissions granted - updating WebView: ${newlyGranted.join(', ')}");
      
      await _controller!.setOptions(
        options: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(
            geolocationEnabled: locationStatus.isGranted,
          ),
        ),
      );

      await _controller!.evaluateJavascript(source: """
        if (${cameraStatus.isGranted} && typeof window.reinitializeCamera === 'function') {
          window.reinitializeCamera();
        }
        
        window.dispatchEvent(new CustomEvent('permissionsUpdated', {
          detail: { 
            camera: ${cameraStatus.isGranted}, 
            microphone: ${microphoneStatus.isGranted}, 
            location: ${locationStatus.isGranted}
          }
        }));
        
        console.log('Permissions updated - Camera: ${cameraStatus.isGranted}, Microphone: ${microphoneStatus.isGranted}, Location: ${locationStatus.isGranted}');
      """);

      String message = '✅ ${newlyGranted.join(', ')} permission(s) granted!';
      if (stillDenied.isNotEmpty) {
        message += '\n⚠️ ${stillDenied.join(', ')} still denied';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: newlyGranted.isNotEmpty ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );

      if (cameraStatus.isGranted) {
        await Future.delayed(const Duration(milliseconds: 500));
        _controller!.reload();
      }
      
    } else if (stillDenied.isNotEmpty) {
      print("⚠️ Still missing permissions: ${stillDenied.join(', ')}");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Missing: ${stillDenied.join(', ')} permissions'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleRefresh() async {
    print("🔄 Refresh triggered");
    
    if (_isFaceFinderPage) {
      await _checkAndHandlePermissions();
    }
    
    if (Platform.isAndroid) {
      _controller?.reload();
    } else if (Platform.isIOS) {
      _controller?.loadUrl(
          urlRequest: URLRequest(url: await _controller?.getUrl()));
    }
  }

  Future<bool> requestPermissionsForFaceFinder() async {
    print("🔐 Requesting permissions for FaceFinder...");
    
    final currentCameraStatus = await Permission.camera.status;
    final currentMicStatus = await Permission.microphone.status;
    final currentLocationStatus = await Permission.location.status;

    print("📋 Current permissions - Camera: $currentCameraStatus, Mic: $currentMicStatus, Location: $currentLocationStatus");

    bool cameraGranted = false;
    bool microphoneGranted = false;
    bool locationGranted = false;

    if (!currentCameraStatus.isGranted) {
      final cameraResult = await Permission.camera.request();
      cameraGranted = cameraResult.isGranted;
      print("📷 Camera permission result: $cameraResult");
    } else {
      cameraGranted = true;
    }

    if (!currentMicStatus.isGranted) {
      final micResult = await Permission.microphone.request();
      microphoneGranted = micResult.isGranted;
      print("🎤 Microphone permission result: $micResult");
    } else {
      microphoneGranted = true;
    }

    if (!currentLocationStatus.isGranted) {
      final locationResult = await Permission.location.request();
      locationGranted = locationResult.isGranted;
      print("📍 Location permission result: $locationResult");
    } else {
      locationGranted = true;
    }

    print("📊 Final permission status:");
    print("📷 Camera: ${cameraGranted ? '✅ Granted' : '❌ Denied'}");
    print("🎤 Microphone: ${microphoneGranted ? '✅ Granted' : '❌ Denied'}");
    print("📍 Location: ${locationGranted ? '✅ Granted' : '❌ Denied'}");

    if (!cameraGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📷 Camera permission denied - Camera features will be limited'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
    
    if (!microphoneGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎤 Microphone permission denied - Audio features will be limited'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
    
    if (!locationGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📍 Location permission denied - Location features will be limited'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }

    bool canProceed = cameraGranted;
    
    if (canProceed) {
      print("✅ Essential permissions granted - proceeding with KYC");
    } else {
      print("❌ Essential permissions (Camera) not granted");
      _showPermissionDialog('Camera');
    }
    
    return canProceed;
  }

  Future<void> handleWebcamError() async {
    print("🚫 Webcam error detected, checking permissions...");
    
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;
    final locationStatus = await Permission.location.status;

    if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied || !cameraStatus.isGranted) {
      print("❌ Camera permission needs to be requested");
      _showPermissionErrorDialog('Camera', Permission.camera);
    } else if (microphoneStatus.isDenied || microphoneStatus.isPermanentlyDenied || !microphoneStatus.isGranted) {
      print("❌ Microphone permission needs to be requested");
      _showPermissionErrorDialog('Microphone', Permission.microphone);
    } else if (locationStatus.isDenied || locationStatus.isPermanentlyDenied || !locationStatus.isGranted) {
      print("❌ Location permission needs to be requested");
      _showPermissionErrorDialog('Location', Permission.location);
    } else {
      print("🤔 All permissions seem granted, showing generic error");
      _showGenericWebcamErrorDialog();
    }
  }

  void _showPermissionDialog(String permission) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('$permission Permission Required'),
        content: Text(
            'KYC verification requires $permission permission. Please enable it in settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showPermissionErrorDialog(String permission, Permission permissionType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 10),
            Text('$permission Access Needed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Webcam initialization failed because $permission permission was denied.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            const Text(
              'To continue with KYC verification, please:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('1. Allow $permission permission\n2. App will automatically refresh the page'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _requestSpecificPermission(permissionType, permission);
            },
            child: const Text('Grant Permission'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestSpecificPermission(Permission permissionType, String permissionName) async {
    print("🔐 Requesting $permissionName permission...");
    
    final status = await permissionType.request();
    
    print("📋 Permission status: $status");
    
    if (status.isGranted) {
      print("✅ $permissionName permission granted!");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $permissionName permission granted! Checking all permissions...'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      await _checkAndHandlePermissions();
      
    } else if (status.isDenied) {
      print("❌ $permissionName permission denied");
      _showRetryPermissionDialog(permissionName, permissionType);
      
    } else if (status.isPermanentlyDenied) {
      print("🚫 $permissionName permission permanently denied");
      _showPermanentlyDeniedDialog(permissionName);
      
    } else if (status.isRestricted) {
      print("🔒 $permissionName permission restricted");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $permissionName access is restricted on this device'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showRetryPermissionDialog(String permission, Permission permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permission Permission Denied'),
        content: Text(
            '$permission permission was denied. Would you like to try again or go to settings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _requestSpecificPermission(permissionType, permission);
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showPermanentlyDeniedDialog(String permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permission Permission Permanently Denied'),
        content: Text(
            '$permission permission has been permanently denied. Please enable it manually in the app settings. The page will refresh automatically when you return.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showGenericWebcamErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Webcam Error'),
          ],
        ),
        content: const Text(
            'There was an error accessing the webcam. Please check your permissions and try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleRefresh();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            bool canGoBack = await _controller?.canGoBack() ?? false;
            if (canGoBack) {
              _controller?.goBack();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _handleRefresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri('https://live.meon.co.in/univest/ra_kyc_uat'),
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
                print("🌐 WebView created successfully");
              },
              pullToRefreshController: _pullToRefreshController,
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
                if (progress == 100) {
                  _pullToRefreshController?.endRefreshing();
                }
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  mediaPlaybackRequiresUserGesture: false,
                  cacheEnabled: true,
                  transparentBackground: true,
                  supportZoom: false,
                  userAgent: "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Mobile Safari/537.36",
                ),
                android: AndroidInAppWebViewOptions(
                  allowFileAccess: true,
                  allowContentAccess: true,
                  useHybridComposition: true,
                  geolocationEnabled: false,
                  domStorageEnabled: true,
                  thirdPartyCookiesEnabled: true,
                  mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                ),
                ios: IOSInAppWebViewOptions(
                  allowsInlineMediaPlayback: true,
                  allowsBackForwardNavigationGestures: true,
                  allowsLinkPreview: true,
                  isFraudulentWebsiteWarningEnabled: false,
                  sharedCookiesEnabled: true,
                ),
              ),
              onLoadStart: (controller, url) async {
                print("📱 Page started loading: $url");
                setState(() {
                  _isLoading = true;
                });
                
                bool isFaceFinder = url != null && url.toString().contains('facefinder');
                setState(() {
                  _isFaceFinderPage = isFaceFinder;
                });
                
                if (isFaceFinder) {
                  print("🎯 FaceFinder URL detected: ${url.toString()}");
                  
                  if (!_permissionsRequested) {
                    _permissionsRequested = true;
                    
                    await Future.delayed(const Duration(milliseconds: 500));
                    
                    bool permissionsGranted = await requestPermissionsForFaceFinder();
                    
                    if (permissionsGranted) {
                      print("✅ Permissions granted, enabling WebView features");
                      
                      await controller.setOptions(
                        options: InAppWebViewGroupOptions(
                          android: AndroidInAppWebViewOptions(
                            geolocationEnabled: true,
                          ),
                        ),
                      );
                      
                      await controller.reload();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Permissions granted. KYC process can continue.'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                }
              },
              onLoadStop: (controller, url) async {
                print("✅ Page finished loading: $url");
                setState(() {
                  _isLoading = false;
                });
                _pullToRefreshController?.endRefreshing();
              },
              onConsoleMessage: (controller, consoleMessage) {
                print("Console: ${consoleMessage.message}");
                
                if (consoleMessage.message.contains("Webcam init error") ||
                    consoleMessage.message.contains("NotAllowedError") ||
                    consoleMessage.message.contains("permission") && 
                    consoleMessage.message.toLowerCase().contains("denied")) {
                  
                  print("🚨 Webcam permission error detected in console");
                  
                  Future.delayed(const Duration(milliseconds: 500), () {
                    handleWebcamError();
                  });
                }
              },
              onPermissionRequest: (controller, request) async {
                print("🔑 WebView permission requested: ${request.resources}");
                
                List<PermissionResourceType> grantedResources = [];
                
                for (var resource in request.resources) {
                  bool shouldGrant = false;
                  
                  String resourceName = resource.toString();
                  
                  if (resourceName.contains('CAMERA')) {
                    final status = await Permission.camera.status;
                    shouldGrant = status.isGranted;
                    print("📷 Camera permission status: $status");
                  } else if (resourceName.contains('MICROPHONE')) {
                    final status = await Permission.microphone.status;
                    shouldGrant = status.isGranted;
                    print("🎤 Microphone permission status: $status");
                  } else if (resourceName.contains('LOCATION') || resourceName.contains('GEOLOCATION')) {
                    final status = await Permission.location.status;
                    shouldGrant = status.isGranted;
                    print("📍 Location permission status: $status");
                  } else {
                    String? currentUrl = (await controller.getUrl())?.toString();
                    shouldGrant = currentUrl != null && currentUrl.contains('facefinder');
                  }
                  
                  if (shouldGrant) {
                    grantedResources.add(resource);
                    print("✅ Granting WebView permission for: $resource");
                  } else {
                    print("❌ Denying WebView permission for: $resource (not granted at system level)");
                  }
                }
                
                if (grantedResources.isNotEmpty) {
                  return PermissionResponse(
                    resources: grantedResources,
                    action: PermissionResponseAction.GRANT,
                  );
                } else {
                  return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.DENY,
                  );
                }
              },
              onGeolocationPermissionsShowPrompt: (controller, origin) async {
                print("🌍 Geolocation permission prompt for origin: $origin");
                
                final locationStatus = await Permission.location.status;
                bool shouldAllowLocation = locationStatus.isGranted && 
                                         origin.contains('facefinder');
                
                if (shouldAllowLocation) {
                  print("✅ Allowing geolocation for FaceFinder (permission granted)");
                  return GeolocationPermissionShowPromptResponse(
                    origin: origin,
                    allow: true,
                    retain: true,
                  );
                } else {
                  if (!locationStatus.isGranted) {
                    print("❌ Denying geolocation (location permission not granted)");
                  } else {
                    print("❌ Denying geolocation (not FaceFinder domain)");
                  }
                  return GeolocationPermissionShowPromptResponse(
                    origin: origin,
                    allow: false,
                    retain: false,
                  );
                }
              },
              onLoadError: (controller, url, code, message) {
                print("❌ Load error: $message");
                setState(() {
                  _isLoading = false;
                });
                _pullToRefreshController?.endRefreshing();
              },
            ),
            
            if (_progress < 1.0)
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                minHeight: 3,
              ),
            
            if (_isLoading)
              Center(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                bool canGoBack = await _controller?.canGoBack() ?? false;
                if (canGoBack) {
                  _controller?.goBack();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () async {
                bool canGoForward = await _controller?.canGoForward() ?? false;
                if (canGoForward) {
                  _controller?.goForward();
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh, 
                color: _isFaceFinderPage ? Colors.blue : null),
              onPressed: () async {
                await _handleRefresh();
              },
            ),
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                _controller?.loadUrl(
                  urlRequest: URLRequest(
                    url: WebUri('https://live.meon.co.in/univest/ra_kyc_uat'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

