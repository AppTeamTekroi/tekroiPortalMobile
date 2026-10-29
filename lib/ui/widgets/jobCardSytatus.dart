import 'package:flutter/material.dart';

class AppStatus{

  static jobCardStatusIcon(int status){
    switch (status){
      case 0 :
        return Icons.filter;
      case 1 :
        return Icons.car_crash_sharp;
      case 2 :
        return Icons.build_outlined;
      case 3 :
        return Icons.list_alt_outlined;
      case 4 :
        return Icons.check_circle_outline_outlined;
    }
  }
}