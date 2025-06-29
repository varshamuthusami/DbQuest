import 'package:flutter/material.dart';
import 'api_keys.dart';
import 'model.dart';

class WorkScreen extends StatefulWidget {
  final String token;
  final String empID;
  WorkScreen({required this.token, required this.empID});

  @override
  _WorkScreenState createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  String? selectedEmpId;
  String? selectedEmpName;

  int? selectedYear;
  int? selectedMonth;

  List<Map<String, String>> employees = []; // List of {EmpID, EmpName}
  List<int> yearList = [];
  List<int> monthList = [];

  List<WorkDate> workData = [];

  final List<String> monthNames = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  @override
  void initState() {
    super.initState();
    monthList = List.generate(12, (index) => index + 1); // Always all months
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      final empList = await ApiService(token: widget.token)
          .getAccessibleEmployees(widget.empID);
      if (empList.isNotEmpty) {
        setState(() {
          employees = empList;
          selectedEmpId = empList[0]['EmpID'];
          selectedEmpName = empList[0]['EmpName'];
        });
        await fetchDOJAndSetupYearMonth();
      }
    } catch (e) {
      print("Error fetching employees: $e");
    }
  }

  Future<void> fetchDOJAndSetupYearMonth() async {
    if (selectedEmpId == null) return;
    try {
      final doj = await ApiService(token: widget.token)
          .getDOJOfEmployee(selectedEmpId!);
      final now = DateTime.now();

      yearList = List.generate(now.year - doj.year + 1, (i) => doj.year + i);

      selectedYear = now.year;
      selectedMonth = now.month;

      updateMonthList(); // just all 12 months

      await fetchWorkData();
    } catch (e) {
      print("Error fetching DOJ or setting up date selectors: $e");
    }
  }

  void updateMonthList() {
    monthList = List.generate(12, (index) => index + 1);
    if (selectedMonth == null) {
      selectedMonth = DateTime.now().month;
    }
  }

  Future<void> fetchWorkData() async {
    if (selectedEmpId == null || selectedYear == null || selectedMonth == null)
      return;

    try {
      // Your API expects month name and year in split form
      final monthName = monthNames[selectedMonth! - 1];
      List<WorkDate> workList = await ApiService(token: widget.token)
          .getWorkList(selectedEmpId!, monthName, selectedYear.toString());

      setState(() {
        workData = workList;
      });
    } catch (e) {
      print("Error fetching work data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Worksheet")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Employee Dropdown (showing names, storing empId)
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedEmpId,
                    hint: Text("Select Employee"),
                    isExpanded: true,
                    items: employees.map((e) {
                      return DropdownMenuItem(
                        value: e['EmpID'],
                        child: Text(e['EmpName']!),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() {
                        selectedEmpId = value;
                        selectedEmpName = employees
                            .firstWhere((e) => e['EmpID'] == value)['EmpName'];
                        workData.clear();
                        selectedYear = null;
                        selectedMonth = null;
                        yearList = [];
                        monthList = [];
                      });
                      await fetchDOJAndSetupYearMonth();
                    },
                  ),
                ),
                SizedBox(width: 10),

                // Year Dropdown
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedYear,
                    hint: Text("Select Year"),
                    isExpanded: true,
                    items: yearList.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedYear = value;
                        // update monthList based on new year selection
                        updateMonthList();
                        workData.clear();
                      });
                      fetchWorkData();
                    },
                  ),
                ),
                SizedBox(width: 10),

                // Month Dropdown
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    hint: Text("Select Month"),
                    isExpanded: true,
                    items: monthList.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(monthNames[month - 1]),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedMonth = value;
                        workData.clear();
                      });
                      fetchWorkData();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: workData.length,
              itemBuilder: (context, index) {
                WorkDate workDate = workData[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ExpansionTile(
                    title: Text(workDate.title,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    children: workDate.entries.map((entry) {
                      return ListTile(
                        title: Text(entry.projectDesc),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Type: ${entry.workType}"),
                            Text("Description: ${entry.workDesc}"),
                          ],
                        ),
                        trailing: Text("${entry.taskPercent}%"),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
