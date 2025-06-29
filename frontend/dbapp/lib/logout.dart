import 'package:dbapp/api_keys.dart';
import 'package:dbapp/main.dart';
import 'package:flutter/material.dart';

void showLogoutDialog(BuildContext context, String userId, String token) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text("Logout"),
        content: Text("Would you like to log out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close the dialog
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop(); // Close dialog first

              bool success = await LogService().logoutUser(userId, token);

              if (!context.mounted) return; // Check if widget is still mounted

              if (success) {
                await AuthService().clearToken(); // Clear token locally
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TabBarPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed')),
                );
              }
            },
            child: Text("Confirm"),
          ),
        ],
      );
    },
  );
}
