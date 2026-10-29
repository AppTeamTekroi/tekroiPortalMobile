import '../../analytics/models/analytics_model.dart';

class ProfileModel {
  bool? status;
  ProfileData? data;

  ProfileModel({this.status, this.data});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      status: json['status'],
      data: json['data'] != null
          ? ProfileData.fromJson(json['data'])
          : null,
    );
  }
}
class ProfileData {
  Employee? employee;
  Summary? summary;

  ProfileData({this.employee, this.summary});

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    final summaryRaw = json['summary'] ?? json['activity_summary'];
    return ProfileData(
      employee: json['employee'] != null
          ? Employee.fromJson(Map<String, dynamic>.from(json['employee'] as Map))
          : null,
      summary: summaryRaw is Map
          ? Summary.fromJson(Map<String, dynamic>.from(summaryRaw))
          : null,
    );
  }
}
class Employee {
  String? name;
  String? email;
  String? employeeId;
  String? department;
  String? reportingTo;
  String? reportingEmail;

  Employee({
    this.name,
    this.email,
    this.employeeId,
    this.department,
    this.reportingTo,
    this.reportingEmail,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    final reportingRaw = json['reporting_to'] ?? json['manager'];
    String? reportingName;
    if (reportingRaw is Map) {
      reportingName = reportingRaw['name']?.toString();
    } else {
      reportingName = reportingRaw?.toString();
    }
    return Employee(
      name: json['name'],
      email: json['email'],
      employeeId: json['employee_id'],
      department: json['department'],
      reportingTo: reportingName,
      reportingEmail: json['reporting_email']?.toString() ??
          (reportingRaw is Map ? reportingRaw['email']?.toString() : null),
    );
  }
}