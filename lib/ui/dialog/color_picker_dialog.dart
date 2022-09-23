import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../common/utils.dart';

class ColorPickerDialog extends StatelessWidget {
  int? selectedColor;
  Color? defaultColor;

  ColorPickerDialog({this.defaultColor, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlockPicker(
        pickerColor: Colors.black,
        availableColors: [
          hexToColor("#FFEF9A9A"),
          hexToColor("#FFF48FB1"),
          hexToColor("#FFCE93D8"),
          hexToColor("#FFB39DDB"),
          hexToColor("#FF9FA8DA"),
          hexToColor("#FF90CAF9"),
          hexToColor("#FF81D4FA"),
          hexToColor("#FF80DEEA"),
          hexToColor("#FF80CBC4"),
          hexToColor("#FFA5D6A7"),
          hexToColor("#FFC5E1A5"),
          hexToColor("#FFE6EE9C"),
          hexToColor("#FFFFF59D"),
          hexToColor("#FFFFE082"),
          hexToColor("#FFFFCC80"),
          hexToColor("#FFFFAB91"),
          hexToColor("#FFBCAAA4"),
          // default color
          defaultColor != null ? defaultColor! : Colors.white70
        ],
        layoutBuilder: (context, colors, child) {
          Orientation orientation = MediaQuery.of(context).orientation;
          return SizedBox(
            width: 300,
            height: orientation == Orientation.portrait ? 180 : 100,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: orientation == Orientation.portrait ? 6 : 7,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              children: [
                for (Color color in colors) child(color),
              ],
            ),
          );
        },
        onColorChanged: (color) {
          selectedColor = color.value;
          Navigator.pop(context, color.value);
        },
      ),
    );
  }
}
