
import 'dart:io' show File;

class LeaveApproval {
  final String empID;
  final String empName;
  final String fromDate;
  final String toDate;
  final String days;
  final String reason;
  final String? note;
  final String? approver;
  final String? approverName;
  final String? approveDate;
  final String status;

  LeaveApproval({
    required this.empID,
    required this.empName,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.reason,
    required this.note,
    required this.approver,
    required this.approverName,
    this.approveDate,
    required this.status,
  });

  factory LeaveApproval.fromJson(Map<String, dynamic> json) {
  return LeaveApproval(
    empID: json['empid'] ?? '',
    empName: json['empname'] ?? '',
    fromDate: json['fromdate'] ?? '',
    toDate: json['todate'] ?? '',
    days: json['days'] ?? '',
    reason: json['reason'] ?? '',
    note: json['note'],  // nullable already
    approver: json['approver'],
    approverName: json['approvername'],
    approveDate: json['approvedate'],
    status: json['status'] ?? '', // might be null in this query
  );
}

}

class Customer {
  final String cuscode,
      cusname,
      add1,
      add2,
      add3,
      add4,
      phone,
      email,
      web,
      country,
      status,
      vatno;

  Customer({
    required this.cuscode,
    required this.cusname,
    required this.add1,
    required this.add2,
    required this.add3,
    required this.add4,
    required this.phone,
    required this.email,
    required this.web,
    required this.country,
    required this.status,
    required this.vatno,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        cuscode: json['cuscode'] ?? '',
        cusname: json['cusname'] ?? '',
        add1: json['add1'] ?? '',
        add2: json['add2'] ?? '',
        add3: json['add3'] ?? '',
        add4: json['add4'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        web: json['web'] ?? '',
        country: json['country'] ?? '',
        status: json['status'] ?? '',
        vatno: json['vatno'] ?? '',
      );
}
class WorkEntry {
  final String wsid;
  final String wsdate;
  final String workType;
  final String projectDesc;
  final String taskDesc;
  final String taskId;
  final String taskPercent;
  final String workDesc;
  final String entryDate;
  final String comments;

  WorkEntry({
    required this.wsid,
    required this.wsdate,
    required this.workType,
    required this.projectDesc,
    required this.taskDesc,
    required this.taskId,
    required this.taskPercent,
    required this.workDesc,
    required this.entryDate,
    required this.comments,
  });

  factory WorkEntry.fromJson(Map<String, dynamic> json) {
  return WorkEntry(
    wsid: json['wsid'] ?? 0, // Default to 0 for ID if null
    wsdate: json['wsdate'] ?? 'Unknown Date', // Provide default string
    workType: json['wtype'] ?? 'Unknown', // Avoid null error
    projectDesc: json['pdesc'] ?? 'No Project',
    taskDesc: json['tdesc'] ?? 'No Task',
    taskId: json['tid']?.toString() ?? 'N/A', // Convert null taskId to 'N/A'
    taskPercent: json['tper'] ?? '0.0', // Ensure numeric conversion
    workDesc: json['wdesc'] ?? 'No Description',
    entryDate: json['edate'] ?? 'No Date',
    comments: json['comm'] ?? 'No Comments',
  );
}

}

class WorkDate {
  final String title;
  final List<WorkEntry> entries;

  WorkDate({required this.title, required this.entries});

  factory WorkDate.fromJson(Map<String, dynamic> json) {
  return WorkDate(
    title: json["Title"] ?? "No Title",
    entries: (json["Info"] as List<dynamic>)
        .map((entry) => WorkEntry.fromJson(entry))
        .toList(),
  );
}

}

class AttendanceEntry {
  final String date;
  final String day;
  final String name;
  final String inTime;
  final String outTime;
  final String hours;
  final String reason;

  AttendanceEntry({
    required this.date,
    required this.day,
    required this.name,
    required this.inTime,
    required this.outTime,
    required this.hours,
    required this.reason,
  });

  /// Factory method to convert JSON into an AttendanceEntry object
  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceEntry(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      name: json['name'] ?? '',
      inTime: json['in'] ?? '',
      outTime: json['out'] ?? '',
      hours: json['hours'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}

class AttendanceData {
  final String title;
  final List<AttendanceEntry> info;

  AttendanceData({required this.title, required this.info});

  /// Factory method to convert a single JSON object into an AttendanceData object
  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    var list = json['Info'] as List? ?? []; // ✅ Extract list safely
    List<AttendanceEntry> infoList =
        list.map((entry) => AttendanceEntry.fromJson(entry as Map<String, dynamic>)).toList();

    return AttendanceData(
      title: json['Title'] ?? '',
      info: infoList,
    );
  }

  /// New factory method to handle API response (which is a list of objects)
  static List<AttendanceData> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((item) => AttendanceData.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

class Task {
  final String taskId;
  final String taskType;
  final String? taskDesc;
  final String? startDate;
  final String? endDate;
  final String? duration;
  final String? taskStatus;
  final String? percentComplete;
  final String? assignedTo;
  final String? assignedName;
  final String? remarks;
  final String? projectId;
  final String? attachment;
  final String? nTaskType;
  final String? status;

  Task({
    required this.taskId,
    required this.taskType,
    this.taskDesc,
    this.startDate,
    this.endDate,
    this.duration,
    this.taskStatus,
    this.percentComplete,
    this.assignedTo,
    this.assignedName,
    this.remarks,
    this.projectId,
    this.attachment,
    this.nTaskType,
    this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['taskid'],
      taskType: json['tasktype'],
      taskDesc: json['taskdesc'],
      startDate: json['sdate'],
      endDate: json['edate'],
      duration: json['duration'],
      taskStatus: json['taskstatus'],
      percentComplete: json['percent'],
      assignedTo: json['ato'],
      assignedName: json['aname'],
      remarks: json['remark'],
      projectId: json['pid'],
      attachment: json['attachment'],
      nTaskType: json['ntasktype'],
      status: json['status'],
    );
  }
}

class TaskDetails {
  final String? taskId;
  final String projectId;
  final String taskType;
  final String taskDesc;
  final String startDate;
  final String endDate;
  final String assignedTo;
  final String createdBy;
  final File? file;

  TaskDetails({
    this.taskId,
    required this.projectId,
    required this.taskType,
    required this.taskDesc,
    required this.startDate,
    required this.endDate,
    required this.assignedTo,
    required this.createdBy,
    this.file,
  });
}

class Project {
  final String projectId;
  final String projectDesc;

  Project({required this.projectId, required this.projectDesc});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['sCode'],
      projectDesc: json['sDesc'],
    );
  }
}

class Employee {
  final String empId;
  final String empName;

  Employee({required this.empId, required this.empName});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      empId: json['sCode'],
      empName: json['sDesc'],
    );
  }
}

class TaskType {
  final String taskTypeId;
  final String taskTypeDesc;

  TaskType({required this.taskTypeId, required this.taskTypeDesc});

  factory TaskType.fromJson(Map<String, dynamic> json) {
    return TaskType(
      taskTypeId: json['sCode'],
      taskTypeDesc: json['sDesc'],
    );
  }
}


