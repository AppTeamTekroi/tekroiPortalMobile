import 'package:flutter/material.dart';

import '../theme/appColor.dart';

import 'package:dropdown_search/dropdown_search.dart';

class AppDropdown extends StatelessWidget {
  final String label;
  final String? hint;
  final String value;
  final List<dynamic> items;
  final ValueChanged<dynamic> onChanged;
  final IconData? icon;
  final Color? color;
  final bool compact;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.icon,
    this.color = Colors.white,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelSize = compact ? 11.0 : 14.0;
    final gap = compact ? 2.0 : 8.0;
    final padV = compact ? 4.0 : 10.0;
    final padH = compact ? 8.0 : 12.0;
    final radius = compact ? 8.0 : 12.0;
    final fontSize = compact ? 12.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: Colors.black,
              fontSize: labelSize,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: " *",
                style: TextStyle(color: color, fontSize: labelSize),
              ),
            ],
          ),
        ),
        SizedBox(height: gap),
        DropdownSearch<String>(
          selectedItem: value.isEmpty ? null : value,
          items: (filter, _) => items.map((e) => e.toString()).toList(),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            fit: FlexFit.loose,
            constraints: BoxConstraints(
              maxHeight: compact ? 260 : 350,
              minWidth: MediaQuery.sizeOf(context).width * (compact ? 0.72 : 0.85),
            ),
            itemBuilder: (context, item, isDisabled, isSelected) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Text(
                  item,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 13 : 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              );
            },
            searchFieldProps: TextFieldProps(
              style: TextStyle(fontSize: compact ? 13 : 14),
              decoration: InputDecoration(
                hintText: "Search...",
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: compact ? 8 : 12,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          dropdownBuilder: compact
              ? (context, selectedItem) {
                  final empty =
                      selectedItem == null || selectedItem.trim().isEmpty;
                  return Text(
                    empty ? (hint ?? 'Select') : selectedItem,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: fontSize,
                      height: 1.2,
                      color: empty ? AppColors.hintText : Colors.black,
                    ),
                  );
                }
              : null,
          decoratorProps: DropDownDecoratorProps(
            baseStyle: TextStyle(fontSize: fontSize, height: 1.2),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              // Compact builder already renders the empty hint — avoid double text.
              hintText: compact ? null : (hint ?? "Select model (optional)"),
              hintStyle: TextStyle(
                color: AppColors.hintText,
                fontSize: fontSize,
                height: 1.2,
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: padV,
                horizontal: padH,
              ),
              prefixIcon: icon != null
                  ? Icon(icon, size: compact ? 16 : 18)
                  : null,
              prefixIconConstraints: compact
                  ? const BoxConstraints(minWidth: 32, minHeight: 32)
                  : null,
              suffixIconConstraints: compact
                  ? const BoxConstraints(minWidth: 28, minHeight: 28)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }
}

@override
class dropdownDisplayList<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) display;
  final Function(T?) onChanged;
  final String label;
  String? hint;
  IconData? icon;

  dropdownDisplayList({
    super.key,
    required this.value,
    required this.items,
    required this.display,
    required this.onChanged,
    required this.label,
    this.icon, this.hint,

  });

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(label,
        maxLines: 3,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500,
        )),
    const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(display(item)),
            );
          }).toList(),
          decoration: InputDecoration(
            prefixIcon: icon == null
                ? null
                : Icon(icon, size: 18, color: AppColors.text),
            hintStyle: TextStyle(color: AppColors.container.withOpacity(0.6)), // hint color
            // filled: true,
            // fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border), // border color
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border), // normal border
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary), // border when focused
            ),
          ),
          focusColor: AppColors.container,
          hint: Text(hint ?? "Select model (optional)"),

          onChanged: onChanged,
        ),
      ],
    );
  }
}


InputDecoration  decoration(IconData? icon,String hint){
 return InputDecoration(
    prefixIcon: icon == null
        ? null
        : Icon(icon, size: 18, color: AppColors.text),
    hintStyle: TextStyle(color: AppColors.container.withOpacity(0.6)), // hint color
    // filled: true,
    // fillColor: Colors.transparent,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border), // border color
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border), // normal border
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary), // border when focused
    ),
  );

}

textDrop(label){
 return Text(label,
      maxLines: 3,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500,
      ));
}