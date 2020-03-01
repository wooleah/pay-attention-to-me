import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveSettings({String themeName, double fontSize}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('themeName', themeName);
  await prefs.setDouble('fontSize', fontSize);
}

Future<Map<String, dynamic>> getSettings() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'themeName': prefs.getString('themeName'),
    'fontSize': prefs.getDouble('fontSize')
  };
}
