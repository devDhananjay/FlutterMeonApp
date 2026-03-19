import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_meon_kyc/flutter_meon_kyc.dart';

class KycSdkLauncher extends StatelessWidget {
  const KycSdkLauncher({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final granted = await _requestPermissions(context);
          if (!granted || !context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KycSdkScreen()),
          );
        },
        child: const Text('Open KYC SDK'),
      ),
    );
  }
}

class KycSdkScreen extends StatelessWidget {
  const KycSdkScreen({super.key});

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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('KYC completed successfully')));
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
