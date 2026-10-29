class ApiConstants {
  static const host = 'https://c360.zone';

  /// Main API (travel, expense, dashboard, timesheets, etc.)
  static const baseUrl = '$host/tekroi_support/api/';

  /// Auth currently served from the dev API host.
  static const authBaseUrl = '$host/tekroi_support/api/';

  /// Uploaded files / attendance photos.
  static const mediaBaseUrl = '$host/tekroi_support/';

  // ── Auth ──────────────────────────────────────────────
  static const usersList = 'users-list';
  static const mobileLogin = 'mobile-login';
  static const login = '/auth/login'; // unused legacy

  // ── Travel ────────────────────────────────────────────
  static const createTravel = 'travel-logs/';
  static const updateTravel = 'travel-logs/';
  static const travelList = 'travel-logs/';
  static const travelDelete = 'travel-delete/';
  static const customersAndProject = 'customer-project-details';

  // ── Expense ───────────────────────────────────────────
  static const expenseList = 'expenses/';
  static const createExpense = 'expenses';
  static const updateExpense = 'expenses/';
  static const expenseDelete = 'expense-delete/';

  // ── Dashboard / Profile / Analytics ───────────────────
  static const dashboard = 'mobile/dashboard/';
  static const profile = 'employee-profile/';
  static const analytics = 'dashboard/analytics/';

  // ── Timesheets / Leave / Support ──────────────────────
  static const projects = 'timesheets';
  static const timesheets = 'timesheets';
  static const timesheetDetails = 'timesheet_details';
  static const timesheetsJson = 'timesheets_json';
  static const employeeLeavesJson = 'employeeleaves_json';
  static const timesheetsMonthlySummary = 'timesheets_monthly_summary';
  static const supportJson = 'support_json';
  static const indexJson = 'index_json';
  static const leaveApproval = 'leave_approval_status';
  static const addLeave = 'add_leave';

  // ── Attendance ────────────────────────────────────────
  static const attendanceCheckIn = 'checkin';
  static const attendanceCheckOut = 'checkout';
  static const attendanceToday = 'checkin/today';
}
