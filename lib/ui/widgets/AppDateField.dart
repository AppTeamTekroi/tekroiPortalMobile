import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:travelPortal/ui/widgets/commonTextStyles.dart';
import '../theme/appColor.dart';
import 'package:intl/intl.dart';

class AppDateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final Color? color;
  const AppDateField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = "Select date",
    this.icon,
    this.color = Colors.white,
  });

  Future<void> _selectDate(BuildContext context) async {

    DateTime now = DateTime.now();

    // DateTime startOfCurrentMonth = DateTime(now.year, now.month, 1);

    // Start of last month
    DateTime startOfLastMonth = DateTime(
      now.month == 1 ? now.year - 1 : now.year,
      now.month == 1 ? 12 : now.month - 1,
      1,
    );

    // End of current month
    // DateTime endOfCurrentMonth = DateTime(now.year, now.month + 1, 0);

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: startOfLastMonth,
      lastDate: now,
    );

    if (picked != null) {
      controller.text = DateFormat("yyyy-MM-dd").format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        RichText(
          maxLines: 3,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: label,
            style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w500,),
            children: [
              TextSpan(
                text: " *",
                style: TextStyle(color: color),
              ),
            ],
          ),
        ),
        // Text(label,
        //     maxLines: 3,
        //     softWrap: true,
        //     overflow: TextOverflow.ellipsis,
        //     style: const TextStyle(
        //       fontSize: 14, fontWeight: FontWeight.w500,
        //     )),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(context),
          decoration: InputDecoration(
            hintText: "dd/mm/yyy",
            hintStyle: TextStyle(
              color: AppColors.hintText,
              fontSize:  17,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
            prefixIcon: icon != null ? Icon(icon) : null,
            suffixIcon: const Icon(Icons.calendar_today_outlined,size: 19,),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border), // normal border
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:  BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}


class AppTimeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final Color? color;
  final Function(String time)? onTimeSelected;

  const AppTimeField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = "--:-- --",
    this.icon,
    this.color = Colors.white,
    this.onTimeSelected, // 👈 add this

  });

  Future<void> pickTime(BuildContext context) async {

    /// ✅ Get typed value
    TimeOfDay initialTime =
        parseTime(controller.text) ?? TimeOfDay.now();

    // TimeOfDay? pickedTime = await showTimePicker(
    //   context: context,
    //   initialTime: initialTime,
    //
    //   builder: (context, child) {
    //     return MediaQuery(
    //       data: MediaQuery.of(context)
    //           .copyWith(alwaysUse24HourFormat: false),
    //       child: child!,
    //     );
    //   },
    // );

    if (initialTime == null) return;

    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      initialTime.hour,
      initialTime.minute,
    );

    /// ✅ Final formatted output
    final formatted = DateFormat("hh:mm a").format(dateTime);
    controller.text = formatted;
    if (onTimeSelected != null) {
      onTimeSelected!(formatted);
    }
  }

  TimeOfDay? parseTime(String input) {
    try {
      final format = DateFormat("hh:mm a");
      final dateTime = format.parseStrict(input);
      return TimeOfDay.fromDateTime(dateTime);
    } catch (e) {
      return null; // invalid input
    }
  }
  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat("hh:mm a").format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          maxLines: 3,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: label,
            style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w500,),
            children: [
              TextSpan(
                text: " *",
                style: TextStyle(color: color),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.datetime,
          inputFormatters: [TimeInputFormatter()],
          readOnly: true,
          /// ✅ Correct place for logic
          onChanged: (value) {
            // Only format if user already entered AM/PM
            if (value.toUpperCase().contains("AM") ||
                value.toUpperCase().contains("PM")) {

              final parsed = parseTime(value.trim());

              if (parsed != null) {
                controller.text = formatTimeOfDay(parsed);

                controller.selection = TextSelection.collapsed(
                  offset: controller.text.length,
                );
              }
            }
          },
          decoration: InputDecoration(
            // labelText: label,
            hintText: "-- -- --",
            hintStyle: TextStyle(
              color: AppColors.hintText,
              fontSize:  17,
            ),
            prefixIcon: icon != null ? Icon(icon) : null,
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),

            /// ✅ Picker icon
            suffixIcon: IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () => pickTime(context),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

}


// class AppTimeField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final String hint;
//   final IconData? icon;
//   final Color? color;
//   final Function(String time)? onTimeSelected;
//
//   const AppTimeField({
//     super.key,
//     required this.controller,
//     required this.label,
//     this.hint = "--:-- --",
//     this.icon,
//     this.color = Colors.white,
//     this.onTimeSelected, // 👈 add this
//
//   });
//
//   Future<void> pickTime(BuildContext context) async {
//
//     /// ✅ Get typed value
//     TimeOfDay initialTime =
//         parseTime(controller.text) ?? TimeOfDay.now();
//
//     TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: initialTime,
//
//       builder: (context, child) {
//         return MediaQuery(
//           data: MediaQuery.of(context)
//               .copyWith(alwaysUse24HourFormat: false),
//           child: child!,
//         );
//       },
//     );
//
//     if (pickedTime == null) return;
//
//     final now = DateTime.now();
//     final dateTime = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       pickedTime.hour,
//       pickedTime.minute,
//     );
//
//     /// ✅ Final formatted output
//     final formatted = DateFormat("hh:mm a").format(dateTime);
//     controller.text = formatted;
//     if (onTimeSelected != null) {
//       onTimeSelected!(formatted);
//     }
//   }
//
//   TimeOfDay? parseTime(String input) {
//     try {
//       final format = DateFormat("hh:mm a");
//       final dateTime = format.parseStrict(input);
//       return TimeOfDay.fromDateTime(dateTime);
//     } catch (e) {
//       return null; // invalid input
//     }
//   }
//   String formatTimeOfDay(TimeOfDay time) {
//     final now = DateTime.now();
//     final dateTime = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       time.hour,
//       time.minute,
//     );
//     return DateFormat("hh:mm a").format(dateTime);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           maxLines: 3,
//           softWrap: true,
//           overflow: TextOverflow.ellipsis,
//           text: TextSpan(
//             text: label,
//             style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w500,),
//             children: [
//               TextSpan(
//                 text: " *",
//                 style: TextStyle(color: color),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           keyboardType: TextInputType.datetime,
//           inputFormatters: [TimeInputFormatter()],
//
//           /// ✅ Correct place for logic
//           onChanged: (value) {
//             // Only format if user already entered AM/PM
//             if (value.toUpperCase().contains("AM") ||
//                 value.toUpperCase().contains("PM")) {
//
//               final parsed = parseTime(value.trim());
//
//               if (parsed != null) {
//                 controller.text = formatTimeOfDay(parsed);
//
//                 controller.selection = TextSelection.collapsed(
//                   offset: controller.text.length,
//                 );
//               }
//             }
//           },
//           decoration: InputDecoration(
//             // labelText: label,
//             hintText: "-- -- --",
//             hintStyle: TextStyle(
//               color: AppColors.hintText,
//               fontSize:  17,
//             ),
//             prefixIcon: icon != null ? Icon(icon) : null,
//             contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
//
//             /// ✅ Picker icon
//             suffixIcon: IconButton(
//               icon: const Icon(Icons.access_time),
//               onPressed: () => pickTime(context),
//             ),
//
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.border),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.primary),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
// }


class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String text = newValue.text.toUpperCase();

    /// ✅ Allow only valid chars
    text = text.replaceAll(RegExp(r'[^0-9APM:]'), '');

    /// ✅ Auto add colon (12 → 12:)
    if (text.length == 2 && !text.contains(':')) {
      text = "$text:";
    }

    /// ✅ Limit length (hh:mm AM)
    if (text.length > 8) {
      text = text.substring(0, 8);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}