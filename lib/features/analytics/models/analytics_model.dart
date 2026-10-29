class AnalyticsModel {
  Summary? summary;
  List<TravelTrend> travelTrend;
  List<TypeData> expenseByType;
  List<TypeData> travelByType;
  List<TopCustomer> topCustomers;

  AnalyticsModel({
    this.summary,
    this.travelTrend = const [],
    this.expenseByType = const [],
    this.travelByType = const [],
    this.topCustomers = const [],
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    // Support both `{ summary, ... }` and `{ status, data: { summary, ... } }`.
    final Map<String, dynamic> root = json['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final trendList = _parseTravelTrend(root['travel_trend']);

    return AnalyticsModel(
      summary: root['summary'] != null
          ? Summary.fromJson(Map<String, dynamic>.from(root['summary'] as Map))
          : null,
      travelTrend: TravelTrend.ensureLast6Months(trendList),
      expenseByType: _parseTypeList(root['expense_by_type']),
      travelByType: _parseTypeList(root['travel_by_type']),
      topCustomers: _parseCustomers(root['top_customers']),
    );
  }

  static List<TravelTrend> _parseTravelTrend(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw.map((e) {
        if (e is Map) {
          return TravelTrend.fromJson(Map<String, dynamic>.from(e));
        }
        return TravelTrend(month: e.toString(), total: 0);
      }).toList();
    }

    if (raw is Map) {
      return raw.entries.map((e) {
        final value = e.value;
        if (value is Map) {
          final map = Map<String, dynamic>.from(value);
          map.putIfAbsent('month', () => e.key.toString());
          return TravelTrend.fromJson(map);
        }
        return TravelTrend(
          month: e.key.toString(),
          total: int.tryParse(value.toString()) ?? 0,
        );
      }).toList();
    }

    return [];
  }

  static List<TypeData> _parseTypeList(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => TypeData.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static List<TopCustomer> _parseCustomers(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => TopCustomer.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
class Summary {
  int? totalTravels;
  int? approved;
  String? totalExpenses;
  String? pending;

  Summary({
    this.totalTravels,
    this.approved,
    this.totalExpenses,
    this.pending,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalTravels: _toInt(
        json['total_travels'] ??
            json['total_travel_logs'] ??
            json['travels'] ??
            json['totalTravels'],
      ),
      approved: _toInt(json['approved'] ?? json['approved_count']),
      totalExpenses: (json['total_expenses'] ?? json['totalExpenses'])
          ?.toString(),
      pending: (json['pending'] ?? json['pending_count'])?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
}
class TravelTrend {
  String? month;
  int? total;

  TravelTrend({this.month, this.total});

  factory TravelTrend.fromJson(Map<String, dynamic> json) {
    return TravelTrend(
      month: json['month'],
      total: json['total'],
    );
  }

  // 🔥 Convert month → index for sorting
  int get monthIndex {
    const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return months.indexOf(month ?? "");
  }
  static List<TravelTrend> ensureLast6Months(List<TravelTrend> list) {
    const months = [
      "Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"
    ];

    final now = DateTime.now();
    List<String> last6Months = List.generate(6, (i) {
      int m = now.month - (5 - i);
      if (m <= 0) m += 12;
      return months[m - 1];
    });

    Map<String, TravelTrend> map = {
      for (var e in list) e.month ?? "": e
    };

    return last6Months.map((m) {
      return map[m] ?? TravelTrend(month: m, total: 0);
    }).toList();
  }
}
class TypeData {
  String? type;
  double? total;

  TypeData({this.type, this.total});

  factory TypeData.fromJson(Map<String, dynamic> json) {
    return TypeData(
      type: json['expense_type']?.toString() ??
          json['travel_type']?.toString() ??
          json['type']?.toString() ??
          json['name']?.toString(),
      total: double.tryParse(
            (json['total'] ?? json['amount'] ?? json['count'] ?? 0).toString(),
          ) ??
          0,
    );
  }
}
class TopCustomer {
  String? name;
  double? total;

  TopCustomer({this.name, this.total});

  factory TopCustomer.fromJson(Map<String, dynamic> json) {
    return TopCustomer(
      name: json['customer']?.toString() ??
          json['name']?.toString() ??
          json['customer_name']?.toString(),
      total: double.tryParse(
            (json['visits'] ?? json['total'] ?? json['count'] ?? 0).toString(),
          ) ??
          0,
    );
  }
}