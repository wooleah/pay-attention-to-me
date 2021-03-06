import 'package:flutter/material.dart';

class EditColorDialog extends StatefulWidget {
  final List<Color> colorList;
  final int initialColorIndex;

  const EditColorDialog({this.colorList, this.initialColorIndex});

  @override
  _EditColorDialogState createState() => _EditColorDialogState();
}

class _EditColorDialogState extends State<EditColorDialog> {
  int _selectedColorIndex;

  @override
  void initState() {
    super.initState();
    _selectedColorIndex = widget.initialColorIndex;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Change the color',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var i = 0; i < widget.colorList.length; ++i)
            RadioListTile<int>(
              value: i,
              groupValue: _selectedColorIndex,
              // activeColor: Colors.red,
              title: Container(
                height: 20,
                color: widget.colorList[i],
              ),
              onChanged: (int colorIndex) {
                setState(() {
                  _selectedColorIndex = colorIndex;
                });
              },
            )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: const Text(
            'Save',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _selectedColorIndex != null
              ? () {
                  Navigator.of(context).pop(_selectedColorIndex);
                }
              : null,
          disabledColor: Colors.white10,
        ),
      ],
    );
  }
}
