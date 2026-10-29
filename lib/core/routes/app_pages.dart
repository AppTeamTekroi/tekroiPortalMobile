import 'package:travelPortal/features/expense/views/create_expense_page.dart';
import 'package:travelPortal/features/expense/views/edit_expense_log.dart';
import 'package:travelPortal/features/travel/views/edit_travel_log.dart';
import '../../features/analytics/views/analytics_details_page.dart';
import '../../features/analytics/views/analytics_page.dart';
import '../../features/travel/views/create_travel_page.dart';
import '../../features/dashboard/home_page.dart';
import '../../features/expense/views/expense_details_page.dart';
import '../../features/expense/views/expense_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/travel/views/travel_details_page.dart';
import '../../features/travel/views/travel_page.dart';
import '../../features/timesheets/views/Analytics.dart';
import '../../features/timesheets/views/Leave_request.dart';
import '../../features/timesheets/views/LeavesList.dart';
import '../../features/timesheets/views/Support.dart';
import '../../features/timesheets/views/TicketViewpage.dart';
import '../../features/timesheets/views/TimeSheets.dart';
import '../../features/timesheets/views/TimeSheetsList.dart';
import 'app_routes.dart';
import 'package:flutter/material.dart';

class AppPage extends StatelessWidget {
  final Routes page;

  const AppPage({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    switch (page) {

    /// EXISTING
      case Routes.home:
        return HomePage();

      case Routes.profile:
        return ProfilePage();

    /// TRAVEL
      case Routes.travel:
        return TravelPage();

      case Routes.travelDetails:
        return TravelDetailsPage();

    /// EXPENSE
      case Routes.expense:
        return ExpensePage();

      case Routes.expenseDetails:
        return ExpenseDetailsPage();

    /// CREATE
    //   case Routes.create:
    //     return CreatePage();

      case Routes.createTravel:
        return CreateTravelPage();

      case Routes.createExpenses:
        return CreateExpensePage();


    ///edit

      case Routes.editExpenses:
        return EditExpensePage();

      case Routes.editTravel:
        return EditTravelPage();

    /// ANALYTICS
      case Routes.analytics:
        return AnalyticsPage();

      case Routes.analyticsDetails:
        return AnalyticsDetailsPage();

    /// TIMESHEETS
      case Routes.timesheets:
        return const EngTrainingscreen();

      case Routes.createTimesheet:
        return const SparesScreen();

      case Routes.ticketView:
        return const Ticketviewpage();

      case Routes.leaves:
        return const Enginnerservicescreen();

      case Routes.createLeave:
        return const LeaveRequest();

      case Routes.timesheetSupport:
        return const Support();

      case Routes.timesheetAnalytics:
        return const Analytics();

      default:
        return const Scaffold(
          body: Center(child: Text('Route not implemented')),
        );
    }
  }
}