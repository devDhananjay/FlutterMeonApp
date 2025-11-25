import 'package:flutter/material.dart';
import 'package:flutter_digilocker_aadhar_pan/flutter_digilocker_aadhar_pan.dart';

// Screen 2: Aadhar & Pan API Screen (Full Screen)
class AadharPanScreen extends StatefulWidget {
  const AadharPanScreen({super.key});

  @override
  AadharPanScreenState createState() => AadharPanScreenState();
}

class AadharPanScreenState extends State<AadharPanScreen> {
  bool _showDigiLocker = false;
  DigiLockerResponse? _response;

  final config = const DigiLockerConfig(
    companyName: 'democapital',
    secretToken: 'cy7Kw2rWqdzVo2KPxlU0ymd9uRQKPSsb',
    redirectUrl: 'https://your-redirect-url.com',
    documents: 'aadhaar,pan',
    panName: '',
    panNo: '',
  );

  void _handleSuccess(DigiLockerResponse response) {
    setState(() {
      _response = response;
      _showDigiLocker = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Verification Successful!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    print('DigiLocker Success: ${response.toJson()}');
    print('Name: ${response.data?.name}');
    print('Aadhar: ${response.data?.aadharNo}');
    print('PAN: ${response.data?.panNumber}');
  }

  void _handleError(String error) {
    setState(() {
      _showDigiLocker = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Error: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );

    print('DigiLocker Error: $error');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DigiLocker Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.credit_card,
                  size: 100,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 30),
                const Text(
                  'DigiLocker Verification',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Verify your Aadhar and PAN using DigiLocker',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                
                if (_response != null) ...[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 30),
                              SizedBox(width: 10),
                              Text(
                                'Verification Complete',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildInfoRow('Name', _response!.data?.name ?? 'N/A'),
                          const SizedBox(height: 12),
                          _buildInfoRow('Aadhar Number', _response!.data?.aadharNo ?? 'N/A'),
                          const SizedBox(height: 12),
                          _buildInfoRow('PAN Number', _response!.data?.panNumber ?? 'N/A'),
                          if (_response!.data?.dob != null) ...[
                            const SizedBox(height: 12),
                            _buildInfoRow('Date of Birth', _response!.data?.dob ?? 'N/A'),
                          ],
                          if (_response!.data?.gender != null) ...[
                            const SizedBox(height: 12),
                            _buildInfoRow('Gender', _response!.data?.gender ?? 'N/A'),
                          ],
                          if (_response!.data?.aadharAddress != null) ...[
                            const SizedBox(height: 12),
                            _buildInfoRow('Address', _response!.data?.aadharAddress ?? 'N/A'),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
                
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showDigiLocker = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Start DigiLocker Verification',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Note: Make sure to configure your DigiLocker credentials in the code.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          if (_showDigiLocker)
            DigiLockerWidget(
              config: config,
              onSuccess: _handleSuccess,
              onError: _handleError,
              onClose: () {
                setState(() {
                  _showDigiLocker = false;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[900],
            ),
          ),
        ),
      ],
    );
  }
}

