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
      decoration: BoxDecoration(
        color: Color(0xff7B93B3),
        // image: DecorationImage(image: AssetImage('assets/images/stripes.png'), fit: BoxFit.fill)
      ),
      padding: const EdgeInsets.symmetric(vertical: 150, horizontal: 70),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          // border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(15)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Theme', style: TextStyle(fontSize: 18),),
            DropdownButton(
              value: _selectedTheme,
              hint: Text('Select your theme', style: TextStyle(fontSize: 18),),
              items: Constants.ThemeList.values.map((theme) {
                return DropdownMenuItem(
                  child: Container(
                    child: Text(theme['themeName'], style: TextStyle(fontSize: 18),),
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
            SizedBox(height: 40),
            Text('Font size', style: TextStyle(fontSize: 18),),
            DropdownButton(
              value: _selectedFontSize,
              hint: Text('Select your font size', style: TextStyle(fontSize: 18),),
              items: Constants.FontSizes.keys.map((sizeName) {
                return DropdownMenuItem(
                  child: Container(
                    child: Text(sizeName, style: TextStyle(fontSize: 18),),
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
            SizedBox(height: 40),
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
      ),
    );
  }
}