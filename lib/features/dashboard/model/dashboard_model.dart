import 'dart:ui';

import 'package:flutter/material.dart';

class DashboardModel {
  bool? status;
  String? message;
  DashboardData? data;

  DashboardModel({this.status, this.message, this.data});

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? DashboardData.fromJson(json['data'])
          : null,
    );
  }
}
class DashboardData {
  int? thisMonth;
  int? pendingApproval;
  String? totalExpenses;
  List<RecentActivity> recentActivity;

  DashboardData({
    this.thisMonth,
    this.pendingApproval,
    this.totalExpenses,
    this.recentActivity = const [],
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      thisMonth: json['this_month'],
      pendingApproval: json['pending_approval'],
      totalExpenses: json['total_expenses']?.toString(),
      recentActivity: (json['recent_activity'] as List? ?? [])
          .map((e) => RecentActivity.fromJson(e))
          .toList(),
    );
  }
}
class RecentActivity {
  int? id;
  String? title;
  String? subtitle;
  String? date;
  String? amount;
  int? status;
  String? type;

  RecentActivity({
    this.id,
    this.title,
    this.subtitle,
    this.date,
    this.amount,
    this.status,
    this.type,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      date: json['date'],
      amount: json['amount']?.toString(),
      status: json['status'],
      type: json['type'],
    );
  }
}
String getStatusText(int? status) {
  switch (status) {
    case 0:
      return "Draft";
    case 1:
      return "Submitted";
    case 2:
      return "Approved";
    case 3:
      return "Rejected";
    default:
      return "Unknown";
  }
}

Color getStatusColor(int? status) {
  switch (status) {
    case 0:
      return Colors.grey;
    case 1:
      return Colors.blue;
    case 2:
      return Colors.green;
    case 3:
      return Colors.red;
    default:
      return Colors.grey;
  }
}