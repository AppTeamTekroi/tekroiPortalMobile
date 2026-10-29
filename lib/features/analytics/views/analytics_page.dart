import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelPortal/features/analytics/controllers/analytics_controller.dart';
import 'package:travelPortal/features/login/controller/login_controller.dart';

import '../../../core/routes/route_controller.dart';
import '../../../core/utils/pageStatus.dart';
import '../../../ui/theme/appColor.dart';
import '../../../ui/widgets/containerWidgets.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/analytics_model.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    RouteController routes = Get.find();
    final AnalyticsController controller = Get.find();

    // Refresh when opening analytics (covers cold start before login).
    if (controller.analyticsState.value.status == PageStatus.initial ||
        controller.analyticsState.value.status == PageStatus.error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.find<LoginController>().UserId != null &&
            Get.find<LoginController>().UserId != 0) {
          controller.loadAnalytics();
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      // appBar: AppBar(title: const Text("Dashboard")),

      body: Obx(() {
        final state = controller.analyticsState.value;
        switch (state.status) {
          case PageStatus.initial:
          case PageStatus.loading:
            return const CircularProgressIndicator(color: Colors.black);

          case PageStatus.error:
            return Text(
              state.error ?? "Error",
              style: const TextStyle(color: Colors.black),
            );

          case PageStatus.empty:
            return const Text(
              "No Data",
              style: TextStyle(color: Colors.black),
            );

          case PageStatus.success:
            final overview = state.data!;
            final summary = overview.summary;
            final trend = overview.travelTrend;
            final expenseTypes = overview.expenseByType;
            final travelTypes = overview.travelByType;
            final customers = overview.topCustomers;

            for (var e in expenseTypes) {
              print("Type: ${e.type}, Total: ${e.total}");

            }            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerWidget.backContainer(
                      () => routes.back(), "Analytics & Reports"),

                  // Text(
                  //   "Analytics & Reports",
                  //   style: TextStyle(
                  //     color: Colors.black,
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w400,
                  //   ),
                  // ),
                  SizedBox(height: 4),
                  Text(
                    "Your travel and Expense insights",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(height: 12),

                  /// 🔹 Top Cards
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.location_on,
                          "${summary?.totalTravels ?? 0}",
                          "Total Travels",
                          AppColors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          Icons.trending_up,
                          "${summary?.approved ?? 0}",
                          "Approved",
                          AppColors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.attach_money,
                          "₹${summary?.totalExpenses ?? "0"}",
                          "Total Expens",
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          Icons.calendar_today,
                          "₹${summary?.pending ?? "0"}",
                          "Pending",
                          AppColors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// 🔹 Travel Trend
                  // _card(
                  //   "Travel Trend (Last 6 Months)",
                  //   SizedBox(
                  //     height: 200,
                  //     child: _barChartPlaceholder(),
                  //   ),
                  // ),

                  _card(
                    "Travel Trend (Last 6 Months)",
                    SizedBox(
                      height: 220,
                      child: trend.isEmpty
                          ? const Center(child: Text("No Data"))
                          : _travelBarChart(trend),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// 🔹 Pie Charts Row
                  // _card(
                  //   "Expense by Type",
                  //   _piePlaceholder("Hotel 100%"),
                  // ),

                  _card(
                    "Expense by Type",
                    Column(
                      children: [
                        SizedBox(
                          height: 220, // 🔥 must give height
                          child: expenseTypes.isEmpty
                              ? const Center(child: Text("No Data"))
                              : _expensePieChart(expenseTypes),
                        ),
                        ...expenseTypes.map((e) => Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                              Icons.circle,color: Colors.blue,size: 15,),
                            ),
                            Text(
                              "${e.type?.toUpperCase()}",
                            ),
                            Spacer(),
                            Text(
                              "${e.total}",
                            ),
                          ],
                        )),
                      ],
                    )

                  ),
                  const SizedBox(height: 16),

                  _card(
                    "Travel by Type",
                    Column(
                      children: [
                        SizedBox(
                          height: 220, // 🔥 must give height
                          child: travelTypes.isEmpty
                              ? const Center(child: Text("No Data"))
                              : _expensePieChart(travelTypes),
                        ),
                        ...travelTypes.map((e) => Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.circle,color: Colors.blue,size: 15,),
                            ),
                            Text(
                              "${e.type?.toUpperCase()}",
                            ),
                            Spacer(),
                            Text(
                              "${e.total}",
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 🔹 Top Customers
                  // _card(
                  //   "Top Customers by Visits",
                  //   Column(
                  //     children: [
                  //       _customerItem(1, "Acme Corporation", 1),
                  //       _customerItem(2, "TechGlobal Inc", 1),
                  //       _customerItem(3, "Innovation Partners", 1),
                  //     ],
                  //   ),
                  // ),

        _card(
        "Top Customers by Visits",
        customers.isEmpty
        ? const Center(child: Text("No Data"))
            : Column(
        children: List.generate(customers.length, (index) {
        final c = customers[index];

        return _customerItem(
        index + 1,
        c.name ?? "Unknown",
        (c.total ?? 0).toInt(),
        );
        }),
        ),
        ),
                ],
              ),
            );
        }
      }),
    );
  }

  /// 🔹 Stat Card
  Widget _statCard(IconData icon, String value, String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryText),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 5,
            children: [
              Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(7)),
                  child: Icon(
                    icon,
                    color: color,
                    size: 15,
                  )),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// 🔹 Main Card
  Widget _card(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// 🔹 Bar Chart Placeholder
  Widget _barChartPlaceholder() {
    return Center(
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text("Bar Chart")),
      ),
    );
  }

  /// 🔹 Pie Placeholder
  Widget _expensePieChart(List<TypeData> expenseTypes) {
    double total = expenseTypes.fold(
      0,
          (sum, item) => sum + (item.total ?? 0),
    );

    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40, // 🔥 important

        sections: List.generate(expenseTypes.length, (i) {
          final e = expenseTypes[i];
          final value = e.total ?? 0;

          final percent = total == 0 ? 0 : (value / total) * 100;

          return PieChartSectionData(
            color: colors[i % colors.length], // 🔥 must have color
            value: value,
            title: "${percent.toStringAsFixed(0)}%",
            radius: 60, // 🔥 bigger radius
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
      ),
    );
  }

  /// 🔹 Customer Item
  Widget _customerItem(int index, String name, int visits) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.deepPurpleAccent.withOpacity(0.1),
            child: Text("$index"),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("$visits",
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
              const Text("visits", style: TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
  Widget _travelBarChart(List<TravelTrend> trend) {
    return BarChart(
      BarChartData(
        maxY: 8, // 🔥 fixed Y axis (0–8)
        alignment: BarChartAlignment.spaceAround,

        /// ✅ GRID LINES
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),

        /// ✅ BORDER
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),

        /// ✅ X & Y AXIS
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= trend.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    trend[value.toInt()].month ?? "",
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),

          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),

        /// ✅ BARS
        barGroups: List.generate(trend.length, (index) {
          final item = trend[index];

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (item.total ?? 0).toDouble(),
                width: 14,
                borderRadius: BorderRadius.circular(4),
                color: AppColors.primary,
              ),
            ],
          );
        }),
      ),
    );
  }
}
