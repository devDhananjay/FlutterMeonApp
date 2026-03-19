import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:meon_face_verification/meon_face_verification.dart';

class FaceSdkLauncher extends StatelessWidget {
  const FaceSdkLauncher({super.key});

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
            MaterialPageRoute(builder: (_) => const FaceSdkScreen()),
          );
        },
        child: const Text('Open Face SDK'),
      ),
    );
  }
}

class FaceSdkScreen extends StatelessWidget {
  const FaceSdkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeonFaceVerification(
        clientId: '330JGFDI3MAAQ1',
        clientSecret: '33034zBrVX0YZOhhYpWzevoU9BydUJ8ILIhNe4C6jNE1',
        onSuccess: (data) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Face verification successful')));
          Navigator.of(context).pop();
        },
        onError: (message) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $message')));
        },
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
