// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/utils/validators.dart';
import 'package:news/ui/screens/auth/Widgets/fieldFocusChange.dart';

class SetAge extends StatelessWidget {
  final FocusNode currFocus;
  final FocusNode nextFocus;
  final TextEditingController AgeC;
  final VoidCallback datePicker;
  late String name;

  SetAge({
    Key? key,
    required this.currFocus,
    required this.nextFocus,
    required this.AgeC,
    required this.name,
    required this.datePicker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: TextFormField(
        readOnly: true,
        focusNode: currFocus,
        textInputAction: TextInputAction.next,
        controller: AgeC,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: UiUtils.getColorScheme(context).primaryContainer,
        ),
        validator: (val) => Validators.nameValidation(val!, context),

        onFieldSubmitted: (v) {
          fieldFocusChange(context, currFocus, nextFocus);
        },
        decoration: InputDecoration(
          hintText: "DD-MM-YYYY",
          hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.5),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 17),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: UiUtils.getColorScheme(context).outline.withOpacity(0.7)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onTap: datePicker,
      ),
    );
  }
}
