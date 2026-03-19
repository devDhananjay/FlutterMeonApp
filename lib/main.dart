import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'; // Permissions handler
import 'package:flutter_meon_kyc/flutter_meon_kyc.dart'; // KYC package
// import 'package:flutter_meon_rekyc/flutter_meon_rekyc.dart'; // Re-KYC package (temporarily disabled)
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // InAppWebView package
import 'package:url_launcher/url_launcher.dart';
import 'package:meon_face_verification/meon_face_verification.dart';
import 'package:meon_ipo_flutter/meon_ipo_flutter.dart';
import 'package:flutter_digilocker_aadhar_pan/flutter_digilocker_aadhar_pan.dart';
import 'package:flutter_meon_digilocker/meon_digilocker_sdk.dart';
import 'package:kyc_flutter_app/screens/home_sdk_tabs_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Meon App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeSdkTabsScreen(),
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
  TextEditingController ipoCompanyController =
      TextEditingController(text: 'ndaindia');

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
        title: const Text('Flutter Meon App'),
        bottom: const TabBar(
          tabs: [
            // Tab(text: 'Re-KYC'),
            Tab(text: 'KYC'),
            Tab(text: 'Face-Finder'),
            Tab(text: 'Digilocker A/P'),
            Tab(text: 'Meon Digilocker'),
            Tab(text: 'IPO'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          // _buildReKycTab(context),
          _buildKycTab(context),
          _buildFaceTab(context),
          _buildDigiLockerAadharPanTab(context),
          _buildMeonDigilockerTab(context),
          _buildIpoTab(context),
        ],
      ),
    );
  }

  Widget _buildReKycTab(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Re-KYC flow is temporarily disabled in this build.\n\n'
          'Only KYC (firstdemat) flow is active with flutter_meon_kyc 2.0.4.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildKycTab(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final permissionsGranted = await requestPermissions(context);
          if (!permissionsGranted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const KYCScreen(),
            ),
          );
        },
        child: const Text('Call KYC SDK'),
      ),
    );
  }

  Widget _buildFaceTab(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          bool permissionsGranted = await requestPermissions(context);
          if (permissionsGranted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FaceVerificationScreen(),
              ),
            );
          }
        },
        child: const Text('Call Face Verification'),
      ),
    );
  }



  Widget _buildDigiLockerAadharPanTab(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final config = DigiLockerConfig(
            companyName: 'democapital',
            secretToken: 'cy7Kw2rWqdzVo2KPxlU0ymd9uRQKPSsb',
            redirectUrl: 'https://meon.co.in',
          );

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => DigiLockerAadharPanScreen(config: config),
            ),
          );

          if (!context.mounted) return;
          if (result is DigiLockerResponse) {
            debugPrint('DigiLocker Success: ${result.toJson()}');
            debugPrint('Name: ${result.data?.name}');
            debugPrint('Aadhar: ${result.data?.aadharNo}');
            debugPrint('PAN: ${result.data?.panNumber}');

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('DigiLocker (Aadhar/PAN) success'),
              ),
            );
          }
        },
        child: const Text('Open DigiLocker Aadhar/PAN'),
      ),
    );
  }

  Widget _buildMeonDigilockerTab(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MeonDigilockerScreen(),
            ),
          );
        },
        child: const Text('Open Meon DigiLocker'),
      ),
    );
  }

    Widget _buildIpoTab(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: ipoCompanyController,
              decoration: const InputDecoration(
                labelText: 'Enter IPO Company Name',
                hintText: 'ndaindia',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final company = ipoCompanyController.text.trim();
                if (company.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Please enter a company name.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                await MeonIPO.instance.open(
                  context,
                  config: MeonIPOConfig(
                    companyName: company,
                    // Dynamically override base URL (optional)
                    baseUrl: 'https://ipo.meon.co.in',
                    mode: MeonIPOMode.inapp,
                    // Customize header text and colors (all optional)
                    headerTitle: 'IPO Portal',
                    headerStartColor: const Color(0xFF1976D2),
                    headerEndColor: const Color(0xFF0D47A1),
                  ),
                );
              },
              child: const Text('Call IPO SDK'),
            ),
          ],
        ),
      ),
    );
  }

}

class DigiLockerAadharPanScreen extends StatelessWidget {
  final DigiLockerConfig config;

  const DigiLockerAadharPanScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DigiLocker Aadhar/PAN'),
      ),
      body: DigiLockerWidget(
        config: config,
        onSuccess: (response) {
          // Close SDK screen immediately and return full response to caller.
          Navigator.of(context).pop(response);
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('DigiLocker error: $error'),
            ),
          );
        },
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class MeonDigilockerScreen extends StatelessWidget {
  const MeonDigilockerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meon DigiLocker')),
      body: DigilockerForm(
        companyName: 'democapital',
        secretToken: 'cy7Kw2rWqdzVo2KPxlU0ymd9uRQKPSsb',
        onSuccess: (response) {
          debugPrint('Meon DigiLocker Success: ${response.toJson()}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meon DigiLocker completed successfully')),
          );
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Meon DigiLocker error: $error')),
          );
        },
      ),
    );
  }
}

// ✅ **Updated WebView with JavaScript & Autoplay Support**
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _controller;

  final InAppWebViewGroupOptions _options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      javaScriptEnabled: true,
      mediaPlaybackRequiresUserGesture: false,
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
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_controller != null && await _controller!.canGoBack()) {
          await _controller!.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('UPI Payment Verification'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_controller != null && await _controller!.canGoBack()) {
                await _controller!.goBack();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(
              'https://rekyc.meon.co.in//v1/company/lkpsec/modification/login?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc0Mjk4MzU1OSwiaWF0IjoxNzQyMzc4NzU5LCJqdGkiOiJkYTUwZWQzODA2ZTg0NTdlYTAzYjA2ODRhZWU0NjdiOCIsInVzZXJfaWQiOiI4NjM3YzNiYi03YjA4LTQwZjQtYjAzYS03ZDE4ZGRlMmFkNmYifQ.8Ak5Ni2E_DVSiXcLbSYChb_rsT-yLYVyes2crUH9RnU&redirect_to=/v1/user/Others/page',
            ),
          ),
          initialOptions: _options,
          onWebViewCreated: (controller) {
            _controller = controller;
          },
          onConsoleMessage: (controller, consoleMessage) {
            // ignore: avoid_print
            print(consoleMessage.message);
          },
          onJsAlert: (controller, jsAlertRequest) async {
            return JsAlertResponse(handledByClient: true);
          },
          onPermissionRequest: (controller, request) async {
            // ignore: avoid_print
            print('Permission requested: ${request.resources}');
            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },
          onGeolocationPermissionsShowPrompt: (controller, origin) async {
            return GeolocationPermissionShowPromptResponse(
              origin: origin,
              allow: true,
              retain: true,
            );
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final uri = navigationAction.request.url;
            if (uri == null) {
              return NavigationActionPolicy.ALLOW;
            }

            final scheme = uri.scheme.toLowerCase();

            if (scheme == 'http' || scheme == 'https') {
              return NavigationActionPolicy.ALLOW;
            }

            const upiSchemes = <String>{
              'upi',
              'bhim',
              'gpay',
              'paytm',
              'phonepe',
              'whatsapp',
              'whatsapp-business',
            };

            if (upiSchemes.contains(scheme) ||
                (scheme.isNotEmpty && scheme != 'about')) {
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
              return NavigationActionPolicy.CANCEL;
            }

            return NavigationActionPolicy.ALLOW;
          },
          onLoadStop: (controller, url) async {
            // Fix iOS zooming on text inputs by enforcing viewport and font size
            await controller.evaluateJavascript(source: """
              (function() {
                var meta = document.querySelector('meta[name=viewport]');
                if (!meta) {
                  meta = document.createElement('meta');
                  meta.name = 'viewport';
                  document.head.appendChild(meta);
                }
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
              })();
            """);

            await controller.evaluateJavascript(source: """
              (function() {
                var elements = document.querySelectorAll('input, textarea, select');
                for (var i = 0; i < elements.length; i++) {
                  var el = elements[i];
                  var style = window.getComputedStyle(el);
                  var size = parseFloat(style.fontSize || '16');
                  if (size < 16) {
                    el.style.fontSize = '16px';
                  }
                }
              })();
            """);
          },
        ),
      ),
    );
  }
}

class KYCScreen extends StatelessWidget {
  const KYCScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeonKYC(
        companyName: 'firstdemat',
        workflow: 'individual_uat',
        enablePayments: true,
        autoRequestPermissions: true,
        showHeader: true,
        headerTitle: 'KYC Process',
        onSuccess: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('KYC completed successfully')),
          );
          Navigator.of(context).pop();
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class FaceVerificationScreen extends StatelessWidget {
  const FaceVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeonFaceVerification(
        clientId: '330JGFDI3MAAQ1',
        clientSecret: '33034zBrVX0YZOhhYpWzevoU9BydUJ8ILIhNe4C6jNE1',
        onSuccess: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Face verification successful')),
          );
          Navigator.of(context).pop();
        },
        onError: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $message')),
          );
        },
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}