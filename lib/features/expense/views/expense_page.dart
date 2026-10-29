import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/routes/route_controller.dart';
import '../../../core/utils/pageStatus.dart';
import '../../../core/utils/size_utils.dart';
import '../../../ui/theme/appColor.dart';
import '../../../ui/widgets/commonTextStyles.dart';
import '../../../ui/widgets/custom_search_view.dart';
import 'package:get/get.dart';

import '../controllers/expenseCreateController.dart';
import '../models/expenseModel.dart';
import 'expenseWidget.dart';
class ExpensePage extends StatelessWidget {
  const ExpensePage({super.key});
  @override
  Widget build(BuildContext context) {
    RouteController routes = Get.find();
    ExpenseController controller = Get.find();
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: CommonTextStyles.commonBoldStyle( title: "Expenses Claim",weight:FontWeight.w500 ),
        centerTitle: false,
        actions: [
          InkWell(
            onTap: () => routes.to(Routes.createExpenses),
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: EdgeInsets.only(right: 8,top: 8),
              decoration: BoxDecoration(
                color: AppColors.green,
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
          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 7),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                CustomSearchView(
                  hintText: "Search expense...",
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
                    CommonTextStyles.commonBoldStyle( title: "Filter by status:",Size: 17),
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
                    ],),

                ),
                SizedBox(height: 20),



          Obx(() {
            final state = controller.expenseState.value;
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
                        onTap: () => routes.to(Routes.expenseDetails, arguments: item),
                        child: ExpenseCard(model: item,));
                  },
                );
            }


        }),
          ]),
    )
    )
    );
          }
          }
Color _getStatusColor(String status) {
  switch (status) {
    case "Approved":
      return AppColors.blue;
    case "Draft":
      return Colors.grey;
    case "Submitted":
      return AppColors.green;
    case "Rejected":
      return Colors.red;
    default:
      return Colors.blue;
  }
}

Widget _buildFilterChip(
    String label,
    String filterType,
    ExpenseController controller,
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

