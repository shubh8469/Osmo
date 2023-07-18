// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:news/utils/uiUtils.dart';

Widget dateView(BuildContext context, String date) {
  return Text(
    UiUtils.convertToAgo(context, DateTime.parse(date), 0)!,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8), fontSize: 12.0, fontWeight: FontWeight.w600),
  );
}
