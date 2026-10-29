class ExpenseModel {
  int? id;
  int? userId;
  String? date;
  String? expenseType;
  String? currency;
  String? amount;

  String? customerRepresentative;
  String? companyName;
  String? description;

  String? travelMode;
  String? from;
  String? to;
  String? fromDate;
  String? toDate;

  String? hotelName;
  String? hotelLocation;
  String? checkIn;
  String? checkOut;

  String? restaurantDate;
  String? restaurantName;
  String? restaurantLocation;

  String? billReceipt;
  String? attachmentsUrl;

  int? status;

  List<PerDiemEntryModel> entries;

  ExpenseModel({
    this.id,
    this.userId,
    this.date,
    this.expenseType,
    this.currency,
    this.amount,
    this.customerRepresentative,
    this.companyName,
    this.description,
    this.travelMode,
    this.from,
    this.to,
    this.fromDate,
    this.toDate,
    this.hotelName,
    this.hotelLocation,
    this.checkIn,
    this.checkOut,
    this.restaurantDate,
    this.restaurantName,
    this.restaurantLocation,
    this.billReceipt,
    this.attachmentsUrl,
    this.status,
    this.entries = const [],
  });

  /// 🔥 FROM JSON
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      userId: json['user_id'],

      date: json['date'],
      expenseType: json['expense_type'],
      currency: json['currency'],
      amount: json['amount']?.toString(),

      customerRepresentative:
      json['customer_rep'] ?? json['customer_representative'],
      companyName: json['company'] ?? json['company_name'],
      description: json['description'],

      travelMode: json['travel_mode'] ?? json['mode_of_travel'],
      from: json['from'] ?? json['from_location'],
      to: json['to'] ?? json['to_location'],
      fromDate: json['from_date'],
      toDate: json['to_date'],

      hotelName: json['hotel_name'],
      hotelLocation: json['hotel_location'],
      checkIn: json['check_in'],
      checkOut: json['check_out'],

      restaurantDate: json['restaurant_date'],
      restaurantName: json['restaurant_name'],
      restaurantLocation: json['restaurant_location'],

      billReceipt: json['bill_receipt'],
      attachmentsUrl: json['attachments_url'],

      status: json['status'],

      entries: (json['entries'] as List? ?? [])
          .map((e) => PerDiemEntryModel.fromJson(e))
          .toList(),
    );
  }

  /// 🔥 TO JSON (optional for update)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "date": date,
      "expense_type": expenseType,
      "currency": currency,
      "amount": amount,
      "customer_representative": customerRepresentative,
      "company_name": companyName,
      "description": description,
      "travel_mode": travelMode,
      "from": from,
      "to": to,
      "from_date": fromDate,
      "to_date": toDate,
      "hotel_name": hotelName,
      "hotel_location": hotelLocation,
      "check_in": checkIn,
      "check_out": checkOut,
      "restaurant_date": restaurantDate,
      "restaurant_name": restaurantName,
      "restaurant_location": restaurantLocation,
      "bill_receipt": billReceipt,
      "attachments_url": attachmentsUrl,
      "status": status,
      "entries": entries.map((e) => e.toJson()).toList(),
    };
  }
}


class PerDiemEntryModel {
  int? id;
  int? expenseId;

  String? monthYear;
  String? location;
  String? startDate;
  String? endDate;
  String? amount;
  String? details;

  PerDiemEntryModel({
    this.id,
    this.expenseId,
    this.monthYear,
    this.location,
    this.startDate,
    this.endDate,
    this.amount,
    this.details,
  });

  factory PerDiemEntryModel.fromJson(Map<String, dynamic> json) {
    return PerDiemEntryModel(
      id: json['id'],
      expenseId: json['expense_id'],
      monthYear: json['month_year'],
      location: json['location'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      amount: json['amount']?.toString(),
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "expense_id": expenseId,
      "month_year": monthYear,
      "location": location,
      "start_date": startDate,
      "end_date": endDate,
      "amount": amount,
      "details": details,
    };
  }
}