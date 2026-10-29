import 'package:flutter/material.dart';
import 'package:travelPortal/ui/widgets/commonTextStyles.dart';
import '../../../ui/theme/appColor.dart';
import '../models/expenseModel.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel model;
  final VoidCallback? onTap;

  const ExpenseCard({
    super.key,
    required this.model,
    this.onTap,
  });

  /// 🔥 STATUS COLORS
  Color getStatusBg() {
    switch (model.status) {
      case 1:
        return Colors.blue.shade100;
      case 2:
        return Colors.green.shade100;
      case 0:
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color getStatusColor() {
    switch (model.status?.toString()) {
      case "0":
        return Colors.grey;      // Draft
      case "1":
        return Colors.blue;      // Submitted
      case "2":
        return Colors.green;     // Approved
      case "3":
        return Colors.red;       // Rejected
      default:
        return Colors.grey;
    }
  }

  String getStatusText() {
    switch (model.status) {
      case 0:
        return "Draft";
      case 1:
        return "Submitted";
      case 2:
        return "Approved";
      case 3:
        return "Rejected";
      default:
        return "Unknown";
    }
  }

  /// 🔥 AMOUNT COLOR
  Color getAmountColor() {
    final amount = double.tryParse(model.amount ?? "0") ?? 0;
    if (amount < 0) return Colors.red;
    if (amount > 0) return Colors.green;
    return Colors.black;
  }

  /// 🔥 ICON BASED ON TYPE
  IconData getIcon() {
    switch (model.expenseType?.toLowerCase()) {
      case "hotel":
        return Icons.hotel;
      case "ticket":
        return Icons.flight;
      case "restaurant":
        return Icons.restaurant;
      case "per_diem":
        return Icons.attach_money;
      default:
        return Icons.receipt_long;
    }
  }

  /// 🔥 TITLE BASED ON TYPE
  // String getTitle() {
  //   switch (model.expenseType?.toLowerCase()) {
  //     case "hotel":
  //       return model.hotelName ?? "Hotel";
  //     case "ticket":
  //       return "${model.from ?? ''} → ${model.to ?? ''}";
  //     case "restaurant":
  //       return model.restaurantName ?? "Restaurant";
  //     case "per_diem":
  //       return "Per Diem";
  //     default:
  //       return model.description ?? "Expense";
  //   }
  // }
  // String getTitle() {
  //   switch (model.expenseType?.toLowerCase()) {
  //     case "hotel":
  //       return  "Hotel";
  //     case "ticket":
  //       return "Ticket";
  //     case "restaurant":
  //       return model.restaurantName ?? "Restaurant";
  //     case "per_diem":
  //       return "Per Diem";
  //     default:
  //       return model.description ?? "Expense";
  //   }
  // }

  /// 🔥 SUBTITLE (SECOND LINE)
  String getSubtitle() {
    switch (model.expenseType?.toLowerCase()) {
      case "hotel":
        return "${model.hotelLocation ?? ''} • ${model.checkIn ?? ''} - ${model.checkOut ?? ''}";
      case "ticket":
        return "${model.travelMode ?? ''} • ${model.fromDate ?? ''}";
      case "restaurant":
        return "${model.restaurantLocation ?? ''} • ${model.restaurantDate ?? ''}";
      case "per_diem":
        return model.entries.isNotEmpty
            ? model.entries.first.location ?? ''
            : '';
      default:
        return model.companyName ?? '';
    }
  }

  /// 🔥 DATE RANGE
  String getDateRange() {
    if (model.fromDate != null && model.toDate != null) {
      return "${model.fromDate} → ${model.toDate}";
    }
    return model.date ?? "--";
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(model.amount ?? "0") ?? 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 TOP
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// LEFT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TITLE + STATUS
                      Row(
                        children: [
                          Text(
                            model.expenseType?.toUpperCase() ?? '--',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 6),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //       horizontal: 8, vertical: 3),
                          //   decoration: BoxDecoration(
                          //     color: item.travelStatus.color.withValues(alpha: 0.2),
                          //     borderRadius: BorderRadius.circular(20),
                          //   ),
                          //   child: Text(
                          //     item.travelStatus.label,
                          //     style: TextStyle(
                          //         fontSize: 14,
                          //         color:item.travelStatus.color
                          //     ),
                          //   ),
                          // ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: getStatusColor().withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              getStatusText() ?? '-',
                              style: TextStyle(
                                fontSize: 14,
                                color: getStatusColor(),
                                // fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Text(model.companyName ?? '--',
                        // getSubtitle(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      /// SUBTITLE

                    ],
                  ),
                ),
Column(
  children: [
    CommonTextStyles.commonSecondaryStyle(title: amount.toStringAsFixed(2),titleColor: AppColors.green, weight: FontWeight.w700,Size: 16),
    Text(
      model.currency ?? '-',
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey.shade600,
      ),
    ),
  ],
),
                /// ICON
                // Container(
                //   padding: const EdgeInsets.all(8),
                //   decoration: BoxDecoration(
                //     color: Colors.orange.shade50,
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: Icon(
                //     getIcon(),
                //     size: 20,
                //     color: AppColors.green,
                //   ),
                // )
              ],
            ),

            // const SizedBox(height: 12),
            // Divider(color: Colors.grey.shade200),
            //
            // CommonTextStyles.commonSecondaryStyle(title: model.description),
            // // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       getDateRange(),
            //       style: TextStyle(color: Colors.grey.shade600),
            //     ),
            //     // Text(
            //     //   model.currency ?? '',
            //     //   style: TextStyle(color: Colors.grey.shade600),
            //     // ),
            //   ],
            // ),

            const SizedBox(height: 8),
Divider(),
            CommonTextStyles.commonSecondaryStyle(title: model.description),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  model.date ?? '--',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Attached 📎",
                style: TextStyle(
                    fontSize: 14,
                    // color:_getStatusColor(item.status)
                ),
              ),
            ),
              ],
            ),
            /// 🔹 AMOUNT
            // Row(
            //   children: [
            //     Text(
            //       "${model.expenseType ?? ''}: ",
            //       style: TextStyle(color: Colors.grey.shade600),
            //     ),
            //     Text(
            //       "₹${amount.toStringAsFixed(2)}",
            //       style: TextStyle(
            //         fontWeight: FontWeight.bold,
            //         color: getAmountColor(),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}