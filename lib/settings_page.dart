import 'package:flutter/material.dart';

import 'constants.dart' as Constants;
import 'models/customTheme.dart';

class SettingsPage extends StatefulWidget {
  final CustomTheme currentTheme;
  final double currentFontSize;
  final Function onSettingsSave;

  const SettingsPage({
    this.currentTheme,
    this.currentFontSize,
    this.onSettingsSave,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  CustomTheme _selectedTheme;
  double _selectedFontSize;
  bool _saveEnabled = false;
  AnimationController _animationController;
  double _saveBtnSize = 125;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
    _selectedFontSize = widget.currentFontSize;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
      lowerBound: 1,
      upperBound: 1.3,
    )
      ..addListener(() {
        setState(() {
          _saveBtnSize = _animationController.value * 125;
        });
      })
      ..addStatusListener((status) {
        setState(() {
          if (status == AnimationStatus.completed) {
            _animationController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _animationController.forward();
          }
        });
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.currentTheme.settingsPageColor,
        // image: DecorationImage(image: AssetImage('assets/images/stripes.png'), fit: BoxFit.fill)
      ),
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 16, horizontal: 70),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                    _animationController.forward();
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
            Transform.scale(
              scale: 1.1,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                width: _saveBtnSize,
                decoration: BoxDecoration(
                  color: _saveEnabled
                      ? Constants.correctColor.withOpacity(0.2)
                      : Constants.wrongColor.withOpacity(0.01),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: FlatButton.icon(
                  onPressed: _saveEnabled
                      ? () {
                          widget.onSettingsSave(
                            _selectedTheme,
                            _selectedFontSize,
                          );
                        }
                      : null,
                  disabledColor: Colors.white10,
                  icon: Icon(
                    Icons.save,
                    color: _saveEnabled
                        ? Constants.correctColor
                        : Constants.wrongColor.withOpacity(0.5),
                  ),
                  label: Text(
                    'SAVE',
                    style: Constants.settingsPageTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _saveEnabled
                          ? Constants.correctColor
                          : Constants.wrongColor.withOpacity(0.5),
                    ),
                  ),
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
