import 'package:flutter/material.dart';

import 'constants.dart' as Constants;

class SettingsPage extends StatefulWidget {
  final Function onSettingsSave;

  const SettingsPage({this.onSettingsSave});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var _selectedTheme;
  var _selectedFontSize;
  bool _saveEnabled = false;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Theme'),
          DropdownButton(
            value: _selectedTheme,
            hint: Text('Select your theme'),
            items: Constants.ThemeList.values.map((theme) {
              return DropdownMenuItem(
                child: Container(
                  child: Text(theme['themeName']),
                ),
                value: theme,
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedTheme = val;
                _saveEnabled = true;
              });
            },
          ),
          SizedBox(height: 20),
          Text('Font size'),
          DropdownButton(
            value: _selectedFontSize,
            hint: Text('Select your font size'),
            items: Constants.FontSizes.keys.map((sizeName) {
              return DropdownMenuItem(
                child: Container(
                  child: Text(sizeName),
                ),
                value: Constants.FontSizes[sizeName],
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedFontSize = val;
                _saveEnabled = true;
              });
            },
          ),
          RaisedButton.icon(
            onPressed: _saveEnabled ? () {
              widget.onSettingsSave(_selectedTheme, _selectedFontSize);
            } : null, 
            elevation: 0,
            disabledColor: Colors.white10,
            icon: Icon(Icons.save), label: Text('SAVE'),
          )
        ],
      ),
    );
  }
}