import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigacharge/src/swap/swap_confirmation.dart';

class SwapPage extends StatefulWidget {
  const SwapPage({super.key});

  @override
  _SwapPageState createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  final _otpController = TextEditingController();
  String _otp = '';

  void _submitOTP() {
    if (_otp.length == 6) {
      // Here you can verify the OTP, for example, with Firebase or your own backend.
      // print('OTP Submitted: $_otp');
      // After successful OTP, navigate to the Swap confirmation page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SwapConfirmationPage()),
      );
    } else {
      // Handle invalid OTP (e.g., show a dialog or error message)
      // print('Invalid OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter OTP'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
                child: Text(
              'To confirm swap, please enter an OTP. Once received your charger is reserved for 15 minutes.',
              style: TextStyle(fontSize: 20),
            )),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              onChanged: (value) {
                setState(() {
                  _otp = value;
                });
              },
              keyboardType: TextInputType.number,
              maxLength: 6,
              // Assuming OTP length is 6
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                hintText: '6 digits',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: _submitOTP,
              child: const Text('Confirm Swap'),
            ),
          ],
        ),
      ),
    );
  }
}
