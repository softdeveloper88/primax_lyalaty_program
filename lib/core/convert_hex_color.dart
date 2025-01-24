import 'package:flutter/material.dart';

Color hexToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
bool isColorBlack(Color color) {
  return color == Colors.black;
}
Color setTextFitColor(Color color) {
    if(color == Colors.black){
      return Colors.white;
    }else if(color == Colors.white){
      return Colors.black;
    }else{
      return Colors.white;
    }
}