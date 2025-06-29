import 'package:dbapp/api_keys.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String token;
  final String empID;
  final PasswordChangeService service;
  final String utype;

  const ChangePasswordScreen({required this.token, required this.empID, required this.service, required this.utype, Key? key})
      : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController currentController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  void _updatePassword() async {
  if (newController.text != confirmController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("New passwords do not match")),
    );
    return;
  }

  // Show loading indicator (optional)
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Updating password...")),
  );

  bool success = await widget.service.updatePassword(
    empID: widget.empID,
    token: widget.token,
    currentPassword: currentController.text,
    newPassword: newController.text,
    utype: widget.utype,
  );

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password updated successfully!")),
    );
    // Clear text fields after successful update
    currentController.clear();
    newController.clear();
    confirmController.clear();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to update password. Please try again.")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              PasswordField(controller: currentController, hintText: "Current Password"),
              const SizedBox(height: 20),
              PasswordField(controller: newController, hintText: "New Password"),
              const SizedBox(height: 20),
              PasswordField(controller: confirmController, hintText: "Confirm Password"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePassword,
                child: const Text("Update", style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const PasswordField({required this.controller, required this.hintText, Key? key}) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: const UnderlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }
}
