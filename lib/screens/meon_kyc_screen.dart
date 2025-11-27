import 'package:flutter/material.dart';
import 'package:flutter_meon_kyc/flutter_meon_kyc.dart';

/// Screen 3: Meon KYC Package Screen (Full Screen)
class MeonKYCScreen extends StatelessWidget {
  const MeonKYCScreen({super.key});

  void _showSnack(BuildContext context, String message,
      {Color background = Colors.blueGrey}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: background,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meon KYC SDK'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Navigator.of(context).pop,
        ),
      ),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Color(0xFFF5F7FB)),
          child: MeonKYC(
            companyName:
                'democapital', // TODO: Replace with your actual company code
            workflow: 'sdk_test', // TODO: Replace with your workflow slug
            baseURL:
                'https://live.meon.co.in', // Point to the same cluster you use elsewhere
            enableIPV: true,
            enablePayments: true,
            autoRequestPermissions: true,
            enableCameraPermission: true,
            enableMicrophonePermission: true,
            enableLocationPermission: true,
            showHeader: true,
            headerTitle: 'Complete Your KYC',
            customStyles: {
              'container': const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              'header': BoxDecoration(
                color: Colors.indigo.shade600,
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 6,
                    color: Colors.black12,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              'headerTitle': const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            },
            onSuccess: (data) async {
              final timestamp = data['timestamp'] ?? DateTime.now().toString();
              await showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('KYC Completed 🎉'),
                  content: Text(
                    'Status: ${data['status'] ?? 'completed'}\n'
                    'Message: ${data['message'] ?? 'Journey finished'}\n'
                    'Time: $timestamp',
                  ),
                  actions: [
                    TextButton(
                      onPressed: Navigator.of(context).pop,
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              );
              Navigator.of(context).pop(data);
            },
            onError: (error) {
              _showSnack(
                context,
                'KYC error: $error',
                background: Colors.redAccent,
              );
            },
            onClose: () {
              _showSnack(context, 'KYC flow closed by user');
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}