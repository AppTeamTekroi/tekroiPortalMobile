import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelPortal/features/login/controller/login_controller.dart';
import '../controllers/VehicleController.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  final RxString _selectedWork = ''.obs;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final VehicleController vehicleController = Get.find<VehicleController>();
  final LoginController loginController = Get.find<LoginController>();

  @override
  void initState() {
    super.initState();
    vehicleController.UserData();
    vehicleController.fetchsummary(context, loginController.UserId.toString());
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body:
      // LoginBackground(
      //   child:
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(h),
              _buildFilterSection(),
              Expanded(child: _buildMainContent(h)),
            ],
          ),
        ),
     // ),
    );
  }

  Widget _buildHeader(double h) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Analytics Dashboard",
            style: GoogleFonts.poppins(
              color: Colors.indigo.shade900,
              fontSize: h * 0.026,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text("Track performance and filling status",
              style: TextStyle(color: Colors.blueGrey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                value: _selectedWork.value.isEmpty ? null : _selectedWork.value,
                hint: const Text("Select Project Member", style: TextStyle(fontSize: 13)),
                isExpanded: true,
                items: vehicleController.workdata.map((u) => DropdownMenuItem(
                  value: u.id.toString(),
                  child: Text(u.name, style: const TextStyle(fontSize: 13)),
                )).toList(),
                onChanged: (v) => _selectedWork.value = v ?? '',
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          )),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildDatePicker(_startDateController, "Start Date"),
              const SizedBox(width: 8),
              _buildDatePicker(_endDateController, "End Date"),
              const SizedBox(width: 8),
              _buildClearButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(TextEditingController ctrl, String hint) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (picked != null) {
            setState(() => ctrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}");
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              const Icon(Icons.calendar_month, size: 14, color: Colors.indigo),
              const SizedBox(width: 6),
              Text(ctrl.text.isEmpty ? hint : ctrl.text, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return GestureDetector(
      onTap: () => setState(() { _startDateController.clear(); _endDateController.clear(); _selectedWork.value = ''; }),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
        child: const Icon(CupertinoIcons.clear_thick_circled, color: Colors.red, size: 18),
      ),
    );
  }

  Widget _buildMainContent(double h) {
    return Obx(() {
      final controller = vehicleController;
      if (controller.isLoading9.value) return const Center(child: CircularProgressIndicator());

      // ... (Filtering Logic same as your original code) ...
      final filteredSummaries = _getFilteredData(controller);

      if (filteredSummaries.isEmpty) return const Center(child: Text('No analytical data found.'));

      final month = controller.summaryData['month'] ?? '';
      final year = controller.summaryData['year']?.toString() ?? '';
      final holidays = List<String>.from(controller.summaryData['holidays'] ?? []);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            _buildSummaryInfo(month, year, holidays),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: filteredSummaries.length,
                itemBuilder: (context, index) => _buildEmployeeCard(filteredSummaries[index]),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryInfo(String month, String year, List<String> holidays) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Active Period", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text("$month $year", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Holidays: ", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  children: holidays.map((h) => Text(h, style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold))).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Map user) {
    return StatefulBuilder(
        builder: (context, setState) {
          bool isExpanded = false; // Note: For a proper list, manage this state in a controller or separate widget
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade50,
                child: Text(user['name'][0], style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
              ),
              title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text("EMP ID: ${user['employee_id']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      const Divider(),
                      _buildStatRow("Working Days", user['total_working_days'].toString(), Icons.work_outline),
                      _buildStatRow("Filled", user['timesheets_filled'].toString(), Icons.check_circle_outline, color: Colors.green),
                      _buildStatRow("Pending", user['pending_days'].toString(), Icons.hourglass_empty, color: Colors.orange),
                      const SizedBox(height: 10),
                      const Align(alignment: Alignment.centerLeft, child: Text("Filled Dates:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: List<String>.from(user['filled_dates'] ?? []).map((d) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                            child: Text(d, style: const TextStyle(fontSize: 10, color: Colors.blue)),
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color ?? Colors.indigo)),
        ],
      ),
    );
  }

  // Helper to maintain your original filtering logic
  List _getFilteredData(VehicleController controller) {
    final allSummaries = controller.summary;
    final selectedUserId = _selectedWork.value;
    final startDateText = _startDateController.text;
    final endDateText = _endDateController.text;
    final selectedStartDate = startDateText.isNotEmpty ? DateTime.tryParse(startDateText) : null;
    final selectedEndDate = endDateText.isNotEmpty ? DateTime.tryParse(endDateText) : null;
    final dataMonth = controller.summaryData['month']?.toString() ?? '';
    final dataYear = controller.summaryData['year']?.toString() ?? '';

    return allSummaries.where((user) {
      final matchesUser = selectedUserId.isEmpty || user['user_id'].toString() == selectedUserId;
      bool matchesDateRange = true;
      if (selectedStartDate != null && selectedEndDate != null) {
        final monthMap = {'January': 1, 'February': 2, 'March': 3, 'April': 4, 'May': 5, 'June': 6, 'July': 7, 'August': 8, 'September': 9, 'October': 10, 'November': 11, 'December': 12};
        final summaryMonthYear = DateTime(int.parse(dataYear), monthMap[dataMonth] ?? 1, 1);
        matchesDateRange = !summaryMonthYear.isBefore(selectedStartDate) && !summaryMonthYear.isAfter(selectedEndDate);
      }
      return matchesUser && matchesDateRange;
    }).toList();
  }
}