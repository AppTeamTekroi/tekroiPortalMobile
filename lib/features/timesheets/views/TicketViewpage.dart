import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:travelPortal/core/constants/api_constants.dart';
import 'package:travelPortal/core/network/api_helper.dart';
import 'package:travelPortal/core/routes/route_controller.dart';
import 'package:travelPortal/features/login/controller/login_controller.dart';
import 'package:travelPortal/ui/theme/appColor.dart';
import 'package:travelPortal/ui/widgets/AppDropdown.dart';
import 'package:travelPortal/ui/widgets/AppTextArea.dart';
import 'package:travelPortal/ui/widgets/button.dart';
import 'package:travelPortal/ui/widgets/containerWidgets.dart';
import '../controllers/VehicleController.dart';
import '../models/model.dart';

class Ticketviewpage extends StatefulWidget {
  const Ticketviewpage({super.key});

  @override
  State<Ticketviewpage> createState() => _TicketviewpageState();
}

class _TicketviewpageState extends State<Ticketviewpage> {
  RxString _selectedDomain = ''.obs;
  VehicleController vehicleController = Get.find<VehicleController>();
  LoginController loginController = Get.find<LoginController>();
  final TextEditingController _descriptionController = TextEditingController();
  File selectedFile = File('');
  String pickedFileName = '';
  bool filePicked = false;
  String? ticketId;
  String? ticketSubject;

  @override
  void initState() {
    super.initState();
    vehicleController.DomainData(context, loginController.UserId.toString());
    vehicleController.ProjectData();
    _loadTicketArgs();
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

  void _loadTicketArgs() {
    final args = Get.find<RouteController>().arguments;
    if (args is! Map) return;
    ticketId = args['ticket_id']?.toString() ?? args['id']?.toString();
    ticketSubject = args['subject']?.toString();
    final domain = args['domain']?.toString() ?? '';
    if (domain.isNotEmpty) {
      _selectedDomain.value = domain;
    }
  }

  List<FormData> formDataList = [FormData()];
  final ScrollController _scrollController = ScrollController();
  int? id;
  var isSubmitting = false.obs;

  @override
  void dispose() {
    _scrollController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}h${minutes.toString().padLeft(2, '0')}m';
  }

  void addForm() {
    setState(() {
      formDataList.add(FormData.copy(formDataList.last));
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
    setState(() => formDataList.removeAt(index));
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

      // ✅ Skip form if any required field is missing
      if (
      //form._selectedProject.value.isEmpty ||
      form.dropdown2 == null ||
          form._selectedWork.value.isEmpty ||
          description.isEmpty) {
        continue;
      }

      hasValidForm = true;

      dateList.add(DateFormat('yyyy-MM-dd').format(form.selectedDate));
      startTimeList.add(_formatTime(form.startTime));
      endTimeList.add(_formatTime(form.endTime));
      totalTimeList.add(form.duration.inHours.toString());
      descriptionList.add(description);
      projectIdList.add(projectId ?? 0);
      statusList.add(form.dropdown2!);
      whoAssignedList.add(whoAssigned ?? "");
    }

    if (!hasValidForm) {
      showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      if (ticketId != null) "ticket_id": ticketId,
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
        setState(() {});
        showDialog(
          context: Get.context!,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.of(context).pop(); // close the dialog
                //     Get.to(() => EnginnerBottomNav());
                //     vehicleController.fetchbinbatch(
                //       Get.context!,
                //       loginController.UserId.toString(),
                //       loginController.rollId.toString(),
                //     );
                //   },
                //   child: const Text("OK"),
                // )
              ],
            ),
          ),
        );
      } else {
        showDialog(
          context: Get.context!,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        );      }
    } catch (e) {
      print('❌ Error: $e');
      showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  void submitForms() {
    for (var data in formDataList) {
      print('Who Assigned: ${data._selectedWork}');
      print('Date: ${data.selectedDate}');
      print('Start Time: ${data.startTime}');
      print('End Time: ${data.endTime}');
      print('Duration: ${data.duration}');
    }
  }

  InputDecoration _outline({Widget? suffix}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      suffixIcon: suffix,
      suffixIconConstraints: const BoxConstraints(minWidth: 26, minHeight: 26),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _fieldLabel(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        children: [
          if (required)
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
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
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: _outline(
          suffix: Icon(icon, size: 14, color: AppColors.text),
        ),
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ),
    );
  }

  Widget _durationBadge(FormData form) {
    return InputDecorator(
      decoration: _outline(
        suffix: Icon(Icons.timelapse_outlined, size: 14, color: AppColors.blue),
      ),
      child: Text(
        _formatDuration(form.duration),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.blue,
        ),
      ),
    );
  }

  Future<void> _uploadAttachment() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'doc', 'docx', 'pdf'],
    );

    if (result.isNotEmpty) {
      final file = result.first;
      setState(() {
        selectedFile = File(file.path!);
        pickedFileName = file.name;
        filePicked = true;
      });
    }
  }

  void _submitDomainUpdate() {
    if (_selectedDomain.value.isEmpty) {
      Get.snackbar(
        'Domain',
        'Please select a domain',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
      );
      return;
    }
    Get.snackbar(
      'Domain updated',
      _selectedDomain.value,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
    );
  }

  Widget _ticketSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle('Ticket'),
          const SizedBox(height: 6),
          Obx(() {
            final domains = vehicleController.domain.map((d) => d.name).toList();
            return AppDropdown(
              label: 'Domain',
              hint: 'Select domain',
              compact: true,
              value: domains.contains(_selectedDomain.value)
                  ? _selectedDomain.value
                  : '',
              items: domains,
              onChanged: (val) {
                if (val != null) _selectedDomain.value = val.toString();
              },
            );
          }),
          const SizedBox(height: 6),
          _fieldLabel('Reply message'),
          const SizedBox(height: 2),
          AppTextArea(
            controller: _descriptionController,
            hint: 'Enter description...',
            maxLines: 2,
            compact: true,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: OutlinedButton.icon(
                    onPressed: _uploadAttachment,
                    icon: const Icon(Icons.attach_file, size: 14),
                    label: Text(
                      filePicked ? pickedFileName : 'Upload file',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                height: 34,
                child: ButtonBS(
                  title: 'Update',
                  textColor: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  padding: 6,
                  height: 34,
                  backgroundColor: AppColors.primary,
                  borderRadius: 8,
                  onPressed: _submitDomainUpdate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timesheetEntryCard(FormData form, int index) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (formDataList.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    'Entry ${index + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF34353d),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => removeForm(index),
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(Icons.close, size: 15, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          // 1. Date | Start
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Date', required: true),
                    const SizedBox(height: 2),
                    _pickerField(
                      value: DateFormat('dd-MM-yyyy').format(form.selectedDate),
                      icon: Icons.calendar_today_outlined,
                      onTap: () async {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final monthStart = DateTime(now.year, now.month, 1);
                        final monthEnd = DateTime(now.year, now.month + 1, 0);
                        final selectedDate = DateTime(
                          form.selectedDate.year,
                          form.selectedDate.month,
                          form.selectedDate.day,
                        );
                        final inThisMonth = !selectedDate.isBefore(monthStart) &&
                            !selectedDate.isAfter(monthEnd);
                        final date = await showDatePicker(
                          context: context,
                          initialDate: inThisMonth ? selectedDate : today,
                          currentDate: today,
                          firstDate: monthStart,
                          lastDate: monthEnd,
                        );
                        if (date == null) return;
                        setState(() => form.selectedDate = date);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Start', required: true),
                    const SizedBox(height: 2),
                    _pickerField(
                      value: form.startTime.format(context),
                      icon: Icons.access_time,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: form.startTime,
                        );
                        if (time == null) return;
                        setState(() => form.startTime = time);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 2. End | Duration
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('End', required: true),
                    const SizedBox(height: 2),
                    _pickerField(
                      value: form.endTime.format(context),
                      icon: Icons.access_time,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: form.endTime,
                        );
                        if (time == null) return;
                        setState(() => form.endTime = time);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Duration'),
                    const SizedBox(height: 2),
                    _durationBadge(form),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 3. Timesheet to | Status
          Obx(() {
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
            final status = (form.dropdown2 == null || form.dropdown2!.isEmpty)
                ? 'Completed'
                : form.dropdown2!;
            if (form.dropdown2 != status) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                form.dropdown2 = status;
              });
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppDropdown(
                    label: 'Timesheet to',
                    hint: 'Person',
                    color: Colors.red,
                    compact: true,
                    value: names.contains(form._selectedWork.value)
                        ? form._selectedWork.value
                        : '',
                    items: names,
                    onChanged: (val) {
                      form._selectedWork.value = val?.toString() ?? '';
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AppDropdown(
                    label: 'Status',
                    hint: 'Status',
                    color: Colors.red,
                    compact: true,
                    value: status,
                    items: const ['In Progress', 'Completed', 'Transferred'],
                    onChanged: (val) {
                      setState(() => form.dropdown2 = val?.toString());
                    },
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 6),

          // 4. Description
          _fieldLabel('Description', required: true),
          const SizedBox(height: 2),
          AppTextArea(
            controller: form.descriptionController,
            hint: 'Enter description...',
            maxLines: 2,
            compact: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        toolbarHeight: 44,
        automaticallyImplyLeading: false,
        title: ContainerWidget.backContainer(
          () => Get.find<RouteController>().back(),
          ticketId == null ? 'New Ticket' : 'Ticket #${ticketId ?? ''}',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              children: [
                if (ticketSubject != null && ticketSubject!.isNotEmpty) ...[
                  Text(
                    ticketSubject!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                _ticketSection(),
                const SizedBox(height: 8),
                _sectionTitle('Add Timesheet'),
                const SizedBox(height: 6),
                for (var i = 0; i < formDataList.length; i++) ...[
                  _timesheetEntryCard(formDataList[i], i),
                  if (i < formDataList.length - 1) const SizedBox(height: 6),
                ],
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
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
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Entry',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      padding: 6,
                      height: 34,
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
}

class FormData {
  RxString _selectedProject = ''.obs;
  String? dropdown2 = 'Completed';
  RxString _selectedWork = ''.obs;
  DateTime selectedDate;
  TimeOfDay startTime;
  TimeOfDay endTime;
  TextEditingController descriptionController;

  FormData()
      : dropdown2 = 'Completed',
        selectedDate = DateTime.now(),
        startTime = const TimeOfDay(hour: 9, minute: 30),
        endTime = const TimeOfDay(hour: 18, minute: 30),
        descriptionController = TextEditingController();

  FormData.copy(FormData other)
      : dropdown2 = other.dropdown2 ?? 'Completed',
        _selectedProject = RxString(other._selectedProject.value),
        _selectedWork = RxString(other._selectedWork.value),
        descriptionController = TextEditingController(),
        selectedDate = DateTime.now(),
        startTime = const TimeOfDay(hour: 9, minute: 30),
        endTime = const TimeOfDay(hour: 18, minute: 30);

  Duration get duration {
    final start = DateTime(0, 0, 0, startTime.hour, startTime.minute);
    final end = DateTime(0, 0, 0, endTime.hour, endTime.minute);
    final diff = end.difference(start);
    return diff.isNegative ? Duration.zero : diff;
  }
}

