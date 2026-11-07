import 'package:flutter/material.dart';
import 'package:punnyam/common/color_palette.dart';

class PunnyamSwitch extends StatefulWidget {
  const PunnyamSwitch({super.key, required this.isOn, required this.onTap});
  final bool isOn;
 final Function(bool value)? onTap;
  @override
  State<PunnyamSwitch> createState() => _PunnyamSwitchState();
}

class _PunnyamSwitchState extends State<PunnyamSwitch> {
  @override
  Widget build(BuildContext context) {
    return Switch(
      // This bool value toggles the switch.
      value: widget.isOn,
      activeColor: ColorPalette.orange,
      onChanged: widget.onTap,
    );
  }
}
