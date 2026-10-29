import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelPortal/core/constants/api_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/routes/route_controller.dart';
import '../../../core/utils/helpers.dart';
import '../../../ui/theme/appColor.dart';
import '../../../ui/widgets/containerWidgets.dart';
import '../../expense/views/expenseWidget.dart';
import '../controllers/travel_controller.dart';
import '../models/travel_model.dart';

class TravelDetailsPage extends StatelessWidget {
  const TravelDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    RouteController routes = Get.find();
    final TravelModel data = routes.arguments as TravelModel;
    final controller = Get.put(TravelController());
    Future<void> _launchURL(url) async {
      print(url);
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception("Could not launch $url");
      }
    }
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: ContainerWidget.backContainer(
            () => routes.back(), "Travel Log Details"),
        // centerTitle: false,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios),
        //   onPressed: () => routes.back,
        // ),

        actions: [
          if (data.status == 0)
            InkWell(
              onTap: () {
                controller.copyToEditTravel(data);
                routes.to(Routes.editTravel);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.edit,
                  color: AppColors.blue,
                ),
              ),
            ),
          if (data.status == 0)
            InkWell(
              onTap: () {
                controller.deleteTravel(data.id.toString());
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          spacing: 5,
          children: [
            /// 🔹 Notes
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
                  _statusBadge(
                      data.travelStatus.label, data.travelStatus.color),
                ],
              ),
            ),

            /// 🔹 Date & Time
            _sectionCard(
              "Date & Time",
              Column(
                children: [
                  _infoRow("Date", data.date),
                  _infoRow("Check-in", data.checkIn),
                  _infoRow("Check-out", data.checkOut),
                ],
              ),
            ),

            /// 🔹 Travel Details
            _sectionCard(
              "Travel Details",
              Column(
                children: [
                  _infoRow("Type", data.travelType),
                  _infoRow("Customer", data.customer),
                  _infoRow("Project", data.project),
                ],
              ),
            ),

            /// 🔹 Transportation
            _sectionCard(
              "Transportation",
              Column(
                children: [
                  _infoRow("Mode", data.travelMode),
                  if(data.travelMode == "Taxi")


          (data.filePath != null && data.filePath != "")
              ?
          GestureDetector(

            onTap: () {
              _launchURL("${ApiConstants.mediaBaseUrl}${data.filePath}");
            },
            child: Row(
              children: [
                Icon(Icons.receipt,),
                SizedBox(width: 6),
                Text(
                  "-taxi bill.pdf",
                  // style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ):
          Row(
            children: [
              Text("No Attachment Found"),
            ],
          )
                ],
              ),
            ),

            /// 🔹 Notes
            _sectionCard(
              "Notes",
              Text(
                data.notes,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Section Card (reuse same design)
  Widget _sectionCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  /// 🔹 Label + Value row
  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.black, fontSize: 15)),
          Flexible(
            child: Text(
              value ?? "-",
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
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
