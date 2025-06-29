
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiService {
  static final String baseUrl = "$apiUrl"; // Replace with your actual backend URL

  // Existing method to get employee profile
  static Future<EmployeeProfile> getEmployeeProfile({
    required String empId,
    required String currentToken,
    String oldToken = "",
  }) async {
    final url = Uri.parse("$baseUrl/getEmpProfile?EmpID=$empId");

    try {
      final response = await http.get(
        url,
        headers: {
          "currentToken": currentToken,
          "oldToken": oldToken,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return EmployeeProfile.fromJson(data);
      } else {
        throw Exception('Failed to load employee profile');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // New method to update employee profile
  static Future<void> updateEmployeeProfile({
    required String empId,
    required String nativePlace,
    required String mobile,
    required String currentToken,
    String oldToken = "", required String email,
  }) async {
    final url = Uri.parse("$baseUrl/updateEmpApp");

    // Prepare the JSON body
    final Map<String, dynamic> body = {
      'EmpID': empId,
      'NativePlace': nativePlace,
      'Mobile': mobile,
      'Email': email,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "currentToken": currentToken,
          "oldToken": oldToken,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Successfully updated
        return;
      } else {
        throw Exception('Failed to update employee profile');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}


class EmployeeProfile {
  final String empId; // Add EmpID
  final String empName;
  final String department;
  final String designation;
  final String dob;
  final String nativePlace;
  final String doj;
  final String mobile;
  final String email;

  EmployeeProfile({
    required this.empId,
    required this.empName,
    required this.department,
    required this.designation,
    required this.dob,
    required this.nativePlace,
    required this.doj,
    required this.mobile,
    required this.email,
  });

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    return EmployeeProfile(
      empId: json['EmpID'] ?? '', // Ensure EmpID is included
      empName: json['EmpName']??'',
      department: json['Department'] ?? '',
      designation: json['Designation']??'',
      dob: json['DOB']??'',
      nativePlace: json['NativePlace'] ?? '',
      doj: json['DOJ']??'',
      mobile: json['Mobile'] ?? '',
      email: json['Email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EmpID': empId,
      'EmpName': empName,
      'Department': department,
      'Designation': designation,
      'DOB': dob,
      'NativePlace': nativePlace,
      'DOJ': doj,
      'Mobile': mobile,
      'Email': email,
    };
  }
}


class EmployeeProfilePage extends StatefulWidget {
  final String empId;
  final String currentToken;
  final String oldToken;

  const EmployeeProfilePage({
    required this.empId,
    required this.currentToken,
    this.oldToken = "",
    Key? key,
  }) : super(key: key);

  @override
  _EmployeeProfilePageState createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  late Future<EmployeeProfile> _employeeProfile;
  late TextEditingController empNameController;
  late TextEditingController departmentController;
  late TextEditingController designationController;
  late TextEditingController dobController;
  late TextEditingController nativePlaceController;
  late TextEditingController dojController;
  late TextEditingController mobileController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    _employeeProfile = ApiService.getEmployeeProfile(
      empId: widget.empId,
      currentToken: widget.currentToken,
      oldToken: widget.oldToken,
    );
  }

  @override
  void dispose() {
    // Dispose controllers to free resources
    empNameController.dispose();
    departmentController.dispose();
    designationController.dispose();
    dobController.dispose();
    nativePlaceController.dispose();
    dojController.dispose();
    mobileController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee Profile"),
      ),
      body: FutureBuilder<EmployeeProfile>(
        future: _employeeProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return Center(child: Text("No profile data available"));
          }

          final profile = snapshot.data!;
          // Initialize controllers with the fetched data
          empNameController = TextEditingController(text: profile.empName);
          departmentController = TextEditingController(text: profile.department);
          designationController = TextEditingController(text: profile.designation);
          dobController = TextEditingController(text: profile.dob);
          nativePlaceController = TextEditingController(text: profile.nativePlace);
          dojController = TextEditingController(text: profile.doj);
          mobileController = TextEditingController(text: profile.mobile);
          emailController = TextEditingController(text: profile.email);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                buildTextField("Name", empNameController, enabled: false),
                buildTextField("Department", departmentController, enabled: false),
                buildTextField("Designation", designationController, enabled: false),
                buildTextField("Date of Birth", dobController, enabled: false),
                buildTextField("Native Place", nativePlaceController),
                buildTextField("Date of Joining", dojController, enabled: false),
                buildTextField("Mobile", mobileController),
                buildTextField("Email", emailController),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateEmployeeProfile, // Call the update method on button press
                  child: Text("Update"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: enabled, // Disable fields that should not be edited
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _updateEmployeeProfile() async {
    // Extract the necessary fields
    final String nativePlace = nativePlaceController.text.trim();
    final String mobile = mobileController.text.trim();
    final String email = emailController.text.trim();

    // Basic validation
    if (nativePlace.isEmpty || mobile.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot be empty")),
      );
      return;
    }

    // Optionally, add more validation (e.g., mobile number format)

    try {
      await ApiService.updateEmployeeProfile(
        empId: widget.empId,
        nativePlace: nativePlace,
        mobile: mobile,
        email: email,
        currentToken: widget.currentToken,
        oldToken: widget.oldToken,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );

      // Optionally, refresh the profile data
      setState(() {
        _employeeProfile = ApiService.getEmployeeProfile(
          empId: widget.empId,
          currentToken: widget.currentToken,
          oldToken: widget.oldToken,
        );
      });
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $error")),
      );
    }
  }
}
