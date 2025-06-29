import 'package:dbapp/api_keys.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'config.dart';

class AttendanceButton extends StatelessWidget {
  final String empId;
  final String currentToken;

  const AttendanceButton({
    super.key,
    required this.empId,
    required this.currentToken,
  });

  Future<void> _handleAttendance(BuildContext context) async {
    final status = await perm.Permission.location.request();
    if (!status.isGranted) {
      _showMessage(context, 'Location permission required');
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      _showMessage(context, 'Please enable location services');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final result = await AttendanceService.markAttendance(
        empId: empId,
        currentToken: currentToken,
        lat: position.latitude,
        lng: position.longitude,
      );

      _showMessage(context, result);
    } catch (e) {
      _showMessage(context, 'Error: ${e.toString().replaceAll("Exception: ", "")}');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: FloatingActionButton.large(
          onPressed: () => _handleAttendance(context),
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.fingerprint, size: 40, color: Colors.blue.shade800),
        ),
      ),
    );
  }
}



class EmployeeAttendancePage extends StatefulWidget {
  final String empID;
  final String currentToken;
  final String oldToken;

  EmployeeAttendancePage({
    required this.empID,
    required this.currentToken,
    required this.oldToken,
  });

  @override
  _EmployeeAttendancePageState createState() => _EmployeeAttendancePageState();
}

class _EmployeeAttendancePageState extends State<EmployeeAttendancePage> {
  late Future<Map<String, List<Map<String, String>>>> attendanceData;

  @override
  void initState() {
    super.initState();
    attendanceData = fetchEmployeeAttendance();
  }

  Future<Map<String, List<Map<String, String>>>>
      fetchEmployeeAttendance() async {
    final response = await http.get(
      Uri.parse(
          '$apiUrl/getEmployeeAttendance?EmpID=${widget.empID}'),
      headers: {
        'currentToken': widget.currentToken,
        'oldToken': widget.oldToken,
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      final data = jsonDecode(response.body) as List<dynamic>;
      Map<String, List<Map<String, String>>> groupedData = {};

      for (var entry in data) {
        final month = entry['Month'] as String?; // Nullable type for 'Month'
        if (month != null) {
          // Only process if month is not null
          groupedData.putIfAbsent(month, () => []).add({
            'Date': entry['Datein'] as String? ??
                '', // Default to empty string if null
            'Day': entry['DayName'] as String? ??
                '', // Default to empty string if null
            'InTime': entry['InTime'] as String? ??
                '', // Default to empty string if null
            'OutTime': entry['OutTime'] as String? ??
                '', // Default to empty string if null
            'Hours': entry['TotalHours'] as String? ??
                '', // Default to empty string if null
          });
        }
      }

      return groupedData;
    } else {
      throw Exception('Failed to load attendance data');
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Attendance'),
    ),
    body: FutureBuilder<Map<String, List<Map<String, String>>>>(
      future: attendanceData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No attendance data found.'));
        } else {
          final Map<String, List<Map<String, String>>> groupedData = snapshot.data!;

          return Column(
            children: [
              // 🔒 Display attendance button ONCE at the top center
              Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom:5.0),
                child: Center(
                  child: AttendanceButton(
                    empId: widget.empID,
                    currentToken: widget.currentToken,
                  ),
                ),
              ),
              // 🧾 Attendance list
              Expanded(
                child: ListView.builder(
                  itemCount: groupedData.keys.length,
                  itemBuilder: (context, index) {
                    final month = groupedData.keys.elementAt(index);
                    final records = groupedData[month]!;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              month,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Day')),
                                DataColumn(label: Text('In Time')),
                                DataColumn(label: Text('Out Time')),
                                DataColumn(label: Text('Hours')),
                              ],
                              rows: records.map((record) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(record['Date']!)),
                                    DataCell(Text(record['Day']!)),
                                    DataCell(Text(record['InTime']!)),
                                    DataCell(Text(record['OutTime']!)),
                                    DataCell(Text(record['Hours']!)),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    ),
  );
}

}
