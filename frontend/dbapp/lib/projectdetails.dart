import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'config.dart';

class ProjectService {
  final String baseUrl;

  ProjectService(this.baseUrl);

  Future<Map<String, dynamic>> fetchSpinnersData(String token) async {
    final url = Uri.parse('$baseUrl/getProjMasterSpinnersData');
    final response = await http.get(
      url,
      headers: {'currentToken': token},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List && data.isNotEmpty) {
        return data.first as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response format: $data');
      }
    } else {
      throw Exception('Failed to fetch spinners data.');
    }
  }

  Future<void> addProject(
      String token, Map<String, dynamic> projectData) async {
    final url =
        Uri.parse('$baseUrl/addProjectMaster'); // Your add project endpoint
    final headers = {
      'Content-Type': 'application/json',
      'currentToken': token, // Adding the token to headers
    };

    // Convert project data into JSON format
    final body = jsonEncode(projectData);

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Handle the response
      if (response.statusCode != 200) {
        throw Exception('Failed to add project: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error if any
      throw Exception('Error adding project: $e');
    }
  }

  Future<void> updateProject(
      String token, Map<String, dynamic> projectData) async {
    final url = Uri.parse('$baseUrl/updateProjectMaster');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'currentToken': token,
      },
      body: json.encode(projectData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update project. ${response.body}');
    }
  }

  // Method to delete a project
  Future<void> deleteProject(String token, String pid) async {
    final url =
        Uri.parse('$baseUrl/deleteProject?pid=$pid'); // Include PID in the URL

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'currentToken': token, // Pass the currentToken header
          'oldToken': '', // Pass the oldToken header if needed
        },
      );

      if (response.statusCode == 200) {
        print('Project with PID: $pid deleted successfully');
      } else {
        throw Exception(
            'Failed to delete project. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error deleting project: $error');
    }
  }
}

class ProjectMasterPage extends StatefulWidget {
  final String token;

  const ProjectMasterPage({required this.token, Key? key}) : super(key: key);

  @override
  _ProjectMasterPageState createState() => _ProjectMasterPageState();
}

class _ProjectMasterPageState extends State<ProjectMasterPage> {
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = false;
  Set<int> _selectedRows = {}; // Track selected rows

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    final url = Uri.parse(
        '$apiUrl/getProjectMaster'); // Update with your API endpoint
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        url,
        headers: {'currentToken': widget.token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        setState(() {
          _projects = data.map((e) => e as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception(
            'Failed to fetch projects. Status code: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog(error.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void showUpdateDialog(Map<String, dynamic> project) {
  showDialog(
    context: context,
    builder: (context) => UpdateProjectDialog(
      projectData: project,
      token: widget.token,
    ),
  ).then((isUpdated) {
    if (isUpdated == true) {
      fetchProjects();
      setState(() {
      _selectedRows.clear();
    });
    }
  });
}


  void deleteSelectedProjects() {
    for (int index in _selectedRows) {
      final project = _projects[index];
      final pid = project['pid'];

      if (pid != null && pid.isNotEmpty) {
        final projectService = ProjectService('$apiUrl');
        projectService.deleteProject(widget.token, pid).then((_) {
          fetchProjects();
        }).catchError((error) {
          showErrorDialog('Failed to delete project: $error');
        });
      }
    }
    setState(() {
      _selectedRows.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Master'),
        actions: _selectedRows.isNotEmpty
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: deleteSelectedProjects,
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    if (_selectedRows.length == 1) {
                      final project = _projects[_selectedRows.first];
                      showUpdateDialog(project);
                      
                    } else {
                      showErrorDialog('Select only one project to edit.');
                    }
                  },
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    showCheckboxColumn: false,
                    columns: const [
                      DataColumn(label: Text('PID')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Technology')),
                      DataColumn(label: Text('Manager')),
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: _projects.asMap().entries.map((entry) {
                      final index = entry.key;
                      final project = entry.value;
                      final isSelected = _selectedRows.contains(index);

                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          setState(() {
                            if (selected!) {
                              _selectedRows.add(index);
                            } else {
                              _selectedRows.remove(index);
                            }
                          });
                        },
                        cells: [
                          DataCell(Text(project['pid'] ?? '')),
                          DataCell(Text(project['pdesc'] ?? '')),
                          DataCell(Text(project['techdesc'] ?? '')),
                          DataCell(Text(project['manname'] ?? '')),
                          DataCell(Text(project['cusname'] ?? '')),
                          DataCell(Text(project['statusdesc'] ?? '')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => UpdateProjectDialog(
              projectData: {},
              token: widget.token,
            ),
          ).then((isAdded) {
            if (isAdded == true) {
              fetchProjects();
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

void deleteProject(String token, String pid) async {
  final projectService =
      ProjectService('$apiUrl'); // Your base URL

  try {
    await projectService.deleteProject(token, pid);
    // Notify user that project was deleted
    print('Project deleted successfully');
  } catch (error) {
    // Show an error dialog or message
    print('Failed to delete project: $error');
  }
}

class UpdateProjectDialog extends StatefulWidget {
  final Map<String, dynamic> projectData;
  final String token;

  const UpdateProjectDialog({
    required this.projectData,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  _UpdateProjectDialogState createState() => _UpdateProjectDialogState();
}

class _UpdateProjectDialogState extends State<UpdateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final ProjectService _projectService = ProjectService('http://192.168.17.5:2024');
  Map<String, dynamic> _spinnersData = {};
  bool _isLoading = true;

  String? _selectedCustomer;
  String? _selectedTechnology;
  String? _selectedManager;
  late TextEditingController _descriptionController;
  DateTime? _expectedDate;
  DateTime? _completionDate;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.projectData['pdesc'] ?? '');
    fetchSpinnersData();
  }

  Future<void> _addProject() async {
    if (!_formKey.currentState!.validate()) return;

    final projectData = {
      'pdesc': _descriptionController.text.trim(),
      'customer': _selectedCustomer,
      'technology': _selectedTechnology,
      'manager': _selectedManager,
      'expdate': _expectedDate != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(_expectedDate!)
          : null,
      'comdate': _completionDate != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(_completionDate!)
          : null,
    };

    try {
      await _projectService.addProject(widget.token, projectData);
      Navigator.of(context).pop(true); // Return success
    } catch (e) {
      showErrorDialog(e.toString());
    }
  }

  Future<void> fetchSpinnersData() async {
    try {
      final data = await _projectService.fetchSpinnersData(widget.token);
      setState(() {
        _spinnersData = data;
        _selectedCustomer = widget.projectData['customer'] as String?;
        _selectedTechnology = widget.projectData['technology'] as String?;
        _selectedManager = widget.projectData['manager'] as String?;
        _expectedDate = widget.projectData['expdate'] != null
            ? DateFormat('dd/MM/yyyy').parse(widget.projectData['expdate'])
            : null;

        _completionDate = widget.projectData['comdate'] != null
            ? DateFormat('dd/MM/yyyy').parse(widget.projectData['comdate'])
            : null;

        _isLoading = false;
      });
    } catch (e) {
      showErrorDialog(e.toString());
    }
  }

  void showErrorDialog(String message) {
    print(message);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProject() async {
    if (!_formKey.currentState!.validate()) return;

    final projectData = {
      'pid': widget.projectData['pid'],
      'pdesc': _descriptionController.text.trim(),
      'customer': _selectedCustomer,
      'technology': _selectedTechnology,
      'manager': _selectedManager,
      'expdate': _expectedDate != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(_expectedDate!)
          : null,
      'comdate': _completionDate != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(_completionDate!)
          : null,
    };
    print(projectData);
    try {
      await _projectService.updateProject(widget.token, projectData);
      Navigator.of(context).pop(true); // Return success
    } catch (e) {
      showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.projectData['pid'] == null ? 'Add Project' : 'Update Project'),
      content: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      isDense: false,
                      isExpanded: true,
                      value: _selectedCustomer,
                      onChanged: (value) =>
                          setState(() => _selectedCustomer = value),
                      items: (_spinnersData['Customer'] as List<dynamic>?)
                          ?.map((item) => DropdownMenuItem<String>(
                                value: item['sCode']
                                    ?.toString(), // Ensure casting to String
                                child: Text(
                                  item['sDesc']?.toString() ?? '',
                                ), // Fallback if null
                              ))
                          .toList(),
                      decoration: InputDecoration(labelText: 'Customer'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a customer'
                          : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Description cannot be empty'
                              : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedTechnology,
                      onChanged: (value) =>
                          setState(() => _selectedTechnology = value),
                      items: (_spinnersData['Technology'] as List<dynamic>?)
                          ?.map((item) => DropdownMenuItem<String>(
                                value: item['sCode']
                                    ?.toString(), // Ensure casting to String
                                child: Text(item['sDesc']?.toString() ??
                                    ''), // Fallback if null
                              ))
                          .toList(),
                      decoration: InputDecoration(labelText: 'Technology'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a technology'
                          : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedManager,
                      onChanged: (value) =>
                          setState(() => _selectedManager = value),
                      items: (_spinnersData['Manager'] as List<dynamic>?)
                          ?.map((item) => DropdownMenuItem<String>(
                                value: item['sCode']
                                    ?.toString(), // Ensure casting to String
                                child: Text(item['sDesc']?.toString() ??
                                    ''), // Fallback if null
                              ))
                          .toList(),
                      decoration: InputDecoration(labelText: 'Manager'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a manager'
                          : null,
                    ),
                    ListTile(
                      title: Text('Expected Date'),
                      subtitle: Text(
                        _expectedDate == null
                            ? 'No date selected'
                            : DateFormat('yyyy-MM-dd').format(_expectedDate!),
                      ),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _expectedDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                            );
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text('Completion Date'),
                      subtitle: Text(
                        _completionDate == null
                            ? 'No date selected'
                            : DateFormat('yyyy-MM-dd').format(_completionDate!),
                      ),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _completionDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
              )),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              widget.projectData['pid'] == null ? _addProject : _updateProject,
          child: Text(widget.projectData['pid'] == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
