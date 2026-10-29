import 'package:flutter/material.dart';
import 'package:travelPortal/core/utils/helpers.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/routes/route_controller.dart';
import '../../../core/utils/pageStatus.dart';
import '../../../core/utils/size_utils.dart';
import '../../../ui/theme/appColor.dart';
import '../../../ui/widgets/commonAppBar.dart';
import '../../../ui/widgets/commonTextStyles.dart';
import '../../../ui/widgets/custom_search_view.dart';
import '../../../ui/widgets/portal_list_kit.dart';
import 'package:get/get.dart';

import '../controllers/travel_controller.dart';
import '../data/travel_data.dart';
import '../models/travel_model.dart';

class TravelPage extends StatelessWidget {
  const TravelPage({super.key});

  @override
  Widget build(BuildContext context) {
    RouteController routes = Get.find();
    final controller = Get.put(TravelController());
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: CommonTextStyles.commonBoldStyle(
            title: "Travel Logs", weight: FontWeight.w500),
        centerTitle: false,
        actions: [
          InkWell(
            onTap: () => routes.to(Routes.createTravel),
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: EdgeInsets.only(right: 8, top: 8),
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSearchView(
                  hintText: "Search travel...",
                  onChanged: (value) {
                    controller.searchQuery.value = value;
                    controller.applyFilter();

                    print("🔍 SEARCH => $value");
                  },
                ),
                SizedBox(height: 17.h),
                Row(
                  children: [
                    Icon(Icons.filter_alt_outlined),
                    CommonTextStyles.commonBoldStyle(
                        title: "Filter by status:", Size: 17),
                  ],
                ),
                SizedBox(height: 17.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 7,
                    children: [
                      _buildFilterChip("All", "All", controller),
                      _buildFilterChip("Draft", "0", controller),
                      _buildFilterChip("Submitted", "1", controller),
                      _buildFilterChip("Approved", "2", controller),
                      _buildFilterChip("Rejected", "3", controller),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Obx(() {
                  final state = controller.travelState.value;
                  switch (state.status) {
                    case PageStatus.initial:
                    case PageStatus.loading:
                      return const CircularProgressIndicator(
                          color: Colors.black);

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
                      final overview = controller.filteredList;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: overview.length,
                        itemBuilder: (context, index) {
                          final item = overview[index];

                          return GestureDetector(
                              onTap: () => routes.to(Routes.travelDetails, arguments: item),
                              child: _travelCard(item));
                        },
                      );
                  }
                })
              ],
            ),
          )),
    );
  }

  Widget _travelCard(TravelModel item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title + Status
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          item.travelType,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PortalStatusPill(
                          label: item.travelStatus.label,
                          color: item.travelStatus.color,
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    /// Company
                    Text(
                      item.project,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              /// Location Icon
              // if (item.travelMode == "Self")
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.status == 1 ? Colors.blue.shade50 : Colors.yellow.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: item.status == 1 ? Colors.blue : Colors.yellow.shade700,
                  ),
                ),

              // if (item.travelMode == "Taxi")
              //   Container(
              //     padding: const EdgeInsets.all(8),
              //     decoration: BoxDecoration(
              //       color: Colors.yellow.shade50,
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: Icon(
              //       Icons.location_on,
              //       size: 20,
              //       color: Colors.yellow.shade900,
              //     ),
              //   )
            ],
          ),

          Text(
            item.customer ?? '--',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          if(item.travelMode == "Taxi")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${item.travelMode} : \$ ${item.amount}",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              // Text(
              //   item.amount,
              //   style: TextStyle(color: Colors.grey.shade600),
              // ),
            ],
          ),
          // const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200),

          /// Bottom Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.date,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              Text(
              item.timeRange),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildFilterChip(
      String label,
      String filterType,
      TravelController controller,
      ) {
    return Obx(() {
      bool isSelected =
          controller.selectedStatus.value == filterType;

      return GestureDetector(
        onTap: () {
          controller.selectedStatus.value = filterType;
          controller.applyFilter();

          print("🎯 SELECTED FILTER => $filterType");
        },
        child: Container(
          padding:
          EdgeInsets.symmetric(horizontal: 14.h, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.blue
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18.h),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF34353d),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}