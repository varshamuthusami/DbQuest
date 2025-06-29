import 'package:dbapp/api_keys.dart';
import 'package:dbapp/model.dart';
import 'package:flutter/material.dart';

class LeaveRequest extends StatefulWidget {
  final String token;
  final String empID;
  final LeaveService leaveservice;

  const LeaveRequest({
    required this.token,
    required this.empID,
    required this.leaveservice,
    super.key,
  });

  @override
  State<LeaveRequest> createState() => _LeaveRequestState();
}

class _LeaveRequestState extends State<LeaveRequest>
    with SingleTickerProviderStateMixin {
  List<LeaveApproval> leaves = [];
  List<LeaveApproval> _selectedLeaves = [];
  bool isLoading = true;
  List<Map<String, dynamic>> approvers = [];
  String? selectedApproverName;
  String? selectedApproverID;
  List<String> approverNames = []; // Add this line

  @override
  void initState() {
    super.initState();
    fetchLeaves();
    fetchApprovers();
  }

  void fetchLeaves() async {
    setState(() {
      isLoading = true;
    });
    List<LeaveApproval> fetchedLeaves =
        await LeaveService.fetchLeave(widget.token, widget.empID);
    setState(() {
      leaves = fetchedLeaves;
      isLoading = false;
    });
  }

  void deleteSelectedLeaves() {
    setState(() {
      leaves.removeWhere((leave) => _selectedLeaves.contains(leave));
      _selectedLeaves.clear();
    });
  }

  void fetchApprovers() async {
    List<Map<String, dynamic>> fetchedApprovers =
        await LeaveService.getApprovers(widget.token, widget.empID);

    setState(() {
      approvers = fetchedApprovers;
      approverNames = approvers.map((e) => e["empname"] as String).toList();

      if (approvers.isNotEmpty) {
        selectedApproverName = approverNames.first;
        selectedApproverID = approvers.first["empid"] as String;
      }
    });

    print(approvers);
  }

  void _showLeaveDialog({LeaveApproval? leave}) {
    // Controllers for the form fields
    TextEditingController fromDateController = TextEditingController();
    TextEditingController toDateController = TextEditingController();
    TextEditingController reasonController = TextEditingController();
    TextEditingController noteController = TextEditingController();

    // Local variables to manage the selected approver within the dialog
    String? localSelectedApproverName;
    String? localSelectedApproverID;

    // Initialize controllers and approver selection if in "Update" mode
    if (leave != null) {
      fromDateController.text = leave.fromDate;
      toDateController.text = leave.toDate;
      reasonController.text = leave.reason;
      noteController.text = leave.note!;

      // Set the selected approver for update mode
      final currentApprover = approvers.firstWhere(
        (a) => a["empid"] == leave.approver,
        orElse: () => {},
      );
      if (currentApprover.isNotEmpty) {
        localSelectedApproverName = currentApprover["empname"] as String?;
        localSelectedApproverID = currentApprover["empid"] as String?;
      }
    }

    // Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              leave == null ? 'Add Leave Request' : 'Update Leave Request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // From Date Field with Date Picker
                TextField(
                  controller: fromDateController,
                  decoration: InputDecoration(labelText: 'From Date'),
                  readOnly: true, // Prevent manual input
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      fromDateController.text =
                          "${pickedDate.toLocal()}".split(' ')[0];
                    }
                  },
                ),
                // To Date Field with Date Picker
                TextField(
                  controller: toDateController,
                  decoration: InputDecoration(labelText: 'To Date'),
                  readOnly: true, // Prevent manual input
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      toDateController.text =
                          "${pickedDate.toLocal()}".split(' ')[0];
                    }
                  },
                ),
                // Reason Field
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(labelText: 'Leave Reason'),
                ),
                // Note Field
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(labelText: 'Note'),
                ),
                // Approver Dropdown
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setDialogState) {
                    return DropdownButton<String>(
                      value: localSelectedApproverName,
                      hint: Text('Select Approver'),
                      items: approverNames.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          // Use setDialogState instead of setState()
                          localSelectedApproverName = val;
                          if (val != null) {
                            final selected = approvers.firstWhere(
                              (a) => a["empname"] == val,
                              orElse: () => {},
                            );
                            if (selected.isNotEmpty) {
                              localSelectedApproverID =
                                  selected["empid"] as String?;
                            }
                          }
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Validate inputs
                if (fromDateController.text.isEmpty ||
                    toDateController.text.isEmpty ||
                    reasonController.text.isEmpty ||
                    localSelectedApproverID == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Please fill all required fields and select an approver')),
                  );
                  return;
                }

                // Handle "Add" or "Update" logic
                bool isSuccess;
                if (leave == null) {
                  // Add new leave request
                  isSuccess = await LeaveService.addLeaveRequest(
                    token: widget.token,
                    empID: widget.empID,
                    fromDate: fromDateController.text,
                    toDate: toDateController.text,
                    reason: reasonController.text,
                    note: noteController.text,
                    approverID:
                        localSelectedApproverID!, // Pass the selected approver ID
                  );
                } else {
                  // Update existing leave request
                  isSuccess = await LeaveService.updateLeaveRequest(
                    token: widget.token,
                    empID: widget.empID,
                    fromDate: fromDateController.text,
                    toDate: toDateController.text,
                    reason: reasonController.text,
                    note: noteController.text,
                    approver:
                        localSelectedApproverID!, // Pass the selected approver ID
                  );
                  setState(() {
                    _selectedLeaves.clear();
                  });
                }

                // Show success or failure message
                if (isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(leave == null
                            ? 'Leave request added successfully'
                            : 'Leave request updated successfully')),
                  );
                  fetchLeaves(); // Refresh the leave list
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(leave == null
                            ? 'Failed to add leave request'
                            : 'Failed to update leave request')),
                  );
                }

                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(leave == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: _selectedLeaves.isNotEmpty
      ? Text('${_selectedLeaves.length} selected')
      : Text("Leave Requests"),
  actions: [
    if (_selectedLeaves.isNotEmpty) ...[
      IconButton(
        icon: Icon(Icons.delete),
        onPressed: deleteSelectedLeaves,
      ),
      if (_selectedLeaves.length == 1)
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () =>
              _showLeaveDialog(leave: _selectedLeaves.first),
        ),
      if (_selectedLeaves.length == 1)
        IconButton(
          icon: Icon(Icons.check),
          tooltip: 'Approve Leave',
          onPressed: () async {
            LeaveApproval leave = _selectedLeaves.first;

            bool success = await LeaveService.approveLeaveRequest(
              token: widget.token,
              approverID: widget.empID,
              empID: leave.empID,
              fromDate: leave.fromDate,
            );

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Leave approved successfully")),
              );
              fetchLeaves();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to approve leave")),
              );
            }

            setState(() {
              _selectedLeaves.clear();
            });
          },
        ),
    ],
    IconButton(
      icon: Icon(Icons.people),
      tooltip: 'Currently On Leave',
      onPressed: () async {
        List<LeaveApproval> onLeaveList = await LeaveService.getCurrentlyOnLeave(widget.token);

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Employees On Leave Today'),
            content: SingleChildScrollView(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: onLeaveList.map((emp) {
      return ListTile(
        title: Text(emp.empName),
        subtitle: Text('${emp.fromDate} to ${emp.toDate}'),
      );
    }).toList(),
  ),
),

            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        );
      },
    ),
  ],
),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLeaveDialog(),
        child: Icon(Icons.add),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: leaves.length,
              itemBuilder: (context, index) {
                LeaveApproval leave = leaves[index];
                bool isSelected = _selectedLeaves.contains(leave);
                return InkWell(
                  onLongPress: () {
                    setState(() {
                      if (isSelected) {
                        _selectedLeaves.remove(leave);
                      } else {
                        _selectedLeaves.add(leave);
                      }
                    });
                  },
                  onTap: () {
                    setState(() {
                      if (_selectedLeaves.isNotEmpty) {
                        if (isSelected) {
                          _selectedLeaves.remove(leave);
                        } else {
                          _selectedLeaves.add(leave);
                        }
                      }
                    });
                  },
                  child: Card(
                    color: isSelected ? Colors.blue[50] : Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(leave.empName),
                      subtitle: Text(
                        '${leave.fromDate} - ${leave.toDate} (${leave.days} days)\nReason: ${leave.reason}',
                      ),
                      trailing: Text(leave.status),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
