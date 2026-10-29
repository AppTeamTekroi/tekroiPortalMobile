import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:travelPortal/core/constants/api_constants.dart';
import 'package:travelPortal/core/network/api_helper.dart';
import 'package:travelPortal/core/routes/route_controller.dart';
import 'package:travelPortal/features/login/controller/login_controller.dart';
import 'package:travelPortal/ui/theme/appColor.dart';
import 'package:travelPortal/ui/widgets/AppDropdown.dart';
import 'package:travelPortal/ui/widgets/AppTextArea.dart';
import 'package:travelPortal/ui/widgets/button.dart';
import 'package:travelPortal/ui/widgets/commonTextStyles.dart';
import 'package:travelPortal/ui/widgets/containerWidgets.dart';
import '../controllers/VehicleController.dart';

class SparesScreen extends StatefulWidget {
  const SparesScreen({super.key});

  @override
  State<SparesScreen> createState() => _SparesScreenState();
}

class _SparesScreenState extends State<SparesScreen> {
  List<FormData> formDataList = [FormData()];
  final ScrollController _scrollController = ScrollController();

  VehicleController vehicleController = Get.find<VehicleController>();
  final LoginController loginController = Get.find<LoginController>();
  var isSubmitting = false.obs;

  @override
  void initState() {
    super.initState();
    vehicleController.ProjectData();
    vehicleController.UserData().then((_) {
      _applyDefaultWhoAssigned();
      if (mounted) setState(() {});
    });
  }

  void _applyDefaultWhoAssigned() {
    final name = vehicleController.defaultWhoAssignedName();
    if (name == null) return;
    for (final form in formDataList) {
      if (form._selectedWork.value.isEmpty) {
        form._selectedWork.value = name;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDuration(double hours) {
    final int h = hours.floor();
    final int m = ((hours - h) * 60).round();
    final String hh = h.toString().padLeft(2, '0');
    final String mm = m.toString().padLeft(2, '0');
    return '${hh}h${mm}m'; // e.g., "03h30m"
  }


  void addForm() {
    setState(() {
      FormData lastForm = formDataList.last;
      FormData newForm = FormData.copy(lastForm);

      if (lastForm.endTime != null &&
          lastForm.selectedDate == newForm.selectedDate) {
        newForm.startTime = lastForm.endTime!;
      } else {
        newForm.startTime = const TimeOfDay(hour: 9, minute: 30);
      }

      newForm.descriptionController.text = '';
      formDataList.add(newForm);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  void removeForm(int index) {
    if (formDataList.length <= 1) return;
    setState(() {
      formDataList.removeAt(index);
    });
  }

  Future<void> submitFormsToApi() async {
    isSubmitting.value = true;

    final dateList = <String>[];
    final startTimeList = <String>[];
    final endTimeList = <String>[];
    final totalTimeList = <String>[];
    final descriptionList = <String>[];
    final projectIdList = <int>[];
    final statusList = <String>[];
    final whoAssignedList = <String>[];

    bool hasValidForm = false;

    for (var form in formDataList) {
      final description = form.descriptionController.text.trim();
      final projectId = vehicleController.project
          .firstWhereOrNull((p) => p.id.toString() == form._selectedProject.value)
          ?.id;
      final whoAssigned = form._selectedWork.value;

      // Print values for debugging
      print("📝 Form values:");
      print("Project: ${form._selectedProject.value}");
      print("Status: ${form.dropdown2}");
      print("Who Assigned: $whoAssigned");
      print("Description: $description");

      // Skip form if any required field is missing
      if (form.dropdown2 == null ||
          whoAssigned.isEmpty ||
          description.isEmpty ||
          form.endTime == null ||
          form._selectedProject.value.isEmpty) {
        print("⚠️ Skipping form due to missing required fields\n");
        continue;
      }

      hasValidForm = true;

      dateList.add(DateFormat('yyyy-MM-dd').format(form.selectedDate));
      startTimeList.add(_formatTime(form.startTime));
      endTimeList.add(_formatTime(form.endTime!));
      totalTimeList.add(_formatDuration(form.durationInHours));
      descriptionList.add(description);
      projectIdList.add(projectId ?? 0);
      statusList.add(form.dropdown2!);
      whoAssignedList.add(whoAssigned ?? "");
    }

    if (!hasValidForm) {
      showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: Colors.orange, size: 60),
              const SizedBox(height: 16),
              const Text(
                "Please fill all required fields.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              )
            ],
          ),
        ),
      );
      isSubmitting.value = false;
      return;
    }

    final body = {
      "date": dateList,
      "start_time": startTimeList,
      "end_time": endTimeList,
      "user_id": loginController.UserId.toString(),
      "total_time": totalTimeList,
      "description": descriptionList,
      "project_name": projectIdList,
      "status": statusList,
      "who_assigned": whoAssignedList,
    };

    print("🔼 Sending data to API:");
    print(jsonEncode(body));

    try {
      final response = await http.post(
        ApiHelper.withToken(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.timesheetDetails}')),
        headers: ApiHelper.getHeaders(),
        body: jsonEncode(body),
      );

      isSubmitting.value = false; // stop loading

      print('✅ Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Get.snackbar("Success", "Timesheet submitted successfully!");

        // ✅ Reset the form
        formDataList.clear();
        formDataList.add(FormData());
        _applyDefaultWhoAssigned();
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
        setState(() {});
        showDialog(
          context: Get.context!,
          builder: (context) => AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                const Text(
                  "Timesheets submitted successfully!",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    final now = DateTime.now();
                    vehicleController.fetchbinbatch(
                      Get.context!,
                      loginController.UserId.toString(),
                      loginController.rollId.toString(),
                      min: DateFormat('yyyy-MM-dd').format(
                        DateTime(now.year, now.month, 1),
                      ),
                      max: DateFormat('yyyy-MM-dd').format(
                        DateTime(now.year, now.month + 1, 0),
                      ),
                    );
                    Get.find<RouteController>().back();
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          ),
        );
      } else {
        showDialog(
          context: Get.context!,
          builder: (context) => AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.close, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                const Text(
                  "TimeSheets not submitted",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close the dialog
                  },
                  child: const Text("OK"),
                )
              ],
            ),
          ),
        );
      }
    } catch (e) {
      isSubmitting.value = false;
      print('❌ Error: $e');
      showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.close, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                "Something went wrong",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close the dialog
                },
                child: const Text("OK"),
              )
            ],
          ),
        ),
      );
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  /// Always 12-hour with AM/PM, independent of device locale settings.
  String _formatTime12(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  Future<TimeOfDay?> _pickTime12(TimeOfDay initial) {
    return showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  // String _formatTime(TimeOfDay time) {
  //   final now = DateTime.now();
  //   final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  //   return DateFormat('HH:mm').format(dt);
  // }

  void submitForms() {
    for (var data in formDataList) {
      // Replace this with your actual submission logic
      print('Dropdown1: ${data._selectedWork}');
      print('Dropdown2: ${data.dropdown2}');
      print('Dropdown3: ${data._selectedProject}');
      print('Date: ${data.selectedDate}');
      print('Start Time: ${data.startTime}');
      print('End Time: ${data.endTime}');
      print('Duration: ${data.durationInHours}');
      // print('Description: ${data.description}');
    }
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _sectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(color: Colors.grey.shade200, height: 1),
    );
  }

  Widget _durationBadge(FormData form) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.backgrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timelapse_outlined, size: 16, color: AppColors.blue),
          const SizedBox(width: 6),
          Text(
            _formatDuration(form.durationInHours),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        children: [
          if (required)
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  InputDecoration _outline({
    String? hint,
    Widget? suffix,
    Color fill = Colors.white,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.hintText, fontSize: 13),
      filled: true,
      fillColor: fill,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      suffixIcon: suffix,
      suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _pickerField({
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: _outline(
          suffix: Icon(icon, size: 16, color: AppColors.text),
        ),
        child: Text(
          value,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        automaticallyImplyLeading: false,
        title: ContainerWidget.backContainer(
          () => Get.find<RouteController>().back(),
          'New Timesheet',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: formDataList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == formDataList.length - 1 ? 0 : 8,
                  ),
                  child: _timesheetCard(formDataList[index], index),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: addForm,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 18, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Entry',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(
                    () => ButtonBS(
                      title: isSubmitting.value ? 'Wait...' : 'Submit',
                      textColor: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      padding: 8,
                      backgroundColor: AppColors.blue,
                      borderRadius: 8,
                      onPressed:
                          isSubmitting.value ? null : submitFormsToApi,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timesheetCard(FormData form, int index) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (formDataList.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    'Entry ${index + 1}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF34353d),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => removeForm(index),
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(Icons.close, size: 16, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          // 1. Project
          Obx(() {
            final names =
                vehicleController.project.map((p) => p.projectName).toList();
            final selected = vehicleController.project.firstWhereOrNull(
              (p) => p.id.toString() == form._selectedProject.value,
            );
            return AppDropdown(
              label: 'Project',
              hint: 'Select project',
              color: Colors.red,
              compact: true,
              value: selected?.projectName ?? '',
              items: names,
              onChanged: (val) {
                final match = vehicleController.project.firstWhereOrNull(
                  (p) => p.projectName == val,
                );
                if (match != null) {
                  form._selectedProject.value = match.id.toString();
                }
              },
            );
          }),
          const SizedBox(height: 10),

          // 2. Date | Duration
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Date', required: true),
                    const SizedBox(height: 4),
                    _pickerField(
                      value: DateFormat('dd-MM-yyyy').format(form.selectedDate),
                      icon: Icons.calendar_today_outlined,
                      onTap: () async {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final monthStart = DateTime(now.year, now.month, 1);
                        final monthEnd = DateTime(now.year, now.month + 1, 0);
                        final selected = DateTime(
                          form.selectedDate.year,
                          form.selectedDate.month,
                          form.selectedDate.day,
                        );
                        final inThisMonth = !selected.isBefore(monthStart) &&
                            !selected.isAfter(monthEnd);
                        final date = await showDatePicker(
                          context: context,
                          initialDate: inThisMonth ? selected : today,
                          currentDate: today,
                          firstDate: monthStart,
                          lastDate: monthEnd,
                        );
                        if (date == null) return;
                        setState(() {
                          form.selectedDate = date;
                          form.startTime =
                              const TimeOfDay(hour: 9, minute: 30);
                          form.endTime = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Duration'),
                  const SizedBox(height: 4),
                  _durationBadge(form),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3. Start | End — wider so AM/PM stays readable
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Start', required: true),
                    const SizedBox(height: 4),
                    _pickerField(
                      value: _formatTime12(form.startTime),
                      icon: Icons.access_time,
                      onTap: () async {
                        final time = await _pickTime12(form.startTime);
                        if (time == null) return;
                        setState(() => form.startTime = time);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('End', required: true),
                    const SizedBox(height: 4),
                    _pickerField(
                      value: form.endTime == null
                          ? '--:-- --'
                          : _formatTime12(form.endTime!),
                      icon: Icons.access_time,
                      onTap: () async {
                        final time = await _pickTime12(
                          form.endTime ?? form.startTime,
                        );
                        if (time == null) return;
                        setState(() => form.endTime = time);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 4. Who Assigned (full width)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Obx(() {
                  loginController.assignedName.value;
                  loginController.assignedId.value;
                  final names =
                  vehicleController.workdata.map((user) => user.name).toList();
                  final selected = form._selectedWork.value;
                  if (selected.isEmpty) {
                    final managerName = vehicleController.defaultWhoAssignedName();
                    if (managerName != null && names.contains(managerName)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (form._selectedWork.value.isEmpty) {
                          form._selectedWork.value = managerName;
                        }
                      });
                    }
                  }
                  return AppDropdown(
                    label: 'Who Assigned',
                    hint: 'Select person',
                    color: Colors.red,
                    compact: true,
                    value: names.contains(form._selectedWork.value)
                        ? form._selectedWork.value
                        : '',
                    items: names,
                    onChanged: (val) {
                      form._selectedWork.value = val?.toString() ?? '';
                    },
                  );
                }),
              ),
              const SizedBox(width: 10), // ✅ was height:10 — no effect in a Row, needs width for horizontal gap

              // 5. Status
              Expanded( // ✅ wrap in Expanded so it shares row width instead of overflowing
                child: AppDropdown(
                  label: 'Status',
                  hint: 'Select status',
                  color: Colors.red,
                  compact: true,
                  value: form.dropdown2 ?? '',
                  items: const ['In Progress', 'Completed', 'Transferred'],
                  onChanged: (val) {
                    setState(() => form.dropdown2 = val?.toString());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 6. Description
          _fieldLabel('Description', required: true),
          const SizedBox(height: 4),
          AppTextArea(
            controller: form.descriptionController,
            hint: 'What did you work on?',
            maxLines: 2,
            compact: true,
          ),
        ],
      ),
    );
  }
}


class FormData {
  RxString _selectedProject = ''.obs;
  String? dropdown2 = 'Completed';
  RxString _selectedWork = ''.obs;
  DateTime selectedDate;
  TimeOfDay startTime;
  TimeOfDay? endTime;
  TextEditingController descriptionController;

  FormData()
      : selectedDate = DateTime.now(),
        dropdown2 = 'Completed',
  startTime = const TimeOfDay(hour: 9, minute: 30),
        endTime = null,
        descriptionController = TextEditingController();

  FormData.copy(FormData other)
      : dropdown2 = other.dropdown2,
        _selectedProject = RxString(other._selectedProject.value),
        _selectedWork = RxString(other._selectedWork.value),
        descriptionController =
        TextEditingController(), // <-- new clean controller
        selectedDate = other.selectedDate,
        startTime = const TimeOfDay(hour: 9, minute: 30),
        endTime = null;

  double get durationInHours {
    if (endTime == null) return 0;
    final start = DateTime(0, 0, 0, startTime.hour, startTime.minute);
    final end = DateTime(0, 0, 0, endTime!.hour, endTime!.minute);
    final diff = end.difference(start);
    if (diff.isNegative) return 0.0;
    return diff.inMinutes / 60; // total hours including minutes
  }

}