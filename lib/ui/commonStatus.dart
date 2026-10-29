
import 'package:flutter/material.dart';
import 'package:travelPortal/ui/theme/appColor.dart';


String getServiceText(int status) {
  switch (status) {
    case 1:
      return "Service";
    case 2:
      return "PMS";
    case 3://Reject
      return "Enquiry";
    default:
      return "--";
  }
}

String getStatusText(int status) {
  switch (status) {
    case 0:
      return "Waiting for Approval";
    case 1:
      return "Pending";
    case 2:
      return "Approved";
    case 3://Reject
      return "Pending";
    case 4:
      return "En route";
    case 5:
      return "In Progress";
    case 6:
      return "Part Await";
    case 7:
      return "Part Approval";
    case 8:
      return "Part Reject";
    case 9:
      return "Closed";
    case 10:
      return "Waiting to close Service";
    default:
      return "issue";
  }
}

Color getStatusColor(int status) {
  switch (status) {
    case 0:
      return Color(0xFFCC934C); // Pending
    case 1:
      return Color(0xFFCC934C); // Assigned
    case 2:
      return Color(0xFF17B54C); // Approved
    case 3:
      return Color(0xFFCC934C); // Reject
    case 4:
      return Color(0xFFCC934C); // Enroute
    case 5:
      return Color(0xFF17B54C); // In Progress
    case 6:
      return Color(0xFFFA5C52); // Part Request/Await
    case 7:
      return Color(0xFF17B54C); // Part Approval
    case 8:
      return Color(0xFFFA5C52); // Part Reject
    case 9:
      return AppColors.primary;
    case 10:
      return AppColors.primary;// Closed
    default:
      return Colors.grey;
  }
}
