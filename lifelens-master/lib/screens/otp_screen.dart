import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dashboard.dart';

class OTP extends StatefulWidget {
  static const routeName = '/otp';
  final String verificationID;

  const OTP({super.key,required this.verificationID});

  @override
  _OtpFormState createState() => _OtpFormState();
}

class _OtpFormState extends State<OTP> {
  // Generate 6 controllers for 6 OTP fields
  final _otpControllers = List.generate(6, (index) => TextEditingController());

  final OutlineInputBorder authOutlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: Colors.grey),
  );

  @override
  void initState() {
    super.initState();
    _clearFields();
  }

  void _clearFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      height: 64,
      width: 64,
      child: TextFormField(
        controller: _otpControllers[index],
        onChanged: (pin) {
          if (pin.isNotEmpty && RegExp(r'\d').hasMatch(pin)) {
            if (index < 5) {
              FocusScope.of(context).nextFocus();
            } else {
              FocusScope.of(context).unfocus();
            }
          }
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: "0",
          hintStyle: const TextStyle(color: Color(0xFF757575)),
          border: authOutlineInputBorder,
          enabledBorder: authOutlineInputBorder,
          focusedBorder: authOutlineInputBorder.copyWith(
            borderSide: const BorderSide(color: Color(0xFFFF7643)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OTP Verification',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Image.network(
              "https://i.postimg.cc/nz0YBQcH/Logo-light.png",
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter the 6-digit OTP sent to your email/phone',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => _buildOtpField(index)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final otp = _otpControllers.map((controller) => controller.text).join('');
                if (otp.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
                  );
                  return;
                }

                try {
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: widget.verificationID,
                    smsCode: otp,
                  );

                  // Sign the user in with the credential
                  await FirebaseAuth.instance.signInWithCredential(credential);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Successfully verified!')),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Dashboard()),
                  );
                  // Navigate to the next screen or handle successful verification here.
                } on FirebaseAuthException catch (ex) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${ex.message}')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
