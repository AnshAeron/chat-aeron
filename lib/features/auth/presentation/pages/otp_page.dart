import 'package:flutter/material.dart';

/// OTP Verification Screen
///
/// Allows the user to enter the OTP received on their phone.
///
/// Firebase verification logic will be connected in the next step.
class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

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
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "OTP Verification",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Enter the 6-digit code sent to your phone.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 40),

                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: "OTP",
                      hintText: "Enter OTP",
                      border: OutlineInputBorder(),
                      counterText: "",
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: () {
                        // Verification logic will be added next.
                      },
                      child: const Text("Verify OTP"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      // Resend OTP will be implemented later.
                    },
                    child: const Text("Resend OTP"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
