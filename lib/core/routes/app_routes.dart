enum Routes {
  splash,
  home,
  profile, // ✅ added
  travel,
  travelDetails,
  expense,
  expenseDetails,
  // create,
  createTravel,
  editTravel,
  createExpenses,
  editExpenses,

  analytics,
  analyticsDetails,

  /// TIMESHEETS
  timesheets,
  createTimesheet,
  ticketView,
  leaves,
  createLeave,
  timesheetSupport,
  timesheetAnalytics,
}
extension RoutePath on Routes {
  String get path => '/${name}';
}
