import 'package:flutter/material.dart';

import 'constants.dart' as Constants;
import 'models/customTheme.dart';

class SettingsPage extends StatefulWidget {
  final CustomTheme currentTheme;
  final double currentFontSize;
  final Function onSettingsSave;

  const SettingsPage(
      {this.currentTheme, this.currentFontSize, this.onSettingsSave});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  CustomTheme _selectedTheme;
  double _selectedFontSize;
  bool _saveEnabled = false;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
    _selectedFontSize = widget.currentFontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.currentTheme.settingsPageColor,
        // image: DecorationImage(image: AssetImage('assets/images/stripes.png'), fit: BoxFit.fill)
      ),
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 70),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          // border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'Theme',
              textAlign: TextAlign.left,
              style: Constants.settingsPageTextStyle.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: 210,
              child: DropdownButton(
                isExpanded: true,
                value: _selectedTheme,
                hint: Text(
                  'Select your theme',
                  style: Constants.settingsPageTextStyle,
                ),
                items: Constants.ThemeList.values.map((theme) {
                  return DropdownMenuItem(
                    child: Container(
                      child: Text(
                        theme.themeName,
                        style: Constants.settingsPageTextStyle,
                      ),
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
            ),
            SizedBox(height: 40),
            Text(
              'Font size',
              textAlign: TextAlign.left,
              style: Constants.settingsPageTextStyle.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: 210,
              child: DropdownButton(
                isExpanded: true,
                value: _selectedFontSize,
                hint: Text(
                  'Select your font size',
                  style: Constants.settingsPageTextStyle,
                ),
                items: Constants.FontSizes.keys.map((sizeName) {
                  return DropdownMenuItem(
                    child: Container(
                      child: Text(
                        sizeName,
                        style: Constants.settingsPageTextStyle,
                      ),
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
            ),
            SizedBox(height: 40),
            FlatButton.icon(
              onPressed: _saveEnabled
                  ? () {
                      widget.onSettingsSave(_selectedTheme, _selectedFontSize);
                    }
                  : null,
              disabledColor: Colors.white10,
              icon: Icon(Icons.save),
              label: Text(
                'SAVE',
                style: Constants.settingsPageTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // SizedBox(height: 25),
            // Image.asset(
            //   Constants.companyLogoPath,
            //   scale: 1.8,
            // ),
            Image.asset(
              Constants.companyLogoWithNamePath,
              scale: 1.8,
            ),
          ],
        ),
      ),
    );
  }
}
