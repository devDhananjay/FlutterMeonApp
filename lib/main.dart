import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'; // Permissions handler
import 'package:flutter_meon_kyc/flutter_meon_kyc.dart'; // KYC package
import 'package:flutter_meon_rekyc/flutter_meon_rekyc.dart'; // Re-KYC package
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // InAppWebView package

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter KYC & Re-KYC App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController clientIdController = TextEditingController();
  TextEditingController workflowIdController = TextEditingController();

  Future<bool> requestPermissions(BuildContext context) async {
    if (await Permission.camera.request().isDenied) {
      _showPermissionDialog(context, 'Camera');
      return false;
    }
    if (await Permission.location.request().isDenied) {
      _showPermissionDialog(context, 'Location');
      return false;
    }
    return true;
  }


  void _showPermissionDialog(BuildContext context, String permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permission Permission Required'),
        content: Text(
            'This app requires $permission permission to proceed. Please enable it in settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter KYC & Re-KYC App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: clientIdController,
                decoration: const InputDecoration(
                  labelText: 'Enter Client ID',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: workflowIdController,
                decoration: const InputDecoration(
                  labelText: 'Enter Workflow ID',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool permissionsGranted = await requestPermissions(context);
                if (permissionsGranted) {
                  String clientId = clientIdController.text;
                  String workflowId = workflowIdController.text;
                  if (clientId.isNotEmpty && workflowId.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SDKCallReKyc(
                          clientId: clientId,
                          workflowId: workflowId,
                        ),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error'),
                        content: const Text(
                            'Please fill in both Client ID and Workflow ID.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              child: const Text('Call Re-KYC SDK'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool permissionsGranted = await requestPermissions(context);
                if (permissionsGranted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SDKCall(
                        companyName: 'RKGLOBAL',
                        workflowName: 'individual',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Call KYC SDK'),
            ),
            const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => WebViewScreen(),
            //       ),
            //     );
            //   },
            //   child: const Text('Open WebView'),
            // ),
          ],
        ),
      ),
    );
  }
}

// ✅ **Updated WebView with JavaScript & Autoplay Support**
class WebViewScreen extends StatefulWidget {
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final InAppWebView _webView;

  @override
  void initState() {
    super.initState();
    _webView = InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(
          'https://rekyc.meon.co.in//v1/company/lkpsec/modification/login?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc0Mjk4MzU1OSwiaWF0IjoxNzQyMzc4NzU5LCJqdGkiOiJkYTUwZWQzODA2ZTg0NTdlYTAzYjA2ODRhZWU0NjdiOCIsInVzZXJfaWQiOiI4NjM3YzNiYi03YjA4LTQwZjQtYjAzYS03ZDE4ZGRlMmFkNmYifQ.8Ak5Ni2E_DVSiXcLbSYChb_rsT-yLYVyes2crUH9RnU&redirect_to=/v1/user/Others/page',
        ),
      ),
      onWebViewCreated: (controller) {
      },
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          javaScriptEnabled: true,
          mediaPlaybackRequiresUserGesture: false, // ✅ Autoplay enabled for both Android and iOS
          // geolocationEnabled: true,
        ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ),
      android: AndroidInAppWebViewOptions(
          allowFileAccess: true,
          allowContentAccess: true,
          useHybridComposition: true,
          geolocationEnabled: true,
        ),
      ),
      onConsoleMessage: (controller, consoleMessage) {
      print(consoleMessage.message);
    },
    onJsAlert: (controller, jsAlertRequest) async {
      return JsAlertResponse(handledByClient: true);
    },
    onPermissionRequest: (controller, request) async {
      print("Permission requested: ${request.resources}");
      // ✅ Grant Camera & Microphone permissions explicitly
      return PermissionResponse(
        resources: request.resources,
        action: PermissionResponseAction.GRANT,
      );
    },
    onGeolocationPermissionsShowPrompt: (controller, origin) async {
        return GeolocationPermissionShowPromptResponse(
          origin: origin, // ✅ Required parameter
          allow: true, // ✅ Allow location access
          retain: true, // ✅ Save permission state
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('InAppWebView Example'),
      ),
      body: _webView,
    );
  }
}