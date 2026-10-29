import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/utils/helpers.dart';
import '../../../ui/theme/appColor.dart';

class TravelModel {
  final int id;
  final String date;
  final String checkIn;
  final String? checkOut;
  final String checkInLocation;
  final String? checkOutLocation;
  final String travelType;
  final String travelMode;
  final String customer;
  final String project;
  final String amount;
  final String notes;
  final int status;
  final String createdAt;
  final String updatedAt;
  final String? filePath;

  TravelModel({
    required this.id,
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.checkInLocation,
    this.checkOutLocation,
    required this.travelType,
    required this.travelMode,
    required this.customer,
    required this.project,
    required this.amount,
    required this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.filePath,
  });

  /// ✅ Helper for UI
  bool get isOngoing => checkOut == null || checkOut!.isEmpty;

  String get timeRange {
    if (isOngoing) return "~ Ongoing";
    return "$checkIn - $checkOut";
  }

  TravelStatus get travelStatus {
    switch (status) {
      case 0:
        return TravelStatus.draft;
      case 1:
        return TravelStatus.submitted;
      case 2:
        return TravelStatus.approved;
      case 3:
        return TravelStatus.rejected;
      default:
        return TravelStatus.draft;
    }
  }

  factory TravelModel.fromJson(Map<String, dynamic> json) {
    return TravelModel(
      id: json['id'] ?? 0,
      date: json['travel_date'] ?? '',
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'],
      checkInLocation: json['check_in_location'] ?? '',
      checkOutLocation: json['check_out_location'],
      travelType: json['travel_type'] ?? '',
      travelMode: json['travel_mode'] ?? '',
      customer: json['customer'] ?? '',
      project: json['project'] ?? '',
      amount: json['amount'] ?? '0.00',
      notes: json['notes'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      filePath: json['attachments'] ?? '',
    );
  }
}