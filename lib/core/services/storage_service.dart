import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _userIdKey = 'user_id';
  static const _tokenKey = 'token';
  static const _managerIdKey = 'manager_id';
  static const _managerNameKey = 'manager_name';
  static const _roleIdKey = 'role_id';

  late final SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveLogin(
    int id,
    String name,
    String empId, {
    String? token,
    int? managerId,
    String? managerName,
    int? roleId,
  }) async {
    await _prefs.setBool('isLogin', true);
    await _prefs.setInt(_userIdKey, id);
    await _prefs.setString("name", name);
    await _prefs.setString("employee_id", empId);
    if (token != null && token.trim().isNotEmpty) {
      await _prefs.setString(_tokenKey, token.trim());
    } else {
      await _prefs.remove(_tokenKey);
    }
    if (managerId != null) {
      await _prefs.setInt(_managerIdKey, managerId);
    } else {
      await _prefs.remove(_managerIdKey);
    }
    if (managerName != null && managerName.trim().isNotEmpty) {
      await _prefs.setString(_managerNameKey, managerName.trim());
    } else {
      await _prefs.remove(_managerNameKey);
    }
    if (roleId != null) {
      await _prefs.setInt(_roleIdKey, roleId);
    } else {
      await _prefs.remove(_roleIdKey);
    }
  }

  Future<void> saveManagerId(int? managerId) async {
    if (managerId != null) {
      await _prefs.setInt(_managerIdKey, managerId);
    } else {
      await _prefs.remove(_managerIdKey);
    }
  }

  Future<void> saveManagerName(String? managerName) async {
    if (managerName != null && managerName.trim().isNotEmpty) {
      await _prefs.setString(_managerNameKey, managerName.trim());
    } else {
      await _prefs.remove(_managerNameKey);
    }
  }

  // Read
  int? get userId => _prefs.getInt(_userIdKey);
  String? get token => _prefs.getString(_tokenKey);
  String? get userName => _prefs.getString("name");
  String? get userEmpId => _prefs.getString("employee_id");
  int? get managerId => _prefs.getInt(_managerIdKey);
  String? get managerName => _prefs.getString(_managerNameKey);
  int? get roleId => _prefs.getInt(_roleIdKey);

  bool get isLoggedIn => _prefs.getBool('isLogin') ?? false;

  // Clear
  Future<void> clearLogin() async {
    await _prefs.clear();
  }
}
