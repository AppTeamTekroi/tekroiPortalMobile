import 'package:flutter/material.dart';
import 'package:travelPortal/features/expense/controllers/expenseCreateController.dart';
import 'package:travelPortal/ui/widgets/AppUploads.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/routes/route_controller.dart';
import '../../../core/utils/pageStatus.dart';
import '../../../core/utils/size_utils.dart';
import 'package:get/get.dart';

import '../../../ui/theme/appColor.dart';
import '../../../ui/widgets/AppDateField.dart';
import '../../../ui/widgets/AppDropdown.dart';
import '../../../ui/widgets/AppLaunchUrl.dart';
import '../../../ui/widgets/AppTextField.dart';
import '../../../ui/widgets/button.dart';
import '../../../ui/widgets/commonTextStyles.dart';
import '../../../ui/widgets/containerWidgets.dart';
import 'package:intl/intl.dart';

import '../../../ui/widgets/shimmer.dart';
import '../../travel/controllers/travel_controller.dart';

class EditExpensePage extends StatelessWidget {
  const EditExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    ExpenseController controller = Get.find();
    TravelController travelController = Get.find();
    RouteController routes = Get.find();
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          controller.clearForm();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade100,
          centerTitle: false,
          automaticallyImplyLeading: true,
          title: ContainerWidget.backContainer(
                  () => routes.back(), "Edit Expense Log"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Basic Info
              _sectionCard(
                "Basic Information",
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    RichText(
                      maxLines: 3,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        text: "Date",
                        style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w500,),
                        children: [
                          TextSpan(
                            text: " *",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(controller.dateController.text,
                            style: TextStyle(color: Colors.black),
                          ),
                          Icon(Icons.access_time),
                        ],
                      ),
                    ),

                    // AppDateField(
                    //     controller: controller.dateController,
                    //     label: "Date",
                    //     color: Colors.red
                    // ),

                    const SizedBox(height: 16),

                    _label("Expense Type", color: Colors.red),
                    const SizedBox(height: 10),

                    /// ✅ Expense Toggle
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.expenseList.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 3.5,
                      ),
                      itemBuilder: (context, index) {
                        final item = controller.expenseList[index];

                        return Obx(
                                () => ContainerWidget.commonSelectableContainer(
                              selected: controller.expenseType.value == item,
                              label: item,
                              onTap: () => controller.setExpenseType(item),
                            ));
                      },
                    ),

                    const SizedBox(height: 16),

                    /// ✅ Currency
                    Obx(() => AppDropdown(
                        label: "Currency",
                        color: Colors.red,
                        value: controller.currency.value,
                        items: ["USD (\$)", "INR (₹)", "EUR (€)"],
                        onChanged: (val) {
                          controller.currency.value = val;
                        })),

                    const SizedBox(height: 16),

                    AppTextField(
                      controller: controller.amountController,
                      hint: "0.00",
                      label: "Amount",
                      color: Colors.red,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),

              /// 🔹 Customer Details
              _sectionCard(
                "Customer Details",
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Expense claims are allowed when traveling with a customer representative",
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 16),
                    Obx(() {
                      if (travelController.customerState.value.status == PageStatus.loading) {
                        return shimmerBox(40);
                      }

                      final models = travelController.customerState.value.data;

                      final uniqueCustomers = models["customers"] ?? [];
                      final customers = uniqueCustomers.toSet().toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Customer Dropdown
                          AppDropdown(
                            label: "Customer",
                            value: customers
                                .contains(controller.customer.value)
                                ? controller.customer.value
                                : "",
                            hint: "Select Customer",
                            items: customers,
                            onChanged: (val) {
                              controller.customer.value = val;
                            },
                          ),
                        ],
                      );
                    }
                    ),
                  ],
                ),
              ),

              /// 🔹 Details
              _sectionCard(
                "Details",
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                        controller: controller.descriptionController,
                        hint: "Provide details about the expense...",
                        label: "Description",
                        color: Colors.red),
                    const SizedBox(height: 16),
                    _label("Bill/Receipt", color: Colors.red),
                    UploadBox(
                      showPicker: controller.showPicker.value,
                      onTap: () {
                        controller.showPicker.value = true;
                      },
                      onFileSelected: (file) {
                        controller.file = file;
                        print("🔥 CONTROLLER FILE => ${file.path}");
                      },
                      onFileRemoved: (){
                        controller.file = null;
                        controller.showPicker.value = false;
                      },
                    ),

                    if(controller.serverFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            FileLinkWidget(
                              url: controller.serverFile,
                              title: "View Attachment",
                            ),
                            Text("Note: If you want to replaced the file only upload bill",style: TextStyle(fontSize: 11,color: Colors.grey),)
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              Obx(() {
                switch (controller.expenseType.value) {
                  case "Ticket":
                    return _ticketSection(controller);

                  case "Hotel":
                    return _hotelSection(controller);

                  case "Restaurant":
                    return _restaurantSection(controller);

                  case "Per_Diem":
                    return _perDiemSection(controller);

                  default:
                    return const SizedBox();
                }
              }),

              /// 🔹 Ticket Details (Reactive)

              /// 🔹 Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ButtonBS(
                        title: 'Save Draft',
                        textColor: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,

                        // width: width * 0.85,
                        // height: height * 0.055,
                        // width: width * 0.39,
                        // height: height * 0.04,
                        padding: 8.0,
                        backgroundColor: Colors.white,
                        borderColor: AppColors.border,
                        borderRadius: 12,
                        // suffixIcon: Icons.arrow_forward_ios,
                        // suffixIconColor: Colors.white,
                        // suffixIconSize: 18,
                        // prefixIconSize: 0,
                        // separateSuffixIcon: 5,
                        onPressed: () {
                          controller.updateExpense(0);
                        }),
                  ),
                  SizedBox(
                    width: 14,
                  ),
                  Expanded(
                    child: ButtonBS(
                        title: 'Submit',
                        textColor: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,

                        // width: width * 0.85,
                        // height: height * 0.055,
                        // width: width * 0.39,
                        // height: height * 0.04,
                        padding: 8.0,
                        backgroundColor: AppColors.green,
                        borderRadius: 12,
                        // suffixIcon: Icons.arrow_forward_ios,
                        // suffixIconColor: Colors.white,
                        // suffixIconSize: 18,
                        // prefixIconSize: 0,
                        // separateSuffixIcon: 5,
                        onPressed: () {
                          controller.updateExpense(1);
                        }),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ticketSection(ExpenseController controller) {
    return _sectionCard(
      "Ticket Details",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("Mode of Travel ", color: Colors.red),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ContainerWidget.commonSelectableContainer(
                  label: "Bus",
                  selected: controller.travelMode.value == "Bus",
                  onTap: () => controller.setTravelMode("Bus"),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ContainerWidget.commonSelectableContainer(
                  label: "Train",
                  selected: controller.travelMode.value == "Train",
                  onTap: () => controller.setTravelMode("Train"),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ContainerWidget.commonSelectableContainer(
                  label: "Flight",
                  selected: controller.travelMode.value == "Flight",
                  onTap: () => controller.setTravelMode("Flight"),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ContainerWidget.commonSelectableContainer(
                  label: "Other",
                  selected: controller.travelMode.value == "Other",
                  onTap: () => controller.setTravelMode("Other"),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 10),
          // Row(
          //   children: [
          //     ContainerWidget.commonSelectableContainer(
          //       label: "Flight",
          //       selected: controller.travelMode.value == "Flight",
          //       onTap: () => controller.setTravelMode("Flight"),
          //     ),
          //     const SizedBox(width: 10),
          //     ContainerWidget.commonSelectableContainer(
          //       label: "Other",
          //       selected: controller.travelMode.value == "Other",
          //       onTap: () => controller.setTravelMode("Other"),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 16),
          AppTextField(
            controller: controller.fromLocationController,
            hint: "Departure city",
            label: "From Location",
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: controller.toLocationController,
            hint: "Arrival city",
            label: "To Location",
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          AppDateField(
            controller: controller.fromDateController,
            label: "From Date",
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          AppDateField(
            controller: controller.toDateController,
            label: "To Date",
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _hotelSection(ExpenseController controller) {
    return _sectionCard(
      "Hotel Details",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _label("Check-in Date",color: Colors.red),
          AppDateField(
              controller: controller.checkInController,
              label: "Check-in Date",
              color: Colors.red),

          const SizedBox(height: 16),
          // _label("Check-out Date",
          //     color: Colors.red),

          AppDateField(
              controller: controller.checkOutController,
              label: "Check-out Date",
              color: Colors.red
            // label: "dd/mm/yyyy",
          ),
          // const SizedBox(height: 10),
          //
          // Row(
          //   spacing: 10,
          //   children: [
          //     _travelToggle("Bus", controller),
          //     _travelToggle("Train", controller),
          //
          //   ],
          // ),
          // const SizedBox(height: 10),
          //
          // Row(
          //   spacing: 10,
          //   children: [
          //
          //     _travelToggle("Flight", controller),
          //     _travelToggle("Other", controller),
          //   ],
          // ),
          const SizedBox(height: 16),

          AppTextField(
            controller: controller.hotelNameController,
            hint: "Name Of the hotel",
            label: "Hotel Name",
            color: Colors.red,
          ),
          const SizedBox(height: 16),

          AppTextField(
            controller: controller.locationController,
            hint: "City,Country",
            label: "Location",
            color: Colors.red,
          ),

          // const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _restaurantSection(ExpenseController controller) {
    return _sectionCard(
      "Restaurant Details",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppDateField(
            controller: controller.restarteDateController,
            // label: "To Date *",
            label: "Date",
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: controller.restartNmaeController,
            hint: "Name Of the restaurant",
            label: "Restaurant Name",
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: controller.locationController,
            hint: "City,Country",
            label: "Location",
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _perDiemSection(ExpenseController controller) {
    return _sectionCard(
      "Per Diem Entries",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Static text
          CommonTextStyles.commonSecondaryStyle(
            title:
            "Add multiple per diem entries for your stay. All amounts are in INR.",
            Size: 9,
          ),
          Divider(),

          /// 🔥 Reactive count
          Obx(() => controller.perDiemList.isEmpty
              ? Text(
            "Added New Entry",
          )
              : Text(
            "Added Entry (${controller.perDiemList.length})",
          )),
          SizedBox(height: 10),

          /// 🔥 Reactive list

          Obx(() => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.perDiemList.length,
            itemBuilder: (context, index) {
              final entry = controller.perDiemList[index];
              return _perDiemCard(entry, controller);
            },
          )),

          /// 🔥 Reactive total
          Obx(() => controller.totalAmount > 0
              ? _totalWidget(controller)
              : const SizedBox()),

          // /// Form (non-reactive)
          _formFields(controller),
        ],
      ),
    );
  }

  Widget _totalWidget(ExpenseController controller) {
    return Obx(() => controller.totalAmount != 0
        ? Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total Amount",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            Text(
              "₹ ${controller.totalAmount.toStringAsFixed(2)}",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
      ),
    )
        : const SizedBox());
  }

  Widget _perDiemCard(entry, ExpenseController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("${entry.location}", style: const TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                // Text(entry.monthYear ?? '--'),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  onPressed: () => controller.perDiemList.remove(entry),
                )
              ],
            ),
            // CommonTextStyles.rowText(key: "Location :", value: entry.location),
            CommonTextStyles.rowText(
                key: "Start Date:", value: entry.startDate),
            CommonTextStyles.rowText(key: "End Date:", value: entry.endDate),
            CommonTextStyles.rowText(
              key: "Amount:",
              value: "₹ ${entry.amount}",
              rightText: AppColors.green,
            ),
            // const SizedBox(height: 6),
            Text("Details:  ${entry.details}",
                style: TextStyle(fontWeight: FontWeight.w500)),
            Text(entry.details),
          ],
        ),
      ),
    );
  }

  Widget _formFields(ExpenseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AppDateField(
        //     controller: controller.monthYearController,
        //     // label: "From Date *",
        //     label: "Month & Year",
        //     color: Colors.red),
        // const SizedBox(height: 16),
        AppTextField(
            controller: controller.perDiemlocationController,
            hint: "City,Country",
            label: "Location ",
            color: Colors.red),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: SizeUtils.width * 0.4,
              child: AppDateField(
                  controller: controller.startDateController,
                  label: "Start Date",
                  hint: "dd/mm/yyyy",
                  color: Colors.red),
            ),
            SizedBox(
              width: SizeUtils.width * 0.4,
              child: AppDateField(
                  controller: controller.endDateController,
                  label: "End Date",
                  hint: "dd/mm/yyyy",
                  color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: controller.perDiemAmountController,
          hint: "0.00",
          label: "Total Amount(INR)",
          color: Colors.red,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: controller.detailsController,
          hint: "Provide details abount per diem entry..",
          label: "Details",
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        ButtonBS(
          title: "Add Entry",
          prefixIcon: Icons.add,
          textColor: Colors.white,
          onPressed: controller.addEntry,
          backgroundColor: AppColors.blue,
          prefixIconColor: Colors.white,
          fontWeight: FontWeight.w500,
          borderRadius: 8,
          padding: 5,
        )
      ],
      //  ),
    );
  }

// Widget _perDiemSection(controller) {
//   return  _sectionCard(
//           "Per Diem Entries",
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CommonTextStyles.commonSecondaryStyle(
//                   title:
//                       "Add multiple per diem entries for your stay. All amounts are in INR."),
//               Obx(()=> Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: CommonTextStyles.commonSecondaryStyle(
//                       title: "Added Entry  (${controller.perDiemList.length})",
//                       Size: 16,
//                       weight: FontWeight.w500),
//                 ),
//               ),
//               Column(
//                 children: controller.perDiemList.map((entry) {
//                   return Container(
//                     // margin: EdgeInsets.symmetric(vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade50,
//                       border: Border.all(
//                         color: AppColors.border,
//                       ),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4),
//                             child: Row(
//                               // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text("Month/Year:",
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.w500)),
//                                 Spacer(),
//                                 Text(entry.monthYear,
//                                     textAlign: TextAlign.right),
//                                 GestureDetector(
//                                   child: Icon(Icons.delete_outline_rounded,
//                                       color: Colors.red),
//                                   onTap: () {
//                                     controller.perDiemList.remove(entry);
//                                   },
//                                 )
//                               ],
//                             ),
//                           ),
//                           rowText(key: "Location :", value: entry.location),
//                           rowText(key: "Start Date:", value: entry.startDate),
//                           rowText(key: "End Date:", value: entry.endDate),
//                           rowText(
//                               key: "Amount:",
//                               value: "₹ ${entry.amount}",
//                               color: AppColors.green),
//                           Text("Details:",
//                               style: TextStyle(fontWeight: FontWeight.w500)),
//                           Text(entry.details, textAlign: TextAlign.right),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//               if (controller.totalAmount != 0)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 15.0),
//                   child: Container(
//                     padding: EdgeInsets.all(12),
//                     margin: EdgeInsets.only(top: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade50,
//                       border: Border.all(color: Colors.blue),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("Total Amount",
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.primary)),
//                         Text("₹ ${controller.totalAmount.toStringAsFixed(2)}",
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.primary)),
//                       ],
//                     ),
//                   ),
//                 ),
//               _label("Month & Year",color: Colors.red),
//               AppDateField(
//                 controller: controller.monthYearController,
//                 // label: "From Date *",
//                 label: "mm/yyyy",
//               ),
//               const SizedBox(height: 16),
//               AppTextField(
//                 controller: controller.locationController,
//                 hint: "City,Country",
//                 label: "Location *",
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   SizedBox(
//                     width: SizeUtils.width * 0.4,
//                     child: AppDateField(
//                       controller: controller.startDateController,
//                       label: "Start Date *",
//                       hint: "dd/mm/yyyy",
//                     ),
//                   ),
//                   SizedBox(
//                     width: SizeUtils.width * 0.4,
//                     child: AppDateField(
//                       controller: controller.endDateController,
//                       label: "End Date *",
//                       hint: "dd/mm/yyyy",
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               AppTextField(
//                 controller: controller.amountController,
//                 hint: "0.00",
//                 label: "Total Amount(INR) *",
//               ),
//               const SizedBox(height: 16),
//               AppTextField(
//                 controller: controller.detailsController,
//                 hint: "Provide details abount per diem entry..",
//                 label: "Details",
//                 color: Colors.red,
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: controller.addEntry,
//                 child: Text("Add Entry"),
//               ),
//             ],
//           ),
//     );
// }

/// 🔹 Toggle (Expense)
}

/// 🔹 Section Card
Widget _sectionCard(String title, Widget child) {
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

/// 🔹 Label
Widget _label(String label, {Color color = AppColors.white}) {
  return RichText(
    maxLines: 3,
    softWrap: true,
    overflow: TextOverflow.ellipsis,
    text: TextSpan(
      text: label,
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      children: [
        TextSpan(
          text: " *",
          style: TextStyle(color: color),
        ),
      ],
    ),
  );
}
