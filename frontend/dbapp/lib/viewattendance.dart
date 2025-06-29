import 'dart:convert';
import 'package:flutter/material.dart';
import 'api_keys.dart';
import 'model.dart';

class AttendanceView extends StatefulWidget {
  final String token;
  final String empID;

  const AttendanceView({required this.token, required this.empID, Key? key}) : super(key: key);

  @override
  _AttendanceViewState createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  String? selectedEmpId;
  String? selectedEmpName;
  int? selectedMonth;
  int? selectedYear;
  List<Map<String, String>> employees = [];
  List<AttendanceData> attData = [];

  List<String> monthNames = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];

  List<int> yearList = [];

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      final empList = await ApiService(token: widget.token).getAccessibleEmployees(widget.empID);
      if (empList.isNotEmpty) {
        setState(() {
          employees = empList;
          selectedEmpId = empList[0]['EmpID'];
          selectedEmpName = empList[0]['EmpName'];
        });
        await fetchDOJAndSetupYears(); // set yearList after getting DOJ
      }
    } catch (e) {
      print("Error fetching employees: $e");
    }
  }

  Future<void> fetchDOJAndSetupYears() async {
    if (selectedEmpId == null) return;
    try {
      final doj = await ApiService(token: widget.token).getDOJOfEmployee(selectedEmpId!);
      final now = DateTime.now();

      // Build year list from DOJ.year to current year
      setState(() {
        yearList = List.generate(now.year - doj.year + 1, (i) => doj.year + i);
        selectedYear = now.year;
        selectedMonth = now.month;
      });

      fetchAttendanceData(selectedMonth!, selectedYear!.toString());
    } catch (e) {
      print("Error fetching DOJ: $e");
    }
  }

  Future<void> fetchAttendanceData(int month, String year) async {
    if (selectedEmpId == null) return;
    try {
      final response = await ApiService(token: widget.token)
          .getEmpAttViewList(selectedEmpId!, month, year);
      final jsonData = jsonDecode(response);
      final parsedData = AttendanceData.fromJsonList(jsonData);

      setState(() {
        attData = parsedData;
      });
      print("Loaded ${attData.length} attendance records.");
    } catch (e) {
      print("Error fetching attendance data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance View")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedEmpId,
                    hint: const Text("Select Employee"),
                    isExpanded: true,
                    items: employees.map((emp) {
                      return DropdownMenuItem<String>(
                        value: emp['EmpID'],
                        child: Text(emp['EmpName']!),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() {
                        selectedEmpId = value;
                        selectedEmpName = employees.firstWhere((e) => e['EmpID'] == value)['EmpName'];
                        attData.clear();
                        selectedMonth = null;
                        selectedYear = null;
                        yearList = [];
                      });
                      await fetchDOJAndSetupYears();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedYear,
                    hint: const Text("Select Year"),
                    isExpanded: true,
                    items: yearList.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() {
                        selectedYear = value;
                      });
                      if (selectedMonth != null) {
                        await fetchAttendanceData(selectedMonth!, selectedYear!.toString());
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    hint: const Text("Select Month"),
                    isExpanded: true,
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(monthNames[index]),
                      );
                    }),
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() {
                        selectedMonth = value;
                      });
                      if (selectedYear != null) {
                        await fetchAttendanceData(selectedMonth!, selectedYear!.toString());
                      }
                    },
                  ),
                ),
                
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: attData.isEmpty
                    ? const Center(child: Text("No attendance records found"))
                    : DataTable(
                        columns: const [
                          DataColumn(label: Text("Day")),
                          DataColumn(label: Text("In Time")),
                          DataColumn(label: Text("Out Time")),
                          DataColumn(label: Text("Hours")),
                        ],
                        rows: attData
                            .expand((data) => data.info)
                            .map((entry) => DataRow(cells: [
                                  DataCell(Text(entry.day)),
                                  DataCell(Text(entry.inTime)),
                                  DataCell(Text(entry.outTime)),
                                  DataCell(Text(entry.hours)),
                                ]))
                            .toList(),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
