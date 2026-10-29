import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travelPortal/core/constants/api_constants.dart';
import 'package:travelPortal/core/network/api_helper.dart';
import 'package:travelPortal/core/routes/route_controller.dart';
import 'package:travelPortal/features/login/controller/login_controller.dart';
import 'package:travelPortal/ui/theme/appColor.dart';
import 'package:travelPortal/ui/widgets/AppTextArea.dart';
import 'package:travelPortal/ui/widgets/button.dart';
import 'package:travelPortal/ui/widgets/containerWidgets.dart';
import '../controllers/VehicleController.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;


class LeaveRequest extends StatefulWidget {
  const LeaveRequest({super.key});

  @override
  State<LeaveRequest> createState() => _LeaveRequestState();
}

class _LeaveRequestState extends State<LeaveRequest> {

  File selectedFile = File('');
  String pickedFileName = '';
  bool filePicked = false;
  TextEditingController _locationController = TextEditingController();
  LoginController lc = Get.find<LoginController>();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  VehicleController vehicleController = Get.find<VehicleController>();
  int _selectedIndex = 0;
  var isSubmitting = false.obs;
  var loadingBar = false.obs;
  bool _isStartDateDropdownEnabled = true;
  bool _isEndDateDropdownEnabled = true; // Initialize as true
  String? _selectedLeave;
  String _selectedHalfDayType = ""; // Default for half-day leave
  String _selectedFullDayOption = ""; // New dropdown option for other leaves
  String _selectedEndDayOption = ""; // New dropdown option for other leaves
  TextEditingController _noOfDaysController = TextEditingController(); // Controller for No. of Days
  TextEditingController _noDaysController = TextEditingController();
  final List<String> _typeofleaves = [
    "Sick Leave",
    "Casual Leave",
  //  "Half Day Leave"
  ];

  final Map<String, String> leaveTypeMap = {
    'Sick Leave': '2',
    'Casual Leave': '1',
    // Add more mappings if needed
  };


  // final List<String> _halfDayOptions = ["First Half", "Second Half"];
  final List<String> _fullDayOptions = ["Full Day", "First Half", "Second Half"];
  final List<String> _fullDayOptions2 = ["Full Day", "First Half", "Second Half"];

  final List<Widget> _pages = [
    // NotificationsPage(),
    // ProfilePage(),
  ];

  // Method to handle the dropdown options based on selected leave type
  bool get isHalfDayLeaveSelected => _selectedLeave == "Half Day Leave";
  bool get isOtherLeaveSelected => _selectedLeave != "Half Day Leave";

  void _calculateNoOfDays() {
    if (_startDateController.text.isNotEmpty && _endDateController.text.isNotEmpty && !isHalfDayLeaveSelected) {
      DateTime startDate = DateTime.parse(_startDateController.text);
      DateTime endDate = DateTime.parse(_endDateController.text);
      int totalDays = endDate.difference(startDate).inDays + 1; // +1 to include both dates

      double noOfDays = totalDays.toDouble();

      if (_selectedFullDayOption == "First Half"){
        noOfDays -= 0.5;
      }
      if (_selectedEndDayOption == "First Half") {
        noOfDays -= 0.5;
      }
      if (_selectedFullDayOption == "Second Half"){
        noOfDays -= 0.5;
      }
      if (_selectedEndDayOption == "Second Half") {
        noOfDays -= 0.5;
      }
      if(startDate.isAtSameMomentAs(endDate)) {
        if (_selectedFullDayOption == "First Half" && _selectedEndDayOption == "Second Half") {
          noOfDays =1;
        } else if (_selectedFullDayOption == "First Half" && _selectedEndDayOption == "First Half") {
          noOfDays = 0.5;
        } else if (_selectedFullDayOption == "Second Half" && _selectedEndDayOption == "Second Half") {
          noOfDays = 0.5; // Only the second half of the day
        }
      }

      _noOfDaysController.text = noOfDays.toString();
    } else {
      _noOfDaysController.clear(); // Clear if conditions not met
    }
  }

  String _selectedFileName = "";

  Future<void> _pickFile() async {
    final file = await FilePicker.pickFile();
    if (file != null) {
      setState(() {
        _selectedFileName = file.name;
        // You can also store path or bytes if needed
      });
    }
  }

  Future<void> submitLeaveRequest() async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    final daysText = isHalfDayLeaveSelected
        ? _noDaysController.text.trim()
        : _noOfDaysController.text.trim();

    if (_selectedLeave == null ||
        _startDateController.text.isEmpty ||
        _endDateController.text.isEmpty ||
        daysText.isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      isSubmitting.value = false;
      _showMessage(
        icon: Icons.warning,
        iconColor: Colors.orange,
        message: 'Please fill all required fields.',
      );
      return;
    }

    final fromSession =
        _selectedFullDayOption.isEmpty ? 'Full Day' : _selectedFullDayOption;
    final toSession =
        _selectedEndDayOption.isEmpty ? 'Full Day' : _selectedEndDayOption;

    final uri = ApiHelper.withToken(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addLeave}'));
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(ApiHelper.getMultipartHeaders());

    request.fields['user_id'] = lc.UserId?.toString() ?? '';
    request.fields['employee_id'] = lc.UserEmployeeId?.toString() ?? '';
    request.fields['type_of_leave'] =
        leaveTypeMap[_selectedLeave] ?? _selectedLeave!;
    request.fields['start_date'] = _startDateController.text;
    request.fields['end_date'] = _endDateController.text;
    request.fields['leave_day_type'] = fromSession;
    request.fields['start_day_type'] = fromSession;
    request.fields['end_day'] = toSession;
    request.fields['end_day_type'] = toSession;
    request.fields['number_days'] = daysText;
    request.fields['location'] = _locationController.text;
    request.fields['description'] = _descriptionController.text.trim();

    if (selectedFile.path.isNotEmpty) {
      try {
        final fileStream = http.ByteStream(selectedFile.openRead());
        final length = await selectedFile.length();
        request.files.add(
          http.MultipartFile(
            'attachements',
            fileStream,
            length,
            filename: p.basename(selectedFile.path),
          ),
        );
      } catch (e) {
        print('Error reading file: $e');
      }
    }

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      print('add_leave ${response.statusCode}: ${response.body}');

      final okStatus =
          response.statusCode == 200 || response.statusCode == 201;
      var apiOk = okStatus;
      try {
        final body = jsonDecode(response.body);
        if (body is Map) {
          apiOk = okStatus &&
              (body['success'] == true ||
                  body['status'] == true ||
                  body['status'] == 'true');
        }
      } catch (_) {}

      if (apiOk) {
        _showMessage(
          icon: Icons.check_circle,
          iconColor: Colors.green,
          message: 'Leave request submitted successfully!',
          onOk: () {
            vehicleController.fetchleaves(
              Get.context!,
              lc.UserId.toString(),
              lc.rollId?.toString() ?? '',
            );
            Get.find<RouteController>().back();
          },
        );
      } else {
        _showMessage(
          icon: Icons.close,
          iconColor: Colors.red,
          message: 'Leave request not submitted',
        );
      }
    } catch (e) {
      print('Exception: $e');
      _showMessage(
        icon: Icons.close,
        iconColor: Colors.red,
        message: 'Something went wrong',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showMessage({
    required IconData icon,
    required Color iconColor,
    required String message,
    VoidCallback? onOk,
  }) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 60),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onOk?.call();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }


  /*
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      Placemark place = placemarks.first;

      String address =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";

      setState(() {
        _locationController.text = address;
      });
    } catch (e) {
      setState(() {
        _locationController.text = "Unable to fetch location: $e";
      });
    }
  }
  */


  @override
  void initState() {
    super.initState();
    _noDaysController.text = '0.5';
    _selectedFullDayOption = 'Full Day';
    _selectedEndDayOption = 'Full Day';
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is removed from the widget tree
    _noDaysController.dispose();
    super.dispose();
  }

  String _displayDate(String raw) {
    if (raw.isEmpty) return 'Select date';
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final controller =
        isStart ? _startDateController : _endDateController;
    final initial = DateTime.tryParse(controller.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked == null) return;

    final formatted =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';

    setState(() {
      controller.text = formatted;
      _calculateNoOfDays();

      if (isStart) {
        if (_endDateController.text == formatted) {
          _selectedEndDayOption = 'Full Day';
        } else {
          _isEndDateDropdownEnabled = true;
        }
      } else {
        if (_startDateController.text == formatted) {
          _isEndDateDropdownEnabled = false;
          _selectedEndDayOption = 'Full Day';
        } else {
          _isEndDateDropdownEnabled = true;
        }
      }
    });
  }

  static const _fieldGap = 8.0;
  static const _sectionGap = 10.0;

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _sectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Divider(color: Colors.grey.shade200, height: 1),
    );
  }

  InputDecoration _outline({Widget? suffix, Color fill = Colors.white}) {
    return InputDecoration(
      filled: true,
      fillColor: fill,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _compactDropdown({
    required String label,
    required String hint,
    required String value,
    required List<String> items,
    required ValueChanged<dynamic> onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        IgnorePointer(
          ignoring: !enabled,
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: DropdownButtonFormField<String>(
              isDense: true,
              isExpanded: true,
              value: items.contains(value) && value.isNotEmpty ? value : null,
              hint: Text(hint, style: TextStyle(fontSize: 13, color: AppColors.hintText)),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: const TextStyle(fontSize: 13)),
                    ),
                  )
                  .toList(),
              onChanged: (val) => onChanged(val),
              decoration: _outline(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: InputDecorator(
            decoration: _outline(
              suffix: Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.text,
              ),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _daysBadge() {
    final days = isHalfDayLeaveSelected
        ? _noDaysController.text
        : _noOfDaysController.text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.backgrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.event_available_outlined, size: 14, color: AppColors.blue),
          const SizedBox(width: 6),
          Text(
            'Total days',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const Spacer(),
          Text(
            days.isEmpty ? '--' : days,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        automaticallyImplyLeading: false,
        title: ContainerWidget.backContainer(
          () => Get.find<RouteController>().back(),
          'New Leave',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // _sectionTitle('Leave'),
                    const SizedBox(height: _sectionGap),
                    _compactDropdown(
                      label: 'Type of leave *',
                      hint: 'Select leave type',
                      value: _typeofleaves.contains(_selectedLeave)
                          ? _selectedLeave!
                          : '',
                      items: _typeofleaves,
                      onChanged: (val) {
                        setState(() {
                          _selectedLeave = val?.toString();
                          _startDateController.clear();
                          _endDateController.clear();
                          _calculateNoOfDays();
                        });
                      },
                    ),
                    _sectionDivider(),
                    // _sectionTitle('Dates'),
                    const SizedBox(height: _sectionGap),
                    _dateField(
                      label: 'Start date *',
                      value: _displayDate(_startDateController.text),
                      onTap: () => _pickDate(isStart: true),
                    ),
                    if (!isHalfDayLeaveSelected) ...[
                      const SizedBox(height: _fieldGap),
                      _dateField(
                        label: 'End date *',
                        value: _displayDate(_endDateController.text),
                        onTap: () => _pickDate(isStart: false),
                      ),
                    ],
                    const SizedBox(height: _fieldGap),
                    _daysBadge(),
                    // _sectionDivider(),
                    // _sectionTitle('Details'),
                    const SizedBox(height: _sectionGap),
                    // Location capture disabled
                    // Text(
                    //   'Current location *',
                    //   style: const TextStyle(
                    //     fontSize: 13,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                    // const SizedBox(height: 4),
                    // TextField(
                    //   controller: _locationController,
                    //   readOnly: true,
                    //   maxLines: 2,
                    //   decoration: _outline(
                    //     fill: AppColors.backgrey,
                    //     suffix: Icon(
                    //       Icons.location_on_outlined,
                    //       size: 16,
                    //       color: AppColors.text,
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: _fieldGap),
                    Text(
                      'Attachments',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: _uploadAttachment,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.upload_file_outlined,
                              size: 18,
                              color: AppColors.blue,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                filePicked ? pickedFileName : 'Upload file',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: filePicked
                                      ? Colors.black
                                      : AppColors.hintText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: _fieldGap),
                    Text(
                      'Description *',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AppTextArea(
                      controller: _descriptionController,
                      hint: 'Reason for leave...',
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
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
                          isSubmitting.value ? null : submitLeaveRequest,
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
