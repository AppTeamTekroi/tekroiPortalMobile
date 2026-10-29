import 'package:flutter/material.dart';
import 'package:travelPortal/ui/widgets/containerWidgets.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/routes/route_controller.dart';
import '../../../core/utils/pageStatus.dart';
import '../../../core/utils/size_utils.dart';
import 'package:get/get.dart';

import '../../../ui/theme/appColor.dart';
import '../../../ui/widgets/AppDateField.dart';
import '../../../ui/widgets/AppDropdown.dart';
import '../../../ui/widgets/AppLaunchUrl.dart';
import '../../../ui/widgets/AppTextArea.dart';
import '../../../ui/widgets/AppTextField.dart';
import '../../../ui/widgets/AppUploads.dart';
import '../../../ui/widgets/button.dart';
import '../../../ui/widgets/commonTextStyles.dart';
import '../../../ui/widgets/shimmer.dart';
import '../controllers/travel_controller.dart';
import 'package:intl/intl.dart';

class CreateTravelPage extends StatelessWidget {
  const CreateTravelPage({super.key});

  @override
  Widget build(BuildContext context) {
    TravelController controller = Get.put(TravelController());
    RouteController routes = Get.find();
    controller.clearForm();
    controller.dateController.text = DateFormat("dd/MM/yyyy").format(DateTime.now());
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade100,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: ContainerWidget.backContainer(() {
            controller.clearForm();
            routes.back();
          }, "New Travel Log"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            spacing: 12,
            children: [
              /// 🔹 Date & Time
              _sectionCard(
                "Date & Time",
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: 3,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        text: "Date",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
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
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.dateController.text,
                            style: TextStyle(color: Colors.black),
                          ),
                          Icon(Icons.access_time),
                        ],
                      ),
                    ),

                    // AppDateField(
                    //   controller: controller.dateController,
                    //   label: "Date",
                    //   color: Colors.red,
                    //   hint: "dd/mm/yyy",
                    //
                    // ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTimeField(
                            controller: controller.checkInController,
                            label: "Check-in",
                            color: Colors.red,
                            onTimeSelected: (time) async {
                              print("Selected time: $time");

                              /// 🔥 fetch location here
                              await controller.getCurrentLocation(0);
                            },

                            /// Allow typing

                            // keyboardType: TextInputType.datetime,

                            /// Picker
                            // icon: IconButton(
                            //   icon: const Icon(Icons.calendar_today),
                            //   onPressed: () => pickDateTime(controller.checkInController),
                            // ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTimeField(
                            controller: controller.checkOutController,
                            label: "Check-out",
                            onTimeSelected: (time) async {
                              print("Selected time: $time");

                              /// 🔥 fetch location here
                              await controller.getCurrentLocation(1);
                            },
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (controller.checkInAddress.value.isNotEmpty)
                            CommonTextStyles.commonSecondaryStyle(
                              title:
                                  "CheckIn At: ${controller.checkInAddress.value}",
                            ),
                          if (controller.checkOutAddress.value.isNotEmpty)
                            CommonTextStyles.commonSecondaryStyle(
                              title:
                                  "CheckOut At: ${controller.checkOutAddress.value}",
                            ),
                        ],
                      );
                    })
                  ],
                ),
              ),

              /// 🔹 Travel Details
              _sectionCard(
                "Travel Details",
                Obx(
                      () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Travel Type
                        requiredLabel("Travel Type "),

                        const SizedBox(height: 10),

                        IntrinsicHeight(
                          child: Row(children: [
                            Expanded(
                                child: _toggleBox("Implementation & Support",
                                    controller.travelType.value, (val) {
                                      controller.travelType.value = val; // ✅ use val, not hardcoded string
                                      controller.customerController.clear();
                                      controller.customer.value = "";
                                      controller.project.value = "";
                                    })),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _toggleBox(
                                    "Sales", controller.travelType.value,
                                        (val) {
                                      controller.travelType.value = val;
                                      controller.customerController.clear();
                                      controller.customer.value = "";
                                      controller.project.value = "";
                                    })),
                          ]),
                        ),

                        const SizedBox(height: 16),

                        /// Customer
                        Obx(() {
                          if (controller.travelType.value == "Implementation & Support") { // ✅ matches toggle value
                            if (controller.customerState.value.status ==
                                PageStatus.loading) {
                              return shimmerBox(40);
                            }

                            final models = controller.customerState.value.data;

                            final uniqueCustomers = models["customers"] ?? [];
                            final customers = uniqueCustomers.toSet().toList();
                            final uniqueProjects = models["projects"] ?? [];
                            final projects = uniqueProjects.toSet().toList();

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

                                const SizedBox(height: 16),

                                /// Project Dropdown
                                // AppDropdown(
                                //   label: "Project",
                                //   value: customers.contains(controller.project.value)
                                //       ? controller.project.value
                                //       : "",
                                //   hint: "Select Project",
                                //   items: projects,
                                //   onChanged: (val) {
                                //     controller.project.value = val;
                                //   },
                                // ),
                              ],
                            );
                          } else {
                            return AppTextField(
                              label: "Customer",
                              hint: "Enter Customer",
                              color: Colors.red,
                              controller: controller.customerController,
                            );
                          }
                        }),
                      ]),
                ),
              ),

              /// 🔹 Transportation
              _sectionCard(
                "Transportation",
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      requiredLabel("Mode of Travel"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _toggleBox(
                              "Self",
                              controller.travelMode.value,
                              (val) {
                                controller.travelMode.value = val;
                                controller.taxiAmountController.clear();
                                controller.taxiBill == null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _toggleBox(
                              "Taxi",
                              controller.travelMode.value,
                              (val) {
                                controller.travelMode.value = val;
                              },
                            ),
                          ),
                        ],
                      ),
                      (controller.travelMode.value == "Taxi")
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                AppTextField(
                                  controller: controller.taxiAmountController,
                                  hint: "0.00",
                                  label: "Amount *",
                                  keyboardType: TextInputType.number,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: requiredLabel("Bill/Receipt "),
                                ),
                                UploadBox(
                                  showPicker: controller.showPicker.value,
                                  onTap: () {
                                    controller.showPicker.value = true;
                                  },
                                  onFileSelected: (file) {
                                    controller.taxiBill = file;

                                    print("🔥 CONTROLLER FILE => ${file.path}");
                                  },
                                  onFileRemoved: () {
                                    controller.taxiBill == null;
                                    controller.showPicker.value = false;
                                  },
                                ),
                                // if (controller.taxiBill != null)
                                //   Padding(
                                //     padding: const EdgeInsets.only(top: 8.0),
                                //     child: Column(
                                //       children: [
                                //         FileLinkWidget(
                                //           url: controller.serverFile,
                                //           title: "View Attachment",
                                //         ),
                                //         Text(
                                //           "Note: If you want to replaced the file only upload bill",
                                //           style: TextStyle(
                                //               fontSize: 11, color: Colors.grey),
                                //         )
                                //       ],
                                //     ),
                                //   ),
                              ],
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),

              /// 🔹 Notes
              _sectionCard(
                "Notes (Optional)",
                AppTextArea(
                  controller: controller.notesController,
                  hint: "Add any additional notes...",
                  // label: "Notes (Optional)"
                ),
              ),

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
                        borderColor: AppColors.border,
                        padding: 8.0,
                        backgroundColor: Colors.white,
                        borderRadius: 12,
                        // suffixIcon: Icons.arrow_forward_ios,
                        // suffixIconColor: Colors.white,
                        // suffixIconSize: 18,
                        // prefixIconSize: 0,
                        // separateSuffixIcon: 5,
                        onPressed: () {
                            controller.submitTravel(0);
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
                        fontWeight: FontWeight.bold,

                        // width: width * 0.85,
                        // height: height * 0.055,
                        // width: width * 0.39,
                        // height: height * 0.04,
                        padding: 8.0,
                        backgroundColor: AppColors.blue,
                        borderRadius: 12,
                        // suffixIcon: Icons.arrow_forward_ios,
                        // suffixIconColor: Colors.white,
                        // suffixIconSize: 18,
                        // prefixIconSize: 0,
                        // separateSuffixIcon: 5,
                        onPressed: () {
                            controller.submitTravel(1);
                        }),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
    );
  }

  /// 🔹 Section Card
  Widget _sectionCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        //controller.travelType.refresh();
        // controller.travelMode.refresh();
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonTextStyles.commonSecondaryStyle(
              title: title, Size: 16, weight: FontWeight.w500),
          // Text(title,
          //     style:
          //         const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  /// 🔹 Toggle using your style
  Widget _toggleBox(String text, String groupValue, Function(String) onTap) {
    bool isSelected = text == groupValue;

    return GestureDetector(
      onTap: () => onTap(text),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.blue.withOpacity(0.1) : AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.blue : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget requiredLabel(String text) {
    return RichText(
      text: TextSpan(
        text: "$text ",
        style: TextStyle(
            color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
        children: [
          TextSpan(
            text: "*",
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
