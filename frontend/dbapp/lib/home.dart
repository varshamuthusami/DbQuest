import 'package:dbapp/api_keys.dart';
import 'package:dbapp/attendance.dart';
import 'package:dbapp/changepassword.dart';
import 'package:dbapp/customerdetails.dart';
import 'package:dbapp/employeeprofile.dart';
import 'package:dbapp/leaverequest.dart';
import 'package:dbapp/logout.dart';
import 'package:dbapp/model.dart';
import 'package:dbapp/projectdetails.dart';
import 'package:dbapp/projecttasks.dart';
import 'package:dbapp/viewattendance.dart';
import 'package:dbapp/viewworksheet.dart';
import 'package:dbapp/worksheet.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize() async {
    // Local notification setup
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    // Request permissions (especially for Android 13+)
    FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Default',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // Optionally handle background messages (e.g., store in local DB)
    print("📨 [BG] Message received: ${message.notification?.title}");
  }
}

class Home extends StatelessWidget {
  final String empID;
  final String empName;
  final String token;
  final String utype;
  final HomeService homeService;

  Home({
    super.key,
    required this.empID,
    required this.empName,
    required this.token,
    required this.utype,
    required this.homeService,
  });

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    NotificationHelper.initialize();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, size: 25),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open Drawer
              },
            );
          },
        ),
        title: Text('Home', style: TextStyle(fontSize: 20.0)),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Row(
                children: [
                  Icon(Icons.person, size: 50, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "$empName [$empID]",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildListTile(
                      context: context,
                      icon: Icons.home,
                      title: 'Home',
                      destinationPage: Home(
                        empID: empID,
                        empName: empName,
                        token: token,
                        utype: utype,
                        homeService: homeService,
                      ),
                    ),
                    buildListTile(
                      context: context,
                      icon: Icons.account_box,
                      title: 'Employee Profile',
                      destinationPage: EmployeeProfilePage(
                        empId: empID,
                        currentToken: token,
                      ),
                    ),
                    buildListTile(
                      context: context,
                      icon: Icons.fingerprint,
                      title: 'Attendance',
                      destinationPage: EmployeeAttendancePage(
                        empID: empID,
                        currentToken: token,
                        oldToken: '',
                      ),
                    ),
                    buildListTile(
                      context: context,
                      icon: Icons.people,
                      title: 'Customer Details',
                      destinationPage: CustomerDetailsPage(token: token),
                    ),
                    buildListTile(
                      context: context,
                      icon: Icons.apps,
                      title: 'Project Details',
                      destinationPage: ProjectMasterPage(token: token),
                    ),
                    buildListTile(
                      context: context,
                      icon: Icons.task,
                      title: 'Project Tasks',
                      destinationPage:
                          TaskListScreen(empID: empID, token: token),
                    ),
                    buildListTile(
                      context: context,
                      icon: Icons.article_outlined,
                      title: 'Worksheet',
                      destinationPage: DropdownScreen(
                        token: token,
                        empID: empID,
                        dropdownService: DropdownService(),
                      ),
                    ),
                    buildListTile(
                        context: context,
                        icon: Icons.mail_outline,
                        title: 'Leave Request',
                        destinationPage: LeaveRequest(
                            token: token,
                            empID: empID,
                            leaveservice: LeaveService())),
                    buildListTile(
                      context: context,
                      icon: Icons.view_agenda,
                      title: 'View Attendance',
                      destinationPage: AttendanceView(
                        empID: empID,
                        token: token,
                      ),
                    ),
                    buildListTile(
                      context: context,
                      icon: Icons.auto_stories_rounded,
                      title: 'View Worksheet',
                      destinationPage: WorkScreen(
                        empID: empID,
                        token: token,
                      ),
                    ),
                    Divider(),
                    // Settings Section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Settings",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    buildListTile(
                      context: context,
                      icon: Icons.password,
                      title: 'Change Password',
                      destinationPage: ChangePasswordScreen(
                        token: token,
                        empID: empID,
                        service: PasswordChangeService(),
                        utype: utype,
                      ),
                    ),
                    buildListTile(
                      context: context,
                      icon: Icons.logout,
                      title: 'Logout',
                      destinationPage: null,
                      onTap: () => showLogoutDialog(context, empID,
                          token), // 🔹 Call logout popup instead of navigating
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person, size: 40),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome"),
                      Text("$empName [$empID]"),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Worksheet Analysis",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // PieChartScreen will take natural space based on its conAspectRatio(
            IntrinsicHeight(
              child: BarChartScreen(
                empID: empID,
                homeService: homeService,
                token: token,
              ),
            ),

//PieChartScreen(empID: empID, homeService: homeService),
            //SizedBox(height: 10),
            // Pending Tasks Section will also grow based on the content
            Text(
              "Pending Tasks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            PendingTasksScreen(
              userId: empID,
              currentToken: token,
              homeService: homeService,
            ),
            SizedBox(height: 10),
            // Leave Approval Section grows naturally
            Text(
              "Pending Leave Requests",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            LeaveApprovalContent(
                userID: empID, token: token, homeService: homeService),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  ListTile buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget? destinationPage, // Make nullable for logout case
    VoidCallback? onTap, // Optional function for custom actions
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        _scaffoldKey.currentState?.closeDrawer();

        if (onTap != null) {
          onTap(); // 🔹 If onTap function exists, execute it
        } else if (destinationPage != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationPage),
          );
        }
      },
    );
  }
}

class WorkDurationBarChart extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String empID;
  final String token;

  WorkDurationBarChart(
      {required this.data, required this.empID, required this.token});

  @override
  _WorkDurationBarChartState createState() => _WorkDurationBarChartState();
}

class _WorkDurationBarChartState extends State<WorkDurationBarChart> {
  List<String> selectedYears = [DateTime.now().year.toString()];
  List<String> selectedMonths = [DateTime.now().month.toString()];

  List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
  ];

  Color _getColorForBar(int index) {
    return colors[index % colors.length];
  }

  final List<Map<String, dynamic>> monthsList = List.generate(12, (index) {
    return {
      "id": (index + 1).toString(), // Store month as number
      "name": [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][index] // Store month name
    };
  });

  @override
  Widget build(BuildContext context) {
    // Get minYear dynamically from data
    List<int> years = widget.data
        .map((item) =>
            int.tryParse(item['year'].toString()) ?? DateTime.now().year)
        .toList();
    int minYear = years.isNotEmpty
        ? years.reduce((a, b) => a < b ? a : b)
        : DateTime.now().year;
    int currentYear = DateTime.now().year;
    List<String> yearList = List.generate(
        currentYear - minYear + 1, (index) => (minYear + index).toString());

    List<Map<String, dynamic>> filteredData = widget.data.where((item) {
      return selectedMonths.contains(item['month'].toString()) &&
          selectedYears.contains(item['year'].toString());
    }).toList();

// ✅ Calculate total hours dynamically
    double maxHours = filteredData.isNotEmpty
        ? (filteredData
            .map((item) => double.parse(item['value']) / 60.0)
            .reduce((a, b) => a > b ? a : b))
        : 0;

    double interval = (maxHours / 5).ceilToDouble();

    return Column(
      children: [
        // Year Dropdown

        // Multi-Select Year Dropdown

        

        AspectRatio(
          aspectRatio: 1,
          child: BarChart(
            BarChartData(
              barGroups: List.generate(filteredData.length, (index) {
                final item = filteredData[index];
                final double workHours = double.parse(item['value']) / 60.0;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: workHours,
                      color: _getColorForBar(index),
                      width: 18,
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ],
                );
              }),
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    getTitlesWidget: (value, meta) {
                      return value % interval == 0
                          ? Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Text('${value.toInt()}h',
                                  style: TextStyle(fontSize: 12)),
                            )
                          : SizedBox.shrink();
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toStringAsFixed(1)}h', // Your text
                      TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        backgroundColor:
                            Colors.blueGrey, // ✅ ACTUAL WORKING PROPERTY
                      ),
                      // For padding/margin adjustments
                      //margin: EdgeInsets.all(4),
                      //padding: EdgeInsets.all(8),
                    );
                  },
                  tooltipMargin: 8, // Space between bar and tooltip
                  tooltipPadding: EdgeInsets.all(8), // Inner tooltip padding
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                ),
                touchCallback:
                    (FlTouchEvent event, BarTouchResponse? response) {
                  if (event is FlTapUpEvent &&
                      response != null &&
                      response.spot != null) {
                    final int index = response.spot!.touchedBarGroupIndex;
                    _showProjectDetails(context, filteredData[index],
                        widget.token, widget.empID);
                  }
                },
              ),
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 25.0, vertical: 4.0), // Add padding
          child: Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: yearList.length,
              itemBuilder: (context, index) {
                final year = yearList[index];
                final isSelected = selectedYears.contains(year);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(year),
                    selected: isSelected,
                    selectedColor: Colors.blue,
                    onSelected: (_) {
                      setState(() {
                        isSelected
                            ? selectedYears.remove(year)
                            : selectedYears.add(year);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),

        SizedBox(height: 10), // Space between the dropdowns

        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 25.0, vertical: 4.0), // Add padding
          child: Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: monthsList.length,
              itemBuilder: (context, index) {
                final month = monthsList[index];
                final isSelected = selectedMonths.contains(month['id']);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(month['name']),
                    selected: isSelected,
                    selectedColor: Colors.blue,
                    onSelected: (_) {
                      setState(() {
                        isSelected
                            ? selectedMonths.remove(month['id'])
                            : selectedMonths.add(month['id']);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showProjectDetails(BuildContext context, Map<String, dynamic> item,
      String userId, String token) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Text(
                "Project: ${item['desc']}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text("Project ID: ${item['id']}"),
              Text(
                  "Total Hours Worked: ${(int.parse(item['value']) / 60).toStringAsFixed(2)} hrs"),
              SizedBox(height: 10),
              Divider(),
              Text("Tasks Done:",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              // Fetch and display tasks, filtering them by selected month and year
              FutureBuilder<List<Map<String, dynamic>>>(
                future: HomeService.getTasksByEmpId(userId, item['id'], token),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error loading tasks: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text("No tasks found.");
                  }

                  // ✅ Filter tasks based on selected month & year
                  var filteredTasks = snapshot.data!.where((task) {
                    String? taskDate = task['EntryDate'];
                    if (taskDate != null && taskDate.isNotEmpty) {
                      DateTime parsedDate = DateTime.parse(taskDate);
                      return selectedYears
                              .contains(parsedDate.year.toString()) &&
                          selectedMonths.contains(parsedDate.month.toString());
                    }
                    return false;
                  }).toList();

                  if (filteredTasks.isEmpty) {
                    return Text("No tasks found for the selected period.");
                  }

                  return SizedBox(
                    height: 300, // Adjust height as needed
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        var task = filteredTasks[index];
                        return ListTile(
                          title: Text(
                              task['Description'] ?? "No Task Description"),
                          subtitle:
                              Text(
  "${formatEntryDate(task['EntryDate'])}", style: TextStyle(color: Colors.grey),
)

                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
String formatEntryDate(String? rawDate) {
  if (rawDate == null || rawDate.isEmpty) return 'N/A';
  try {
    // Parse raw string
    DateTime date = DateTime.parse(rawDate);
    
    // Format to '10 Apr 2024 - 7:40 PM'
    final formatter = DateFormat('d MMM yyyy - h:mm a');
    return formatter.format(date);
  } catch (e) {
    return 'Invalid date';
  }
}


class BarChartScreen extends StatelessWidget {
  final String empID;
  final HomeService homeService;
  final String token;
  BarChartScreen(
      {required this.empID, required this.homeService, required this.token});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future:
          homeService.getWorksheetChart(empID, token), // Fetching chart data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return WorkDurationBarChart(
            data: snapshot.data!,
            empID: empID,
            token: token,
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }
}

class PendingTasksScreen extends StatefulWidget {
  final String userId;
  final String currentToken;
  final HomeService homeService;

  PendingTasksScreen({
    required this.userId,
    required this.currentToken,
    required this.homeService,
  });

  @override
  _PendingTasksScreenState createState() => _PendingTasksScreenState();
}

class _PendingTasksScreenState extends State<PendingTasksScreen> {
  List<Map<String, dynamic>> pendingTasks = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    NotificationService.saveToken(widget.userId, widget.currentToken);
    widget.homeService
        .fetchPendingTasks(widget.userId, widget.currentToken)
        .then((data) {
      setState(() {
        pendingTasks = data;
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(child: Text("An error occurred while loading tasks."));
    }

    if (pendingTasks.isEmpty) {
      return Center(child: Text("No Pending Tasks"));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: pendingTasks.length,
      itemBuilder: (context, index) {
        final taskGroup = pendingTasks[index];
        final String title = taskGroup["Title"] ?? "No Title";
        final List<dynamic> taskInfo = taskGroup["Info"] ?? [];

        return Card(
          margin: EdgeInsets.all(8.0),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Divider(),
                taskInfo.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: taskInfo.map((task) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Text("Task ID: ${task["tid"]}"),
                                Text(formatDateRange(task["sdate"], task["edate"])),
                                Text("${task["percent"]}% completed"),

                              ],
                            ),
                          );
                        }).toList(),
                      )
                    : Text("No task details available."),
              ],
            ),
          ),
        );
      },
    );
  }
}

String formatDateRange(String? start, String? end) {
  if (start == null || end == null) return "Date unavailable";

  try {
    final DateTime sDate = DateTime.parse(start);
    final DateTime eDate = DateTime.parse(end);

    final String formattedStart = DateFormat('d MMM yyyy').format(sDate);
    final String formattedEnd = DateFormat('d MMM yyyy').format(eDate);

    return "$formattedStart - $formattedEnd";
  } catch (e) {
    return "Invalid date format";
  }
}


class LeaveApprovalContent extends StatefulWidget {
  final String userID;
  final String token;
  final HomeService homeService;

  const LeaveApprovalContent({
    Key? key,
    required this.userID,
    required this.token,
    required this.homeService,
  }) : super(key: key);

  @override
  _LeaveApprovalContentState createState() => _LeaveApprovalContentState();
}

class _LeaveApprovalContentState extends State<LeaveApprovalContent> {
  late Future<List<LeaveApproval>> leaveApprovalFuture;

  @override
  void initState() {
    super.initState();
    leaveApprovalFuture = widget.homeService
        .fetchLeaveApprovalDetails(widget.userID, widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LeaveApproval>>(
      future: leaveApprovalFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No pending leave approvals.'));
        }

        final leaveApprovals = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: leaveApprovals.length,
          itemBuilder: (context, index) {
            final leave = leaveApprovals[index];
            return Card(
              margin: EdgeInsets.all(10.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name: ${leave.empName}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text("${leave.fromDate} - ${leave.toDate} (${leave.days} days)"),
                    Text("Reason: ${leave.reason}"),
                    /*
                    SizedBox(height: 8),
                    Text(
                      "Approver: ${leave.approverName}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Approval Date: ${leave.approveDate ?? 'Pending'}"),
                    */
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
