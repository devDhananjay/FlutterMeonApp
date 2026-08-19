import 'package:flutter/material.dart';
import 'package:flutter_meon_rekyc/flutter_meon_rekyc.dart';
import 'package:permission_handler/permission_handler.dart';

class RekycSdkLauncher extends StatelessWidget {
  const RekycSdkLauncher({super.key});

  Future<bool> _requestPermissions(BuildContext context) async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.location,
    ].request();

    if (!context.mounted) return false;

    if (statuses[Permission.camera]?.isGranted != true) {
      _showPermissionDialog(context, 'Camera');
      return false;
    }
    if (statuses[Permission.microphone]?.isGranted != true) {
      if (!context.mounted) return false;
      _showPermissionDialog(context, 'Microphone');
      return false;
    }
    if (statuses[Permission.location]?.isGranted != true) {
      if (!context.mounted) return false;
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
          'This app requires $permission permission for Re-KYC video verification. Please enable it in settings.',
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
            MaterialPageRoute(builder: (_) => const RekycSdkScreen()),
          );
        },
        child: const Text('Open Re-KYC SDK'),
      ),
    );
  }
}

class RekycSdkScreen extends StatelessWidget {
  const RekycSdkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeonReKYC(
        username: 'dhananjay@meon.co.in',
        password: '123456',
        companyId: '1',
        workflowId: '7cd3b329-7b79-46c4-b4f3-abb6664f99f4',
        clientCode: 'meon1',
        baseUrl: 'https://rekyc.meon.co.in',
        showHeader: true,
        headerTitle: 'Re-KYC',
        autoRequestPermissions: true,
        onSuccess: (data) {
          debugPrint('Re-KYC session ready: $data');
        },
        onError: (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Re-KYC error: $error')),
          );
        },
        onClose: () {
          Navigator.of(context).maybePop();
        },
      ),
    );
  }
}
