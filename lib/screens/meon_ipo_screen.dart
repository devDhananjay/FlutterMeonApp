import 'package:flutter/material.dart';
import 'package:flutter_meon_ipo/flutter_meon_ipo.dart';

class MeonIPOScreen extends StatelessWidget {
  const MeonIPOScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meon IPO'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: MeonIPO(
        companyName: 'ndaindia',
        onLoadStart: () {
          print('🚀 IPO WebView loading started');
        },
        onLoadEnd: () {
          print('✅ IPO WebView loading finished');
        },
        onError: (error) {
          print('❌ IPO WebView Error: ${error.description}');
        },
        onProgress: (progress) {
          print('📊 IPO Loading progress: $progress%');
        },
        backgroundColor: Colors.grey[50],
      ),
    );
  }
}
