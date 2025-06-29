import 'dart:convert';
import 'dart:io' show File;
import 'package:dbapp/home.dart';
import 'package:dbapp/model.dart';
import 'package:file_selector/file_selector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class EasyProService {
  static final String baseUrl = '$apiUrl'; // Update with your server address

  // 1. Get Department Names
  static Future<List<Map<String, dynamic>>?> getDepartmentNames() async {
    final url = Uri.parse('$baseUrl/getDepartmentNamesFromEasyProVideo');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        // Convert List<dynamic> to List<Map<String, dynamic>>
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        print('Failed to load department names. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching department names: $e');
      return null;
    }
  }

  // 2. Get EasyPro Video Files by SlNo
  static Future<List<Map<String, dynamic>>?> getEasyProVideoFilesBySlNo(int slNo) async {
    final url = Uri.parse('$baseUrl/getEasyProVideoFilesBySlNo?slNo=$slNo');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        print('Failed to load video files by SlNo. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching video files: $e');
      return null;
    }
  }

  // 3. Get Video Links by SlNo and VideoNo
  static Future<List<Map<String, dynamic>>?> getVideoLinksBySlNoAndVideoNo(int slNo, int videoNo) async {
    final url = Uri.parse('$baseUrl/getVideoLinksBySlNoAndVideoNo?slNo=$slNo&videoNo=$videoNo');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        print('Failed to load video links. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching video links: $e');
      return null;
    }
  }
}


class ForgotPswd {
  static Future<bool> sendOtp(String email) async {
  final url = Uri.parse('$apiUrl/generateOtp?email=$email'); // update with actual server

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      
    );

    return response.statusCode == 200;
  } catch (e) {
    print("Error sending OTP: $e");
    return false;
  }
}


  static Future<bool> resetPassword(String email, String otp, String newPassword) async {
  final url = Uri.parse('$apiUrl/verifyAndResetPassword?email=$email&enteredOtp=$otp&newPassword=$newPassword'); // update with actual server

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
       
      },
      
    );

    return response.statusCode == 200;
  } catch (e) {
    print("Error resetting password: $e");
    return false;
  }
}

  
}


class TaskService {
  
  static Future<List<Task>> fetchTasks(String token, String empID) async {
    final response = await http.get(
      Uri.parse('$apiUrl/getprojecttaskbasedElevel?empId=$empID'),
      headers: {
        'currentToken': token, // Include the token in the headers
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Task> tasks =
          body.map((dynamic item) => Task.fromJson(item)).toList();
          print(tasks);
      return tasks;
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  static Future<List<Task>> fetchSubTasks(String token) async {
    final response = await http.get(
      Uri.parse('$apiUrl/getprojecttask'),
      headers: {
        'currentToken': token, // Include the token in the headers
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Task> tasks =
          body.map((dynamic item) => Task.fromJson(item)).toList();
      return tasks;
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  static Future<Map<String, List<dynamic>>> fetchDropdownData(
      String token) async {
    final response = await http.get(
      Uri.parse(
          '$apiUrl/getProjTaskSpinnersData'), // Replace with your API URL
      headers: {
        'currentToken': token,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Parse the response as a List<dynamic>
      List<dynamic> body = jsonDecode(response.body);

      // Extract the data from the first item in the list
      Map<String, dynamic> firstItem = body[0];

      // Parse projects, employees, and task types
      List<Project> projects = (firstItem['Proj'] as List)
          .map((item) => Project.fromJson(item))
          .toList();
      List<Employee> employees = (firstItem['Assign'] as List)
          .map((item) => Employee.fromJson(item))
          .toList();
      List<TaskType> taskTypes = (firstItem['TaskType'] as List)
          .map((item) => TaskType.fromJson(item))
          .toList();

      return {
        'projects': projects,
        'employees': employees,
        'taskTypes': taskTypes,
      };
    } else {
      throw Exception('Failed to load dropdown data');
    }
  }

  static Future<void> saveTask(String token, TaskDetails task) async {
  final uri = Uri.parse('$apiUrl/addProjTasks');
  final request = http.MultipartRequest('POST', uri)
    ..headers['currentToken'] = token
    ..fields['pid'] = task.projectId
    ..fields['ttype'] = task.taskType
    ..fields['tdesc'] = task.taskDesc
    ..fields['sdate'] = task.startDate
    ..fields['edate'] = task.endDate
    ..fields['ato'] = task.assignedTo
    ..fields['cby'] = task.createdBy;

  // If file is selected, add it to the request
  if (task.file != null) {
    final file = await http.MultipartFile.fromPath(
      'file',
      task.file!.path,
    );
    request.files.add(file);
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  print("Fields: ${request.fields}");
  print("File: ${task.file?.path}");
  print("Response: ${response.body}");
  print("Status: ${response.statusCode}");

  if (response.statusCode != 200) {
    throw Exception('Failed to save task: ${response.body}');
  }
}


  static Future<void> UpdateTask(String token, TaskDetails task, {File? file}) async {
  try {
    var uri = Uri.parse('$apiUrl/updateProjTasks');
    var request = http.MultipartRequest("POST", uri);

    // Add headers
    request.headers['currentToken'] = token;

    // Add fields
    request.fields['tid'] = task.taskId.toString();
    request.fields['pid'] = task.projectId.toString();
    request.fields['ttype'] = task.taskType.trim();
    request.fields['tdesc'] = task.taskDesc;
    request.fields['sdate'] = task.startDate;
    request.fields['edate'] = task.endDate;
    request.fields['ato'] = task.assignedTo;
    request.fields['cby'] = task.createdBy;

    // Add file if provided
    if (file != null && await file.exists()) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    // Send request
    var streamedResponse = await request.send();

    // Read response
    final response = await http.Response.fromStream(streamedResponse);

    print('Request Fields: ${request.fields}');
    print('File: ${file?.path}');
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update task: ${response.body}');
    }
  } catch (e) {
    print('Error updating task: $e');
    throw Exception('Failed to update task due to an error');
  }
}


  static Future<void> deleteProject(
      String token, String pid, String tid) async {
    // Ensure the parameters are properly encoded to avoid issues with special characters

    final url = Uri.parse(
        '$apiUrl/deleteProjectTask?pid=$pid&taskid=$tid');

    print('Request URL: $url'); // Log the URL

    try {
      final response = await http.delete(
        url,
        headers: {
          'currentToken': token,
          'Content-Type': 'application/json', // Pass the currentToken header
        },
      );

      if (response.statusCode == 200) {
        print('Project with PID: $pid deleted successfully');
      } else {
        print('Error Response Body: ${response.body}');
        throw Exception(
            'Failed to delete project. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Log the error and rethrow it with additional context
      print('Error occurred while deleting project: $error');
      throw Exception('Error deleting project: $error');
    }
  }
}

class PasswordChangeService {
  final String baseUrl = "$apiUrl"; // API Base URL

  /// Fetches the current password for validation
  Future<String?> getCurrentPassword(String empID, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getCurrentPass?UserID=$empID'),
        headers: {
          'currentToken': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["CurrentPassword"]; // Extract the password string
      } else {
        print("Failed to get password. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching password: $e");
      return null;
    }
  }

  /// Updates the password after validation
  Future<bool> updatePassword({
    required String empID,
    required String token,
    required String currentPassword,
    required String newPassword,
    required String utype,
  }) async {
    try {
      // 1️⃣ Get the current password
      String? storedPassword = await getCurrentPassword(empID, token);

      if (storedPassword == null) {
        print("Could not fetch current password.");
        return false;
      }

      // 2️⃣ Compare passwords
      if (storedPassword != currentPassword) {
        print("Current password does not match.");
        return false;
      }

      // 3️⃣ Send API request to update password
      final response = await http.post(
        Uri.parse('$baseUrl/updatePassword'),
        headers: {
          'currentToken': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'Pwd': newPassword,
          'UserID': empID,
          'UType': utype,
        }),
      );

      if (response.statusCode == 200) {
        print("Password updated successfully.");
        return true;
      } else {
        print("Failed to update password. Response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error updating password: $e");
      return false;
    }
  }
}

class DropdownService {
  Future<Map<String, List<Map<String, String>>>> fetchDropdownData(
      String empID, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/getEmpWSSpinnersData?EmpID=$empID'),
        headers: {
          'currentToken': token,
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return {
          "projects": (data[0]['Proj'] as List).map((item) {
            return {
              "sCode": item['sCode'].toString(),
              "sDesc": item['sDesc'].toString(),
            };
          }).toList(),
          "workTypes": (data[0]['WorkType'] as List).map((item) {
            return {
              "sCode": item['sCode'].toString(),
              "sDesc": item['sDesc'].toString(),
            };
          }).toList(),
        };
      }
    } catch (e) {
      print("Error fetching dropdown data: $e");
    }
    return {"projects": [], "workTypes": []};
  }

static Future<bool> addTaskWithSubtasks({
  required String empId,
  required String workDate,
  required String workType,
  required String projectId,
  required String taskDescription,
  required List<Map<String, String>> subTasks,
  required String token,
  String? taskId,
  int? taskPercentage,
  XFile? attachmentFile, // 👈 optional file param
}) async {
  try {
    // STEP 1: First add the worksheet entry
    final url = Uri.parse("$apiUrl/addEmpWS");

    Map<String, dynamic> workSection = {
      "empid": empId,
      "wdate": workDate,
      "wtype": workType,
      "pid": projectId,
      "desc": taskDescription,
    };

    if (taskId != null) workSection["tid"] = taskId;
    if (taskPercentage != null) workSection["tper"] = taskPercentage;

    Map<String, dynamic> requestBody = {
      "Work": workSection,
      "WorkItems": subTasks,
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "currentToken": token,
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      print("Error adding task: ${response.body}");
      return false;
    }
  final wsid = jsonDecode(response.body);
    // STEP 2: Then upload the file if present
    if (attachmentFile != null) {
  final uploadUrl = Uri.parse("$apiUrl/WStaskupload");

  var request = http.MultipartRequest("POST", uploadUrl);
  request.headers["currentToken"] = token;
  request.fields["WSID"] = wsid.toString(); // 👈 now you have it
  // REQUIRED fields expected by your backend
  request.fields["pid"] = projectId;
  request.fields["taskid"] = taskId ?? "";

  // Correct file field name
  request.files.add(await http.MultipartFile.fromPath(
    'file', // must match @RequestParam("file")
    attachmentFile.path,
    // contentType optional
  ));

      final uploadResponse = await request.send();

      if (uploadResponse.statusCode != 200) {
        print("File upload failed: ${uploadResponse.statusCode}");
        return false;
      } else {
        print("File uploaded successfully.");
      }
    }

    return true;
  } catch (e) {
    print("Exception in addTaskWithSubtasks: $e");
    return false;
  }
}

  Future<List<Map<String, dynamic>>> fetchProjTasks(String projectId, String token) async {
  final response = await http.get(
    Uri.parse('$apiUrl/getTasks?pid=$projectId'),
    headers: {
        "Content-Type": "application/json",
        "currentToken": token,
      },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data);
  } else {
    throw Exception("Failed to fetch project tasks");
  }
}


}

class HomeService {
  static Future<List<Map<String, dynamic>>> getTasksByEmpId(
      String token,  String projectid, String userId, ) async {
        
    final Uri url =
        Uri.parse("$apiUrl/getTasksByEmpIdAndProjectId?UserID=$userId&projectID=$projectid");
        print("Fetching tasks...");
print("URL: $url");
print("UserID: $userId");
print("ProjectID: $projectid");
print("Token: $token");


    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "currentToken": token,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception("Failed to fetch tasks: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching tasks: $e");
    }
  }
  Future<List<Map<String, dynamic>>> getWorksheetChart(
    String userID, String token) async {
  final url =
      Uri.parse('$apiUrl/getWorksheetChart?UserID=$userID');
  try {
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "currentToken": token,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load chart');
    }
  } catch (error) {
    throw Exception('Error occurred: $error');
  }
}



Future<List<Map<String, dynamic>>> fetchPendingTasks(
    String userID, String token) async {
  final url =
      Uri.parse('$apiUrl/getPendingTasks?UserID=$userID');
  try {
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "currentToken": token,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load pending tasks');
    }
  } catch (error) {
    throw Exception('Error occurred: $error');
  }
}

Future<List<LeaveApproval>> fetchLeaveApprovalDetails(
    String userID, String token) async {
  final response = await http.get(
    Uri.parse('$apiUrl/getEmployeePending?EmpID=$userID'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 200) {
    print("Response Body: ${response.body}");
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => LeaveApproval.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load leave approvals');
  }
}
}

class LeaveService {
  static Future<List<LeaveApproval>> fetchLeave(
      String token, String empID) async {
    final response = await http.get(
      Uri.parse('$apiUrl/getEmployeePending?EmpID=$empID'),
      headers: {
        'currentToken': token, // Include the token in the headers
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<LeaveApproval> leaves =
          body.map((dynamic item) => LeaveApproval.fromJson(item)).toList();
      return leaves;
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  static Future<bool> updateLeaveRequest({
    required String token,
    required String empID,
    required String fromDate,
    required String toDate,
    required String reason,
    required String note,
    required String approver,
  }) async {
    try {
      // Prepare the request body as JSON
      Map<String, dynamic> requestBody = {
        'empid': empID,
        'fromdate': fromDate,
        'todate': toDate,
        'reason': reason,
        'note': note,
        'approver': approver,
      };

      // Send HTTP PUT request to update leave
      final response = await http.put(
        Uri.parse('$apiUrl/updateEmployeeLeave'),
        headers: {
          'currentToken': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        return true; // Success
      } else {
        throw Exception('Failed to update leave request');
      }
    } catch (e) {
      print("Error: $e");
      return false; // Error
    }
  }

  static Future<List<Map<String, dynamic>>> getApprovers(String token, String empID) async {
    final url = Uri.parse("$apiUrl/getApprovers?empId=$empID");

    try {
      final response = await http.get(
        url,
        headers: {
          "currentToken": token, // Replace with actual token if needed
          'Content-Type': 'application/json', // Replace if needed
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data
            .map((approver) => {
                  "empid": approver["empid"],
                  "empname": approver["empname"],
                })
            .toList();
      } else {
        throw Exception("Failed to load approvers");
      }
    } catch (e) {
      print("Error fetching approvers: $e");
      return [];
    }
  }

  // Replace with your backend URL

  // Method to add a leave request
  static Future<bool> addLeaveRequest({
    required String token,
    required String empID,
    required String fromDate,
    required String toDate,
    required String reason,
    required String note,
    required String approverID, // Use approver ID instead of approver name
  }) async {
    try {
      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'empid': empID,
        'fromdate': fromDate,
        'todate': toDate,
        'reason': reason,
        'note': note,
        'approver': approverID, // Pass approver ID
      };

      // Send the POST request to the backend API
      final response = await http.post(
        Uri.parse(
            '$apiUrl/addEmployeeLeave'), // Replace with your API endpoint
        headers: {
          "currentToken": token, // Replace with actual token if needed
          'Content-Type': 'application/json', // Replace if needed
        },
        body: jsonEncode(requestBody),
      );
      print(requestBody);
      // Check if the request was successful
      if (response.statusCode == 200) {
        return true; // Leave request added successfully
      } else {
        // Handle errors
        print('Failed to add leave request: ${response.body}');
        return false;
      }
    } catch (e) {
      // Handle exceptions
      print('Error adding leave request: $e');
      return false;
    }
  }

  static Future<void> deleteRequest(
      String token, String empID, String fromDate) async {
    // Ensure the parameters are properly encoded to avoid issues with special characters

    final url = Uri.parse(
        '$apiUrl/deleteEmployeeLeave?EmpID=$empID&FromDate=$fromDate');

    print('Request URL: $url'); // Log the URL

    try {
      final response = await http.delete(
        url,
        headers: {
          'currentToken': token,
          'Content-Type': 'application/json', // Pass the currentToken header
        },
      );

      if (response.statusCode == 200) {
        print('Leave request deleted successfully');
      } else {
        print('Error Response Body: ${response.body}');
        throw Exception(
            'Failed to delete leave request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Log the error and rethrow it with additional context
      print('Error occurred while deleting request: $error');
      throw Exception('Error deleting request: $error');
    }
  }
static Future<bool> approveLeaveRequest({
  required String token,
  required String approverID,
  required String empID,
  required String fromDate,
}) async {
  final response = await http.post(
    Uri.parse('$apiUrl/approveLeaveRequest'),
    headers: {
          "currentToken": token, // Replace with actual token if needed
          
        },
    body: {
      'empId': empID,
      'fromDate': fromDate,
      'approverId': approverID,
    },
  );
  return response.statusCode == 200;
}

static Future<List<LeaveApproval>> getCurrentlyOnLeave(String token) async {
  final response = await http.get(
    Uri.parse('$apiUrl/getEmployeesOnLeaveToday'),
    headers: {
          "currentToken": token, // Replace with actual token if needed
          
        },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => LeaveApproval.fromJson(json)).toList();
  } else {
    return [];
  }
}



}



class AuthService {
  static final String baseUrl = '$apiUrl';

  // Fetch the static API key token from backend and save locally
  Future<String> fetchAndSaveToken() async {
    final url = Uri.parse('$baseUrl/getToken');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final token = response.body.trim(); // Expecting plain text like "token"
        await saveToken(token);
        print('Fetched and saved token: $token');
        return token;
      } else {
        print('Failed to fetch token: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      print('Error fetching token: $e');
      return '';
    }
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('currentToken') ?? '';
  }

  Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('currentToken');
  print('Token cleared locally.');
}


  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentToken', token);
    print('Token saved: $token');
  }

  Future<void> login(BuildContext context, String userId, String password) async {
    String token = await getToken();

    if (token.isEmpty) {
      // Fetch token from backend if not saved locally
      token = await fetchAndSaveToken();

      if (token.isEmpty) {
        print('Cannot login without a token');
        return;
      }
    }

    final url = Uri.parse('$baseUrl/getUserInfo').replace(queryParameters: {
      'userid': userId,
      'password': password,
    });

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'currentToken': token,
        },
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('Login successful: $data');

        final empName = data['EmpName'] ?? 'Unknown';
        final empID = data['EmpID'] ?? '0';
        final utype = data['UType'] ?? 'user';

        // Navigate to Home screen with retrieved data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(
              empID: empID,
              empName: empName,
              token: token,
              utype: utype,
              homeService: HomeService(),
            ),
          ),
        );

        // If backend sends a new token (optional)
        if (data['token'] != null && data['token'] != token) {
          await saveToken(data['token']);
          print('New token saved: ${data['token']}');
        }
      } else {
        print('Login failed: ${response.statusCode}, ${response.body}');
        // Optionally show error dialog/snackbar here
      }
    } catch (e) {
      print('Login request failed: $e');
      // Optionally show error dialog/snackbar here
    }
  }
}



class CustomerService {
  final String token;

  CustomerService({required this.token});

  Future<List<Customer>> fetchCustomerData() async {
    final response = await http.get(
      Uri.parse('$apiUrl/getCustomerMaster'),
      headers: {'currentToken': token},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Customer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load customer details');
    }
  }

  Future<void> addNewCustomer(Map<String, String> customerData) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/addCustomerMaster'),
        headers: {
          'currentToken': token,
          'Content-Type': 'application/json',
        },
        body: json.encode(customerData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add customer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> updateCustomerData(
      Customer customer, Map<String, String> updatedData) async {
        updatedData['cuscode'] = customer.cuscode;
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/updateCustomerMaster'),
        headers: {
          'currentToken': token,
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update customer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteCustomer(String cuscode) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/deleteCustomer?cuscode=$cuscode'),
        headers: {'currentToken': token},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete customer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting customer: $e');
    }
  }
}

class ApiService {
  final String token;

  ApiService({required this.token});
  static final String baseUrl = "$apiUrl";
  



  Future<List<Map<String, String>>> getAccessibleEmployees(String empId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/getAccessibleEmployees?empid=$empId'),
    headers: {
      'currentToken': token,
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => {
      'EmpID': item['EmpID'].toString(),
      'EmpName': item['EmpName'].toString(),
    }).toList();
  } else {
    throw Exception("Failed to load employees");
  }
}

  Future<DateTime> getDOJOfEmployee(String empId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/getDOJOfEmployee?selectedEmpId=$empId'),
    headers: {
      'currentToken': token,
      'Content-Type': 'application/json',
    },
  );

    if (response.statusCode == 200) {
    final dojStr = response.body.replaceAll('"', '').trim(); // remove quotes if any
    return DateTime.parse(dojStr); // "2024-03-18"
  } else {
    throw Exception("Failed to fetch DOJ");
  }
}


  int getMonthNumber(String monthName) {
  const Map<String, int> monthMap = {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 10,
    'Nov': 11,
    'Dec': 12,
  };
  return monthMap[monthName] ?? -1; // -1 for invalid input
}

Future<List<WorkDate>> getWorkList(String userId, String wMonth, String wYear) async {
  int numericMonth = getMonthNumber(wMonth);
  if (numericMonth == -1) {
    throw Exception("Invalid month name: $wMonth");
  }
  print(numericMonth);
  print(wYear);
  final response = await http.get(
    Uri.parse('$baseUrl/getWSList?UserID=$userId&WMonth=$numericMonth&WYear=$wYear'),
    headers: {
      'currentToken': token,
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => WorkDate.fromJson(item)).toList();
  } else {
    throw Exception("Failed to load work data");
  }
}

Future<String> getEmpAttViewList(String userId, int wMonth, String wYear) async {
  
 
  print(wYear);
  final response = await http.get(
    Uri.parse('$baseUrl/getEmpAttViewList?UserID=$userId&WMonth=$wMonth&WYear=$wYear'),
    headers: {
      'currentToken': token,
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
      print("API Raw Response: ${response.body}"); // Debugging
    return response.body; 
    } else {
    throw Exception("Failed to load work data");
  }
}

}

class LogService {
  Future<bool> logoutUser(String userId, String token) async {
    final String baseUrl = "$apiUrl/setTokenNull";

    try {
      final response = await http.get(
        Uri.parse("$baseUrl?userid=$userId"),
        headers: {
          'currentToken': token,
        },
      );

      if (response.statusCode == 200) {
        print("Logout successful");
        return true;
      } else {
        print("Failed to log out: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error logging out: $e");
      return false;
    }
  }
}



class NotificationService {
  static Future<void> saveToken(String empId, String token) async {
    final fcmtoken = await FirebaseMessaging.instance.getToken();
    print('fcm token $fcmtoken');
    if (fcmtoken == null) return;

    final response = await http.post(
      Uri.parse('$apiUrl/saveFcmToken?empId=$empId&fcmtoken=$fcmtoken'),
      headers: {
        'Content-Type': 'application/json',
        'currentToken': token,
      },
    );

    if (response.statusCode == 200) {
      print('FCM token saved: ${response.body}');
    } else {
      print('Failed to save FCM token: ${response.statusCode}');
      throw Exception("Failed to save token");
    }
  }
}


class AttendanceService {
  static final String _baseUrl = '$apiUrl';

  static Future<String> markAttendance({
    required String empId,
    required String currentToken,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/markAttendance'),
        headers: {'currentToken': currentToken},
        body: {
          'empID': empId,
          'lat': lat.toString(),
          'lng': lng.toString(),
        },
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'Attendance not marked. Already submitted or error occurred.';
      }
    } catch (e) {
      return 'Failed to contact server';
    }
  }
}

