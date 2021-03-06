import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

final textTheme = TextTheme(
  headline1: GoogleFonts.nunito(
    fontSize: 102,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.5,
  ),
  headline2: GoogleFonts.nunito(
    fontSize: 64,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
  ),
  headline3: GoogleFonts.nunito(
    fontSize: 51,
    fontWeight: FontWeight.w400,
  ),
  headline4: GoogleFonts.nunito(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  ),
  headline5: GoogleFonts.nunito(
    fontSize: 25,
    fontWeight: FontWeight.w400,
  ),
  headline6: GoogleFonts.nunito(
    fontSize: 21,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  ),
  subtitle1: GoogleFonts.nunito(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
  ),
  subtitle2: GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ),
  bodyText1: GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  ),
  bodyText2: GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  ),
  button: GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  ),
  caption: GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  ),
  overline: GoogleFonts.roboto(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.5,
  ),
);

final colorScheme = ColorScheme.dark(
  primary: Color(0xff1d0f28),
  primaryVariant: Color(0xff34273d),
  secondary: Color(0xffa60367),
  secondaryVariant: Color(0xffa60367),
  background: Color(0xff1d0f28),
  onBackground: Color(0xffffffff),
  onPrimary: Color(0xffffffff),
  onSecondary: Color(0xffffffff),
  brightness: Brightness.dark,
  error: Color(0xff72003d),
  onError: Color(0xffffffff),
  surface: Color(0xff34273d),
  onSurface: Color(0xffffffff),
);

final blindlyTheme = ThemeData(
  colorScheme: colorScheme,
  primarySwatch: createMaterialColor(colorScheme.primary),
  primaryColor: colorScheme.primary,
  primaryColorLight: colorScheme.primaryVariant,
  accentColor: colorScheme.secondary,
  backgroundColor: colorScheme.background,
  scaffoldBackgroundColor: colorScheme.background,
  accentColorBrightness: colorScheme.brightness,
  cursorColor: colorScheme.secondary,
  buttonTheme: ButtonThemeData(
    height: 50,
    buttonColor: colorScheme.secondary,
    textTheme: ButtonTextTheme.normal,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50.0),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      primary: colorScheme.secondary,
      minimumSize: Size(88, 50),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50.0)),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      primary: colorScheme.onPrimary,
      minimumSize: Size(88, 50),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
    ).copyWith(
      side: MaterialStateProperty.resolveWith<BorderSide>(
        (Set<MaterialState> states) {
          return BorderSide(
            color: colorScheme.onPrimary,
            width: 1.5,
          );
        },
      ),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      onPrimary: colorScheme.onSecondary,
      primary: colorScheme.secondary,
      minimumSize: Size(88, 50),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    foregroundColor: colorScheme.onSecondary,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: InputBorder.none,
  ),
  cardTheme: CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
  dividerColor: colorScheme.primaryVariant,
  textTheme: textTheme,
  primaryTextTheme: textTheme,
  accentTextTheme: textTheme,
  appBarTheme: AppBarTheme(
    brightness: Brightness.dark,
    color: colorScheme.primaryVariant,
    textTheme: textTheme,
    centerTitle: true,
    iconTheme: IconThemeData(
      size: 24,
      color: colorScheme.onPrimary,
    ),
    actionsIconTheme: IconThemeData(
      size: 24,
      color: colorScheme.onPrimary,
    ),
  ),
  brightness: Brightness.dark,
  primaryColorBrightness: Brightness.dark,
  snackBarTheme: SnackBarThemeData(
    backgroundColor: colorScheme.secondary,
    contentTextStyle: textTheme.subtitle1,
  ),
);
