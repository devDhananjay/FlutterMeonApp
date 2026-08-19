import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_meon_kyc/flutter_meon_kyc.dart';

class KycSdkLauncher extends StatefulWidget {
  const KycSdkLauncher({super.key});

  @override
  State<KycSdkLauncher> createState() => _KycSdkLauncherState();
}

class _KycSdkLauncherState extends State<KycSdkLauncher> {
  final _mobileController = TextEditingController(text: '9411441937');
  final _secretController = TextEditingController(
    text: 'kefMXWrR2ta8DTKEJRMAyqcLn7KA74hL',
  );
  final _companyController = TextEditingController(text: 'easterfin');
  final _workflowController = TextEditingController(text: 'individual');

  @override
  void dispose() {
    _mobileController.dispose();
    _secretController.dispose();
    _companyController.dispose();
    _workflowController.dispose();
    super.dispose();
  }

  Future<bool> _requestPermissions(BuildContext context) async {
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
          'This app requires $permission permission to proceed. Please enable it in settings.',
        ),
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

  Future<void> _openKyc({required bool sso}) async {
    final granted = await _requestPermissions(context);
    if (!granted || !mounted) return;

    final company = _companyController.text.trim();
    final workflow = _workflowController.text.trim();
    if (company.isEmpty || workflow.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter company name and workflow')),
      );
      return;
    }

    String? mobile;
    String? secret;
    if (sso) {
      mobile = _mobileController.text.trim();
      secret = _secretController.text.trim();
      if (mobile.isEmpty || secret.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SSO KYC needs mobile number and secret key'),
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KycSdkScreen(
          companyName: company,
          workflow: workflow,
          mobileNumber: mobile,
          secretKey: secret,
          redirectUrl: 'https://www.google.com', //sso ? '' : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'flutter_meon_kyc 2.1.2',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Normal KYC opens the company workflow URL.\n'
            'SSO KYC calls /get_sso_route and opens short_url.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _companyController,
            decoration: const InputDecoration(
              labelText: 'Company name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _workflowController,
            decoration: const InputDecoration(
              labelText: 'Workflow',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Mobile number (SSO only)',
              hintText: '9411441937',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _secretController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Secret key (SSO only)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _openKyc(sso: false),
            child: const Text('Open KYC (Normal)'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => _openKyc(sso: true),
            child: const Text('Open KYC (SSO)'),
          ),
        ],
      ),
    );
  }
}

class KycSdkScreen extends StatelessWidget {
  final String companyName;
  final String workflow;
  final String? mobileNumber;
  final String? secretKey;
  final String? redirectUrl;

  const KycSdkScreen({
    super.key,
    required this.companyName,
    required this.workflow,
    this.mobileNumber,
    this.secretKey,
    this.redirectUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeonKYC(
        companyName: companyName,
        workflow: workflow,
        mobileNumber: mobileNumber,
        secretKey: secretKey,
        redirectUrl: redirectUrl,
        notification: false,
        enablePayments: true,
        autoRequestPermissions: true,
        showHeader: true,
        headerTitle: secretKey != null ? 'SSO KYC Process' : 'KYC Process',
        onSuccess: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('KYC completed successfully')),
          );
          Navigator.of(context).pop();
        },
        onError: (error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $error')));
        },
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
