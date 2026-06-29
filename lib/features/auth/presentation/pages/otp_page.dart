import 'package:flutter/material.dart';

/// OTP Verification Screen
///
/// Receives the Firebase verificationId from the Login screen.
class OtpPage extends StatefulWidget {
  final String verificationId;

  const OtpPage({super.key, required this.verificationId});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),

              Icon(
                Icons.lock_outline,
                size: 80,
                color: theme.colorScheme.primary,
              ),

              const SizedBox(height: 20),

              Text(
                "OTP Verification",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),

              const SizedBox(height: 10),

              const Text(
                "Enter the 6-digit code sent to your phone.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: "OTP",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              FilledButton(
                onPressed: () {
                  // We'll connect Firebase verification next.
                  debugPrint(widget.verificationId);
                  debugPrint(_otpController.text);
                },
                child: const Text("Verify OTP"),
              ),

              const SizedBox(height: 16),

              TextButton(onPressed: () {}, child: const Text("Resend OTP")),
            ],
          ),
        ),
      ),
    );
  }
}
