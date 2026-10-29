import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'app_routes.dart';

class RouteController extends GetxController {
  var selectedIndex = 0.obs;
  // var currentPage = Routes.home.obs;
  dynamic arguments;
  final RxList<Routes> _stack = <Routes>[Routes.home].obs;

  Rx<Routes> get currentPage => _stack.last.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  /// Push new page (like Get.to)
  void to(Routes page,{dynamic arguments}) {
    this.arguments = arguments;
    _stack.add(page);
  }

  /// Replace current page (like Get.off)
  void off(Routes page) {
    if (_stack.isNotEmpty) {
      _stack.removeLast();
    }
    _stack.add(page);
  }

  /// Clear all and go to page (like Get.offAll)
  void offAll(Routes page) {
    _stack
      ..clear()
      ..add(page);
  }

  /// Go back (like Get.back)
  void back() {
    if (_stack.length > 1) {
      _stack.removeLast();
    }
  }

  /// Switch a root tab without stacking pages
  void switchTab(Routes page) {
    arguments = null;
    if (page == Routes.home) {
      offAll(Routes.home);
      return;
    }
    _stack.assignAll([Routes.home, page]);
  }

  /// Always go to home
  void backToHome() {
    offAll(Routes.home);
  }
}

