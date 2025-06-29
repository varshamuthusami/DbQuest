import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'api_keys.dart';
import 'package:intl/intl.dart';
import 'model.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path show basename;
import 'package:url_launcher/url_launcher.dart';
import 'config.dart';

class TaskListScreen extends StatefulWidget {
  final String token;
  final String empID;

  TaskListScreen({required this.token, required this.empID});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> futureTasks;
  Set<int> selectedTasks = {};

  @override
  void initState() {
    super.initState();
    _refreshTaskList();
  }

  void _refreshTaskList() {
    setState(() {
      futureTasks = TaskService.fetchTasks(widget.token, widget.empID);
      selectedTasks.clear();
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (selectedTasks.contains(index)) {
        selectedTasks.remove(index);
      } else {
        selectedTasks.add(index);
      }
    });
  }

  void _deleteSelectedTasks(List<Task> tasks) async {
    if (selectedTasks.isEmpty) return;

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete the selected tasks?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (int index in selectedTasks) {
        await TaskService.deleteProject(
          widget.token,
          tasks[index].projectId!,
          tasks[index].taskId,
        );
      }
      _refreshTaskList();
    }
  }

  void _showTaskDialog({Task? task}) async {
    final dropdownData = await TaskService.fetchDropdownData(widget.token);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddTaskDialog(
        dropdownData: dropdownData,
        token: widget.token,
        empID: widget.empID,
        task: task,
      ),
    );
    if (result == true) _refreshTaskList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: selectedTasks.isNotEmpty
          ? AppBar(
              title: Text("${selectedTasks.length} Selected"),
              actions: [
                if (selectedTasks.length ==
                    1) // Only show edit icon if one task is selected
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      futureTasks.then((tasks) {
                        int selectedIndex = selectedTasks.first;
                        _showTaskDialog(
                            task: tasks[selectedIndex]); // Open edit dialog
                      });
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () =>
                      futureTasks.then((tasks) => _deleteSelectedTasks(tasks)),
                ),
              ],
            )
          : AppBar(title: Text("Project Tasks")),
      body: FutureBuilder<List<Task>>(
        future: futureTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No tasks found"));
          } else {
            List<Task> tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                Task task = tasks[index];
                bool isSelected = selectedTasks.contains(index);
                return InkWell(
                  onLongPress: () => _toggleSelection(index),
                  onTap: () => _toggleSelection(
                      index), // Only allow selection, no edit on tap

                  child: Card(
                    color: isSelected ? Colors.blue[50] : Colors.white,
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.taskDesc ?? "N/A",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.work_outline,
                                  size: 16, color: Colors.blueGrey),
                              SizedBox(width: 6),
                              Text("Type: ${task.taskType}"),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16, color: Colors.blueGrey),
                              SizedBox(width: 6),
                              Text(
                                  "Date: ${task.startDate ?? "N/A"} - ${task.endDate ?? "N/A"}"),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person,
                                  size: 16, color: Colors.blueGrey),
                              SizedBox(width: 6),
                              Text(
                                  "Assigned To: ${task.assignedName ?? "N/A"}"),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.timer,
                                  size: 16, color: Colors.blueGrey),
                              SizedBox(width: 6),
                              Text("Duration: ${task.duration ?? "N/A"} days"),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 16, color: Colors.blueGrey),
                              SizedBox(width: 6),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: task.taskStatus == "OnGoing"
                                      ? Colors.green[100]
                                      : Colors.yellow[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  task.taskStatus ?? "N/A",
                                  style: TextStyle(
                                    color: task.taskStatus == "OnGoing"
                                        ? Colors.green[800]
                                        : Colors.orange[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (task.attachment != null &&
                              task.attachment!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white, // Button background
                                  foregroundColor:
                                      Colors.blue, // Text & Icon color
                                  //side: BorderSide(color: Colors.blue), // Optional: adds blue border
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                onPressed: () async {
                                  final Uri url = Uri.parse(
                                    "$apiUrl/ProjectTaskDownload/file"
                                    "?FileName=${Uri.encodeComponent(task.attachment!)}"
                                    "&PID=${Uri.encodeComponent(task.projectId!)}"
                                    "&TASKID=${Uri.encodeComponent(task.taskId.toString())}",
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url,
                                        mode: LaunchMode.externalApplication);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Could not launch document')),
                                    );
                                  }
                                },
                                icon: Icon(Icons.edit_document),
                                label: Text("View Document"),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddTaskDialog extends StatefulWidget {
  final Map<String, List<dynamic>> dropdownData;
  final String token;
  final String empID;
  final Task? task;

  AddTaskDialog({
    required this.dropdownData,
    required this.token,
    required this.empID,
    this.task,
  });

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedProject;
  late String _selectedTaskType;
  late String _taskDesc;
  late String _selectedEmployee;
  DateTime? _startDate;
  DateTime? _endDate;
  File? _selectedFile;

  @override
  void initState() {
    super.initState();

    List<Project> projects = widget.dropdownData['projects'] as List<Project>;
    _selectedProject = widget.task != null &&
            projects.any((p) => p.projectId == widget.task!.projectId)
        ? widget.task!.projectId!
        : (projects.isNotEmpty ? projects.first.projectId : '');

    List<TaskType> taskTypes =
        widget.dropdownData['taskTypes'] as List<TaskType>;
    _selectedTaskType = widget.task != null &&
            taskTypes.any((t) => t.taskTypeId == widget.task!.taskType)
        ? widget.task!.taskType
        : (taskTypes.isNotEmpty ? taskTypes.first.taskTypeId : '');

    _taskDesc = widget.task != null ? widget.task!.taskDesc ?? '' : '';

    List<Employee> employees =
        widget.dropdownData['employees'] as List<Employee>;
    _selectedEmployee = widget.task != null &&
            employees.any((e) => e.empId == widget.task!.assignedTo)
        ? widget.task!.assignedTo!
        : (employees.isNotEmpty ? employees.first.empId : '');

    _startDate = widget.task != null && widget.task!.startDate != null
        ? DateTime.tryParse(widget.task!.startDate!)
        : null;

    _endDate = widget.task != null && widget.task!.endDate != null
        ? DateTime.tryParse(widget.task!.endDate!)
        : null;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveorupdate(String s) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final task = TaskDetails(
        projectId: _selectedProject,
        taskType: _selectedTaskType,
        taskDesc: _taskDesc,
        startDate: DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(_startDate!),
        endDate: DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(_endDate!),
        assignedTo: _selectedEmployee,
        createdBy: widget.empID,
        taskId: widget.task?.taskId,
        file: _selectedFile,
      );

      if (s == "save") {
        TaskService.saveTask(widget.token, task).then((_) {
          Navigator.of(context).pop(true); // Close the dialog and return true
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save task: $error')),
          );
        });
      } else {
        TaskService.UpdateTask(widget.token, task, file: _selectedFile)
            .then((_) {
          Navigator.of(context).pop(true); // Close the dialog and return true
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save task: $error')),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.task != null ? Text('Update Task') : Text('Add Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                isDense: false,
                isExpanded: true,
                value: _selectedProject,
                items: (widget.dropdownData['projects'] as List<Project>)
                    .map((project) => DropdownMenuItem(
                          value: project.projectId,
                          child: Text(project.projectDesc),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProject = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Project'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedTaskType,
                items: (widget.dropdownData['taskTypes'] as List<TaskType>)
                    .map((taskType) => DropdownMenuItem(
                          value: taskType.taskTypeId,
                          child: Text(taskType.taskTypeDesc),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTaskType = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Task Type'),
              ),
              TextFormField(
                initialValue: _taskDesc,
                decoration: InputDecoration(labelText: 'Task Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _taskDesc = value!;
                },
              ),
              ListTile(
                title: Text(_startDate == null
                    ? 'Select Start Date'
                    : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}'),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: Text(_endDate == null
                    ? 'Select End Date'
                    : 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}'),
                onTap: () => _selectDate(context, false),
              ),
              DropdownButtonFormField<String>(
                value: _selectedEmployee,
                items: (widget.dropdownData['employees'] as List<Employee>)
                    .map((employee) => DropdownMenuItem(
                          value: employee.empId,
                          child: Text(employee.empName),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEmployee = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Assigned To'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final XFile? pickedFile = await openFile();
                  if (pickedFile != null) {
                    setState(() {
                      _selectedFile = File(
                          pickedFile.path); // Convert XFile to dart.io.File
                    });
                  }
                },
                child: Text(_selectedFile == null
                    ? 'Select File'
                    : 'File: ${path.basename(_selectedFile!.path)}'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Fixed the onPressed logic
            _saveorupdate(widget.task == null ? "save" : "update");
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
