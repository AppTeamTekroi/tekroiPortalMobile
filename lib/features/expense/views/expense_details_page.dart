import 'package:flutter/material.dart';
import 'package:travelPortal/core/utils/size_utils.dart';
import 'package:travelPortal/features/expense/controllers/expenseCreateController.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/routes/route_controller.dart';
import '../../../ui/theme/appColor.dart';
import '../../../ui/widgets/containerWidgets.dart';
import '../models/expenseModel.dart';
import 'package:get/get.dart';

class ExpenseDetailsPage extends StatelessWidget {
  const ExpenseDetailsPage({super.key});

  Future<void> _launchURL(url) async {
    print(url);
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  }

  /// 🔹 Common Row
  Widget row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              (value == null || value.isEmpty) ? "-" : value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Section Card
  Widget section(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  double parseAmount(String? amt) {
    return double.tryParse(amt ?? "0") ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    RouteController routes = Get.find();

    final ExpenseModel model = routes.arguments as ExpenseModel;
    final type = model.expenseType?.toLowerCase();
    final ExpenseController controller = Get.find();
    Color getStatusColor() {
      switch (model.status?.toString()) {
        case "0":
          return Colors.grey; // Draft
        case "1":
          return Colors.blue; // Submitted
        case "2":
          return Colors.green; // Approved
        case "3":
          return Colors.red; // Rejected
        default:
          return Colors.grey;
      }
    }

    String getStatusText() {
      switch (model.status?.toString()) {
        case "0":
          return "Draft";
        case "1":
          return "Submitted";
        case "2":
          return "Approved";
        case "3":
          return "Rejected";
        default:
          return "Unknown";
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: ContainerWidget.backContainer(
            () => routes.back(), "Expense Log Details"),
        actions: [
          if (model.status == 0)
            InkWell(
              onTap: () {
                controller.copyToEditExpense(model);
                routes.to(Routes.editExpenses);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.edit,
                  color: AppColors.blue,
                ),
              ),
            ),
          if (model.status == 0)
              InkWell(
                onTap: () {
                  controller.deleteTravel(model.id.toString());
                }, child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                ),
              ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          spacing: 5,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Status",
                      style:
                          const TextStyle(color: Colors.black, fontSize: 15)),
                  _statusBadge(getStatusText(), getStatusColor()),
                ],
              ),
            ),

            Container(
              width: SizeUtils.width,
              margin: const EdgeInsets.only(bottom: 5),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Text("Claim Amount",
                      style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 6),
                  Text(
                    "${model.amount}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text("INR"), // static or add in model if needed
                ],
              ),
            ),

            /// 🔹 BASIC INFO
            section("Expense Details", [
              row("Type", model.expenseType ?? ""),
              row("Date", model.date ?? ""),

              /// 🎫 TICKET
              // if (model.expenseType == "Ticket") ...[
              //   row("Travel Mode", model.travelMode ?? ""),
              //   row("Travel", "${model.from ?? ""} - ${model.to ?? ""}"),
              //   row("On", "${model.fromDate ?? ""} - ${model.toDate ?? ""}"),
              //
              //   // row("To", model.to ?? ""),
              //   // row("From Date", model.fromDate ?? ""),
              //   // row("To Date", model.toDate ?? ""),
              // ],
              //
              // /// 🏨 HOTEL
              // if (model.expenseType == "Hotel") ...[
              //   row("Hotel Name", model.hotelName ?? ""),
              //   row("Location", model.hotelLocation ?? ""),
              //   row("Check In", model.checkIn ?? ""),
              //   row("Check Out", model.checkOut ?? ""),
              // ],

              /// 💰 PER DIEM
              // if (model.expenseType == "Per_Diem") ...[
              //   ...model.entries.map((e) => Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       row("Month & Year", e.monthYear ?? ""),
              //       row("Location", e.location ?? ""),
              //       row("Start Date", e.startDate ?? ""),
              //       row("End Date", e.endDate ?? ""),
              //       row("Amount",
              //           "₹${double.tryParse(e.amount ?? "0")?.toStringAsFixed(2) ?? "0.00"}"),
              //       row("Details", e.details ?? ""),
              //       const Divider(),
              //     ],
              //   )),
              // ],

              /// 🍽 RESTAURANT
              // if (model.expenseType == "Restaurant") ...[
              //   row("Visit On", model.restaurantDate ?? ""),
              //   row("Restaurant Name", model.restaurantName ?? ""),
              //   row("Location", model.restaurantLocation ?? ""),
              // ],
            ]),

            section("Customer Information", [
              // row("Date", model.date),
              // row("Type", model.expenseType),
              // row("Amount",
              //     "₹${parseAmount(model.amount).toStringAsFixed(2)}"),
              row("Company", model.companyName),
              row("Representative", model.customerRepresentative),
              // row("Description", model.description),
            ]),
            section("Description", [
              row("Description", model.description ?? '--'),
            ]),

            /// 🎫 TICKET DETAILS
            if (type == "ticket")
              section("Travel Details", [
                row("From", model.from),
                row("To", model.to),
                row("Travel Mode", model.travelMode),
                row("From Date", model.fromDate),
                row("To Date", model.toDate),
              ]),

            /// 🏨 HOTEL DETAILS
            if (type == "hotel")
              section("Hotel Details", [
                row("Hotel Name", model.hotelName),
                row("Location", model.hotelLocation),
                row("Check In", model.checkIn),
                row("Check Out", model.checkOut),
              ]),

            /// 💰 PER DIEM DETAILS
            if (type == "per diem" || model.entries.isNotEmpty)
              section("Per Diem Entries", [
                ...model.entries.map((e) {
                  return Container(
                    // margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    // decoration: BoxDecoration(
                    //   color: Colors.grey.shade50,
                    //   borderRadius: BorderRadius.circular(10),
                    //   border:
                    //   Border.all(color: Colors.grey.shade300),
                    // ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        row("Month", e.monthYear),
                        row("Location", e.location),
                        row("Start Date", e.startDate),
                        row("End Date", e.endDate),
                        row("Details", e.details),
                        row(
                          "Amount",
                          "₹${parseAmount(e.amount).toStringAsFixed(2)}",
                        ),
                        Divider()
                      ],
                    ),
                  );
                }).toList(),

                /// 🔥 TOTAL
                if (model.entries.isNotEmpty)
                  Builder(builder: (_) {
                    double total = model.entries
                        .fold(0, (sum, e) => sum + parseAmount(e.amount));
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Total: ₹${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }),
              ]),

            /// 📎 ATTACHMENT
            // if ((model.attachmentsUrl ?? "").isNotEmpty)
            section("Bill/Receipt", [
              (model.attachmentsUrl != null)
                  ? GestureDetector(
                      onTap: () {
                        _launchURL(model.attachmentsUrl);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "${model.expenseType}-bill.pdf",
                            // style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        Text("No Attachment Found"),
                      ],
                    )
            ]),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 13,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
