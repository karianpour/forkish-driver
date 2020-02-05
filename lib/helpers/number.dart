import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';

NumberFormat _formatter;

String formatNumber(BuildContext context, dynamic number){
  final local = LocalizedApp.of(context).delegate.currentLocale.languageCode;
  if(_formatter==null || _formatter.locale!=local){
    _formatter = NumberFormat.decimalPattern(local);
  }
  var formatted = _formatter.format(number);
  // if(local=='fa'){
  //   return mapToFarsi(formatted);
  // }
  return formatted;
}

String mapToFarsi(String str){
  return str.replaceAllMapped(RegExp(r"\d"), 
    (Match m) {
      return convertDigit(m[0]);
    }
  );
}

String convertDigit(String m) {
  switch(m){
    case "1":
      return "۱";
    case "2":
      return "۲";
    case "3":
      return "۳";
    case "4":
      return "۴";
    case "5":
      return "۵";
    case "6":
      return "۶";
    case "7":
      return "۷";
    case "8":
      return "۸";
    case "9":
      return "۹";
    case "0":
      return "۰";

  }
  return m;
}
