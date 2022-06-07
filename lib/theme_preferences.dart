import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  static const DARK_MODE = "true";

  setDarkMode(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(DARK_MODE, value);
  }

  getDarkMode() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(DARK_MODE) ?? false;
  }
}
//Switching themes in the flutter apps - Flutterant