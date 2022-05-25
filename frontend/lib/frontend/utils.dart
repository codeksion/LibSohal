import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Color digitToColor(int? digit) {
  if ((digit ?? 0) == 0) {
    return Colors.red;
  }

  if (digit! < 1) return Colors.orange;
  if (digit < 2) return Colors.blue;
  return Colors.green;
}
