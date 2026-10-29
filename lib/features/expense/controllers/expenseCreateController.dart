import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelPortal/features/dashboard/controller/dashboard_controller.dart';
import 'package:travelPortal/features/expense/models/expenseModel.dart';
import 'package:travelPortal/features/login/controller/login_controller.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/routes/route_controller.dart';
import '../../../core/utils/helpers.dart';
import '../../../ui/widgets/loading.dart';
import '../data/expense_data.dart';
import 'package:intl/intl.dart';

class ExpenseController extends GetxController {

  final ExpenseService _service = ExpenseService();
  RouteController routeController = Get.find();
  LoginController loginController = Get.find();

  @override
  void onInit() {
    super.onInit();
    if (loginController.UserId != 0) {
      loadExpenses();
    }
  }


  RxString searchQuery = "".obs;
  RxString selectedStatus = "All".obs;
  var customer = "".obs;

// ✅ MUST be list
  RxList<ExpenseModel> filteredList = <ExpenseModel>[].obs;
  Rx<ApiResult<String>> deleteState = ApiResult<String>.initial().obs;

  void applyFilter() {
    final original = expenseState.value.data;
    print(original);
    if (original == null) return; // ✅ safety check

    List<ExpenseModel> temp = List.from(original); // ✅ copy list

    // 🎯 Status filter
    if (selectedStatus.value != "All") {
      temp = temp
          .where((item) =>
      item.status.toString() == selectedStatus.value)
          .toList();
    }

    // 🔍 Search filter
      if (searchQuery.value.isNotEmpty) {
        temp = temp.where((item) {
          final expenseType = item.expenseType ?? '';
          return expenseType
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());
        }).toList();
      }
    filteredList.value = temp;

    print("✅ FILTERED COUNT => ${filteredList.length}");
  }

  /// 🔥 STATES
  var showPicker = false.obs;

  Rx<ApiResult<List<ExpenseModel>>> expenseState =
      ApiResult<List<ExpenseModel>>.initial().obs;

  /// 🔥 DROPDOWNS
  final expenseList = ["Ticket", "Hotel", "Restaurant", "Per_Diem", "Other"];

  RxString currency = "USD (\$)".obs;
  RxString expenseType = "Ticket".obs;
  RxString travelMode = "".obs;

  /// 🔥 COMMON CONTROLLERS
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController customerRepController = TextEditingController();
  // TextEditingController companyController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  File? file;

  /// 🔥 HOTEL
  final checkInController = TextEditingController();
  final checkOutController = TextEditingController();
  final hotelNameController = TextEditingController();
  final locationController = TextEditingController();

  /// 🔥 TICKET
  final fromLocationController = TextEditingController();
  final toLocationController = TextEditingController();
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  /// 🔥 RESTAURANT
  final restarteDateController = TextEditingController();
  final restartNmaeController = TextEditingController();

  /// 🔥 PER DIEM
  TextEditingController perDiemlocationController = TextEditingController();
  TextEditingController monthYearController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController perDiemAmountController = TextEditingController();

  var perDiemList = <PerDiemEntry>[].obs;

  int? editingId;
  String? serverFile;

  /// 🔥 SETTERS
  void setExpenseType(String value) => expenseType.value = value;
  void setTravelMode(String value) => travelMode.value = value;
  void setCurrency(String value) => currency.value = value;

  /// 🔥 PER DIEM ADD
  void addEntry() {
    if (perDiemAmountController.text.isEmpty) return;

    if(checkDates(startDateController.text,endDateController.text) == false){
      AppSnackbar.error("Diem Dates should be accurate");
      return ;
    }
    
    perDiemList.add(
      PerDiemEntry(
        location: perDiemlocationController.text,
        startDate: startDateController.text,
        endDate: endDateController.text,
        amount: double.tryParse(perDiemAmountController.text) ?? 0,
        details: detailsController.text,
      ),
    );

    clearPerDiemFields();
  }

  double get totalAmount =>
      perDiemList.fold(0, (sum, item) => sum + item.amount);

  void clearPerDiemFields() {
    monthYearController.clear();
    startDateController.clear();
    endDateController.clear();
    perDiemlocationController.clear();
    perDiemAmountController.clear();
    detailsController.clear();
  }


  void copyToEditExpense(ExpenseModel model) {
    /// 🔹 ALWAYS CLEAR FIRST (IMPORTANT)
    clearForm();

    /// 🔹 BASIC (COMMON FOR ALL)
    dateController.text = model.date ?? "";
    expenseType.value = model.expenseType ?? "";
    currency.value = model.currency ?? "";
    amountController.text = model.amount ?? "";

    // customerRepController.text = model.customerRepresentative ?? "";
    customer.value = model.companyName ?? "";
    descriptionController.text = model.description ?? "";

    final type = model.expenseType;

    /// 🎫 TICKET
    if (type == "Ticket") {
      travelMode.value = model.travelMode ?? "";
      fromLocationController.text = model.from ?? "";
      toLocationController.text = model.to ?? "";
      fromDateController.text = model.fromDate ?? "";
      toDateController.text = model.toDate ?? "";
    }

    /// 🏨 HOTEL
    else if (type == "Hotel") {
      hotelNameController.text = model.hotelName ?? "";
      locationController.text = model.hotelLocation ?? "";
      checkInController.text = model.checkIn ?? "";
      checkOutController.text = model.checkOut ?? "";
    }

    /// 💰 PER DIEM
    else if (type == "Per_Diem") {
      perDiemList.clear();

      perDiemList.addAll(
        model.entries.map((e) => PerDiemEntry(
          location: e.location ?? "",
          startDate: e.startDate ?? "",
          endDate: e.endDate ?? "",
          amount: double.tryParse(e.amount ?? "0") ?? 0,
          details: e.details ?? "",
        )),
      );
    }

    /// 🍽 RESTAURANT (if using)
    else if (type == "Restaurant") {
      restarteDateController.text = model.restaurantDate ?? "";
      restartNmaeController.text = model.restaurantName ?? "";
      locationController.text = model.restaurantLocation ?? "";
    }

    /// 🔹 FILE (COMMON)
    // file = model.attachmentsUrl ?? "";

    /// 🔹 EDIT MODE
    // isEdit.value = true;
    editingId = model.id;
    serverFile = model.attachmentsUrl;
    update();
  }

  void clearForm() {
    /// 🔹 BASIC
    dateController.clear();
    expenseType.value = "Ticket";
    currency.value = "USD (\$)";
    amountController.clear();

    customerRepController.clear();
    customer.value = "";
    descriptionController.clear();

    /// 🔹 TRAVEL
    travelMode.value = "";
    fromLocationController.clear();
    toLocationController.clear();
    fromDateController.clear();
    toDateController.clear();

    /// 🔹 HOTEL
    hotelNameController.clear();
    locationController.clear();
    checkInController.clear();
    checkOutController.clear();

    /// 🔹 RESTAURANT
    restarteDateController.clear();
    restartNmaeController.clear();

    /// 🔹 FILE
    file = null;
    serverFile = null;
    /// 🔹 PER DIEM
    perDiemList.clear();

    /// 🔹 RESET EDIT MODE
    editingId = null;

    update();
  }

  void prepareNewExpense() {
    clearForm();
    dateController.text = DateFormat("yyyy-MM-dd").format(DateTime.now());
  }
  /// 🔥 PAYLOAD BUILDER
  Map<String, dynamic> buildPayload() {
    switch (expenseType.value) {
      case "Ticket":
        return {
          "date": dateController.text,
          "amount": amountController.text,
          "company":  customer.value,
          "customer_rep": customerRepController.text,

          "description": descriptionController.text,
          "currency": currency.value,
          "expense_type": "Ticket",
          "travel_mode": travelMode.value,
          "from": fromLocationController.text,
          "to": toLocationController.text,
          "from_date": fromDateController.text,
          "to_date": toDateController.text,
          "user_id": loginController.UserId?.toString() ?? '',
        };

      case "Hotel":
        return {
          "date": dateController.text,
          "amount": amountController.text,
          "company":  customer.value,
          "customer_rep": customerRepController.text,

          "description": descriptionController.text,
          "currency": currency.value,
          "expense_type": "Hotel",
          "hotel_name": hotelNameController.text,
          "hotel_location": locationController.text,
          "check_in": checkInController.text,
          "check_out": checkOutController.text,
          "user_id": loginController.UserId?.toString() ?? '',

        };

      case "Restaurant":
        return {
          "date": dateController.text,
          "amount": amountController.text,
          "company":  customer.value,
          "customer_rep": customerRepController.text,

          "description": descriptionController.text,
          "currency": currency.value,
          "expense_type": "Restaurant",
          "restaurant_date": restarteDateController.text,
          "restaurant_name": restartNmaeController.text,
          "restaurant_location": locationController.text,
          "user_id": loginController.UserId?.toString() ?? '',

        };

      case "Per_Diem":
        return {
          "date": dateController.text,
          "amount": amountController.text,
          "company":  customer.value,
          "customer_rep": customerRepController.text,

          "description": descriptionController.text,
          "currency": currency.value,
          "user_id": loginController.UserId?.toString() ?? '',
          "expense_type": "Per_Diem",
          "entries": perDiemList.map((e) => {
            "location": e.location,
            "start_date": e.startDate,
            "end_date": e.endDate,
            "amount": e.amount,
            "details": e.details,
          }).toList(),
          "total_amount": totalAmount,
        };

      default:
        return {
          "date": dateController.text,
          "amount": amountController.text,
          "customer_rep": customerRepController.text,
          "company":  customer.value,
          "description": descriptionController.text,
          "currency": currency.value,
          "expense_type": "Other",
          "user_id": loginController.UserId?.toString() ?? '',

        };
    }
  }

  bool checkDates(String from, String to){
    DateTime one = DateFormat("yyyy-MM-dd").parse(from);
    DateTime two = DateFormat("yyyy-MM-dd").parse(to);
    if(two.isBefore(one)){
      return false;
    }
    return true;
  }


  /// 🔥 VALIDATION
  bool validateForm( int type) {

    if (loginController.UserId == null || loginController.UserId == 0) {
      AppSnackbar.error("* Something went Wrong, Please Login Again");
      return false;
    }

    if (expenseType.value.isEmpty) {
      AppSnackbar.error("Expense type is required");
      return false;
    }

    if (dateController.text.isEmpty) {
      AppSnackbar.error("Date is required");
      return false;
    }

    if (expenseType.value != "Per_Diem" &&
        amountController.text.isEmpty) {
      AppSnackbar.error("Amount is required");
      return false;
    }

    if (customer.value.isEmpty) {
      AppSnackbar.error("Company is required");
      return false;
    }

    switch (expenseType.value) {
      case "Ticket":
        if (travelMode.value.isEmpty) {
          AppSnackbar.error("Travel mode required");
          return false;
        }
        if (fromLocationController.text.isEmpty ||
            toLocationController.text.isEmpty) {
          AppSnackbar.error("From & To locations required");
          return false;
        }
        if (fromDateController.text.isEmpty ||
            toDateController.text.isEmpty) {
          AppSnackbar.error("Travel dates required");
          return false;
        }
        if(checkDates(fromDateController.text,toDateController.text) == false){
          AppSnackbar.error("Travel dates should be accurate");
          return false;
        }

          break;

      case "Hotel":
        if (hotelNameController.text.isEmpty) {
          AppSnackbar.error("Hotel name required");
          return false;
        }
        if (locationController.text.isEmpty) {
          AppSnackbar.error("Hotel location required");
          return false;
        }
        if (checkInController.text.isEmpty ||
            checkOutController.text.isEmpty) {
          AppSnackbar.error("Check-in & Check-out required");
          return false;
        }
        if(checkDates(checkInController.text,checkOutController.text) == false){
          AppSnackbar.error("Hotel Checked should be accurate");
          return false;
        }

        break;

      case "Restaurant":
        if (restartNmaeController.text.isEmpty) {
          AppSnackbar.error("Restaurant name required");
          return false;
        }
        if (restarteDateController.text.isEmpty) {
          AppSnackbar.error("Restaurant date required");
          return false;
        }
        break;

      case "Per_Diem":
        if (perDiemList.isEmpty) {
          AppSnackbar.error("Add at least one entry");
          return false;
        }
        if (totalAmount == 0) {
          AppSnackbar.error("Total amount should be greater than 0");
          return false;
        }
        break;
    }

    if(file != null){
      serverFile = null;
    }

    return true;
  }


  Future<void> submitExpense(  int type) async {
    if (!validateForm(type)) return;
    print("--sub");

    LoadingOverlay.show("Submitting your expense...");

    try {
      final payload = buildPayload();

      final result = await _service.createExpense(payload, file, type);

      LoadingOverlay.hide();

      await Future.delayed(const Duration(milliseconds: 300));

      result.fold(
            (failure) {
          AppSnackbar.error(failure.message.toString());
        },
            (res) {
        final data = res;
        final ok = data is Map &&
            (data["status"] == true ||
                data["status"] == "true" ||
                data["success"] == true);

        if (ok) {
            AppSnackbar.success(
              (data["message"] ?? "Expense submitted successfully").toString(),
            );
            clearForm();
            loadExpenses();
            _refreshDashboard();
            routeController.off(Routes.expense);
          } else {
            AppSnackbar.error(
              (data is Map ? data["message"] : null)?.toString() ??
                  "Something went wrong",
            );
          }
        },
      );
    } catch (e) {
      LoadingOverlay.hide();

      await Future.delayed(const Duration(milliseconds: 300));

      AppSnackbar.error("Something went wrong");
    }
  }

  Future<void> updateExpense( int type) async {
    if (!validateForm(type)) return;
     print("--upadating $type");
    if (editingId == null || editingId == 0) return;

    LoadingOverlay.show("Updating your expense...");

    try {
      final payload = buildPayload();

      final result = await _service.updateExpense(
        payload,
        file,
        editingId.toString(),
        type.toString(),
      );

      print("sank in 0$result");

      LoadingOverlay.hide();

      result.fold(
            (failure) {
              print("sank in 1");

              AppSnackbar.error(failure.message.toString());
        },
            (res) {
              final data = res;
              final ok = data is Map &&
                  (data["status"] == true ||
                      data["status"] == "true" ||
                      data["success"] == true);

              if (ok) {
            print("sank in 2");
            AppSnackbar.success(
              (data["message"] ?? "Expense updated successfully").toString(),
            );
            clearForm();
            loadExpenses();
            _refreshDashboard();
            routeController.off(Routes.expense);

          } else {
            print("sank in 3");

            AppSnackbar.error(
              (data is Map ? data["message"] : null)?.toString() ??
                  "Something went wrong",
            );
          }
        },
      );
    } catch (e) {

      print("sank in 4");
      LoadingOverlay.hide();

      AppSnackbar.error("Something went wrong Out");
    }
  }
  /// 🔥 FETCH
  Future<void> loadExpenses() async {
    print("loading");
    expenseState.value = ApiResult.loading();

    final result = await _service.fetchExpenses(loginController.UserId.toString());
    print(result);

    result.fold(
          (failure) => expenseState.value = ApiResult.error(failure.message),
          (data) {
            final List list = data;
            if (list.isEmpty) {
              expenseState.value = ApiResult.empty();
            } else {
              expenseState.value = ApiResult.success(data);
              filteredList.value = List.from(data);
            }
          }
    );
  }

  void _refreshDashboard() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadDashboard();
    }
  }

  Future<void> deleteTravel(String id) async {
    print("travel loding");
    LoadingOverlay.show("Removing the Travel Log");
    deleteState.value = ApiResult.loading();
    try {
      final result = await _service.deleteExpense(id);
      LoadingOverlay.hide();

      result.fold(
              (failure) {
            deleteState.value = ApiResult.error(failure.message);
            AppSnackbar.error("Refresh and try again");
          },
              (data) {
            deleteState.value = ApiResult.success(data);
            AppSnackbar.success( data);
            routeController.off(Routes.expense);
            loadExpenses();
            _refreshDashboard();
          }
      );
    } catch (e) {
      LoadingOverlay.hide();
      AppSnackbar.error("Something Went Wrong, Try after some time");
      deleteState.value = ApiResult.error(e.toString());
    }
  }
}

/// MODEL
class PerDiemEntry {
  String location;
  String startDate;
  String endDate;
  double amount;
  String details;

  PerDiemEntry({
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.details,
  });
}