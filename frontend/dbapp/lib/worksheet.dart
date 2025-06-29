import 'package:dbapp/api_keys.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_selector/file_selector.dart';

class DropdownScreen extends StatefulWidget {
  final String token;
  final String empID;
  final DropdownService dropdownService;

  DropdownScreen(
      {required this.token,
      required this.empID,
      required this.dropdownService});

  @override
  _DropdownScreenState createState() => _DropdownScreenState();
}

class _DropdownScreenState extends State<DropdownScreen> {
  List<Map<String, String>> workDates = [];
  List<Map<String, String>> workTypes = [];
  List<Map<String, String>> projects = [];
  List<Map<String, String>> subTasks = [];
  List<Map<String, String>> projectTasks = [];
  String? selectedTask;
  double taskPercentage = 0;
  XFile? selectedFilePath;

  String? selectedWorkDate;
  String? selectedWorkType;
  String? selectedProject;
  TextEditingController taskDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    generateLast10Days();
    fetchDropdownData();
  }

  void generateLast10Days() {
    DateTime now = DateTime.now();
    setState(() {
      workDates = List.generate(10, (index) {
        DateTime date = now.subtract(Duration(days: index));
        String formattedDate =
            DateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(date);

        return {
          "sCode": formattedDate, // Store the correctly formatted date
          "sDesc":
              DateFormat("yyyy-MM-dd").format(date), // Display shorter format
        };
      });
    });
  }

  Future<void> showAddSubTaskDialog() async {
    TextEditingController subTaskDescController = TextEditingController();
    TextEditingController fileNameController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    TextEditingController endTimeController = TextEditingController();

    Future<void> pickTime(
        BuildContext context, TextEditingController controller) async {
      TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (picked != null) {
        // Format time as "HH:mm:ss.0000000"
        String formattedTime = "${picked.hour.toString().padLeft(2, '0')}:"
            "${picked.minute.toString().padLeft(2, '0')}:00.0000000";

        setState(() {
          controller.text = formattedTime;
        });
      }
    }

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Sub Task"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subTaskDescController,
                  decoration: InputDecoration(labelText: "Task Description"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: fileNameController,
                  decoration: InputDecoration(labelText: "Filename/Screen"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: startTimeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Start Time",
                  ),
                  onTap: () => pickTime(context, startTimeController),
                ),
                TextField(
                  controller: endTimeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "End Time",
                  ),
                  onTap: () => pickTime(context, endTimeController),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Map<String, String> subTask = {
                  "empid": widget.empID,
                  "wdesc": subTaskDescController.text,
                  "wref": fileNameController.text,
                  "stime": startTimeController.text,
                  "etime": endTimeController.text,
                };

// Add the sub-task to the list
                subTasks.add(subTask);
                print({
                  "Task Description": subTaskDescController.text,
                  "Filename/Screen": fileNameController.text,
                  "Start Time": startTimeController.text,
                  "End Time": endTimeController.text,
                });

                setState(() {
                  // Refresh the task list after adding the subtask
                  TaskService.fetchSubTasks(
                    widget.token,
                  );
                });

                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchDropdownData() async {
    String empID = widget.empID; // Replace with actual EmpID
    var data =
        await widget.dropdownService.fetchDropdownData(empID, widget.token);
    setState(() {
      projects = data["projects"]!;
      workTypes = data["workTypes"]!;
    });
  }

  Future<void> fetchTasksForProject(String projectId) async {
    final tasks =
        await widget.dropdownService.fetchProjTasks(projectId, widget.token);
    setState(() {
      projectTasks = [
        {"sCode": "none", "sDesc": "None"},
        ...tasks.map((t) => {
              "sCode": t["taskid"].toString(),
              "sDesc": t["taskdesc"] ?? "Untitled Task",
            })
      ];
    });
  }

  Future<XFile?> pickSingleFile() async {
    final XTypeGroup typeGroup = XTypeGroup(
      label: 'Files',
      extensions: [
        'pdf',
        'doc',
        'docx',
        'jpg',
        'png',
        'jpeg',
      ], // add more if needed
    );

    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Worksheet')),
      body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownWidget(
                  hint: "Select Work Date",
                  selectedValue: selectedWorkDate,
                  items: workDates,
                  onChanged: (value) =>
                      setState(() => selectedWorkDate = value),
                ),
                SizedBox(height: 10),
                DropdownWidget(
                  hint: "Select Work Type",
                  selectedValue: selectedWorkType,
                  items: workTypes,
                  onChanged: (value) =>
                      setState(() => selectedWorkType = value),
                ),
                SizedBox(height: 10),
                DropdownWidget(
                  hint: "Select Project",
                  selectedValue: selectedProject,
                  items: projects,
                  onChanged: (value) async {
                    setState(() {
                      selectedProject = value;
                      selectedTask = null;
                      taskPercentage = 0;
                      projectTasks = [];
                    });

                    if (value != null) {
                      await fetchTasksForProject(value);
                    }
                  },
                ),

                if (projectTasks.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownWidget(
                        hint: "Select Task",
                        selectedValue: selectedTask,
                        items: projectTasks,
                        onChanged: (value) {
                          setState(() {
                            selectedTask = value;
                            taskPercentage = 0;
                          });
                        },
                      ),
                      if (selectedTask != null && selectedTask != "none") ...[
                        SizedBox(height: 10),
                        Text("Task Completion: ${taskPercentage.toInt()}%"),
                        Slider(
                          value: taskPercentage,
                          min: 0,
                          max: 100,
                          divisions: 20,
                          label: "${taskPercentage.toInt()}%",
                          onChanged: (value) {
                            setState(() {
                              taskPercentage = value;
                            });
                          },
                        ),
                      ],
                    ],
                  ),

                SizedBox(height: 10),
                TextField(
                  controller: taskDescriptionController,
                  decoration: InputDecoration(
                    labelText: "Task Description",
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.attach_file),
                  label: Text(selectedFilePath == null
                      ? "Attach File"
                      : "File Selected"),
                  onPressed: () async {
                    final XFile? file = await pickSingleFile();
                    if (file != null) {
                      setState(() {
                        selectedFilePath = file;
                      });
                    }
                  },
                ),
                if (selectedFilePath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Selected File: ${selectedFilePath!.name}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                SizedBox(height: 10), // Space between fields and subtasks

                // Subtasks Containers
                if (subTasks.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: subTasks.map((subTask) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Description: ${subTask["wdesc"]}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text("File: ${subTask["wref"]}"),
                                    Text(
                                        "Start: ${subTask["stime"]}\nEnd: ${subTask["etime"]}"),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    subTasks.remove(subTask);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                SizedBox(height: 10),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: showAddSubTaskDialog,
                      child: Text("Add Sub Task"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedWorkDate == null ||
                            selectedWorkType == null ||
                            selectedProject == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text("Please select all required fields")),
                          );
                          return;
                        }

                        bool success =
                            await DropdownService.addTaskWithSubtasks(
                          empId: widget.empID,
                          workDate: selectedWorkDate!,
                          workType: selectedWorkType!,
                          projectId: selectedProject!,
                          taskDescription: taskDescriptionController.text,
                          subTasks: subTasks,
                          token: widget.token,
                          taskId: selectedTask == "none" ? null : selectedTask,
                          taskPercentage: selectedTask == "none"
                              ? null
                              : taskPercentage.toInt(),
                          attachmentFile: selectedFilePath,
                        );

                        if (success) {
                          // Show Snackbar if task and subtasks are added successfully
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Task added successfully!'),
                              // Success color
                              duration: Duration(
                                  seconds:
                                      2), // How long the Snackbar will show
                            ),
                          );

                          // Clear all fields after showing the Snackbar
                          taskDescriptionController
                              .clear(); // Clear the task description
                          setState(() {
                            subTasks.clear(); // Clear the subtasks list
                            selectedWorkDate = null; // Clear the work date
                            selectedWorkType = null; // Clear the work type
                            selectedProject = null;
                            selectedTask = null;
                            taskPercentage = 0; // Reset the slider
                            projectTasks = [];
                            selectedFilePath = null;
                            // Clear the project
                          });
                        } else {
                          // If something goes wrong, show an error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Failed to add task. Please try again.'),
                              // Error color
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }

                        print({
                          "Work Date": selectedWorkDate,
                          "Work Type": selectedWorkType,
                          "Project ID":
                              selectedProject, // This now prints the correct project ID
                          "Description": taskDescriptionController.text,
                        });
                      },
                      child: Text("Submit"),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

class DropdownWidget extends StatelessWidget {
  final String hint;
  final String? selectedValue;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;

  DropdownWidget({
    required this.hint,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: Text(hint),
      value: selectedValue,
      isExpanded: true,
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['sCode'],
          child: Text(item['sDesc']!),
        );
      }).toList(),
    );
  }
}
