import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:scomb_mobile/common/utils.dart';

class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("色選択"),
      children: [
        BlockPicker(
          pickerColor: Colors.white,
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
            Colors.white70
          ],
          layoutBuilder: (context, colors, child) {
            Orientation orientation = MediaQuery.of(context).orientation;
            return SizedBox(
              width: 300,
              height: orientation == Orientation.portrait ? 360 : 240,
              child: GridView.count(
                crossAxisCount: orientation == Orientation.portrait ? 6 : 7,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                children: [for (Color color in colors) child(color)],
              ),
            );
          },
          onColorChanged: (color) {
            Navigator.pop(context, color.value);
          },
        ),
      ],
    );
  }
}
