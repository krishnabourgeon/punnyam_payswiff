import 'package:flutter/cupertino.dart';

extension WidgetExtension on Widget {
  Widget animatedSwitch(
      {Curve? curvesIn, Curve? curvesOut, int duration = 500}) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: duration),
      switchInCurve: curvesIn ?? Curves.linear,
      switchOutCurve: curvesOut ?? Curves.linear,
      child: this,
    );
  }
}

extension ConvertToSliver on Widget {
  Widget convertToSliver() {
    return SliverToBoxAdapter(
      child: this,
    );
  }
}
