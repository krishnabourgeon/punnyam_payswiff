import 'package:flutter/material.dart';

extension PaddingExtension on Widget {
  Widget leftPadding(double padding) {
    return Padding(padding: EdgeInsets.only(left: padding), child: this);
  }

  Widget rightPadding(double padding) {
    return Padding(padding: EdgeInsets.only(right: padding), child: this);
  }

  Widget topPadding(double padding) {
    return Padding(padding: EdgeInsets.only(top: padding), child: this);
  }

  Widget bottomPadding(double padding) {
    return Padding(padding: EdgeInsets.only(bottom: padding), child: this);
  }

  Widget verticalPadding(double padding) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: padding), child: this);
  }

  Widget horizontalPadding(double padding) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: padding), child: this);
  }

  Widget allPadding(double padding) {
    return Padding(padding: EdgeInsets.all(padding), child: this);
  }

  Widget symmetricPadding(
      {required double vertical, required double horizontal}) {
    return Padding(
        padding:
            EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
        child: this);
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}
