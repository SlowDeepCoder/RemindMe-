import 'package:flutter/material.dart';
import 'package:remind_me/managers/screen_manager.dart';
import 'package:remind_me/ui/models/checklist.dart';
import 'package:remind_me/ui/models/note.dart';
import 'package:remind_me/ui/screens/edit_checklist_screen.dart';
import 'package:remind_me/ui/screens/home_screen.dart';
import 'package:remind_me/ui/screens/edit_note_screen.dart';
import 'package:remind_me/util/color_constants.dart';

import 'managers/settings_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsManager = SettingsManager();
  await settingsManager.loadSettings();
  final GlobalKey<MyAppState> _myAppGlobalKey = GlobalKey();
  settingsManager.setKey(_myAppGlobalKey);
  runApp(MyApp(
    key: _myAppGlobalKey,
  ));
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final settingsManager = SettingsManager();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        _setScreenDimensions(context);
        if (child != null) {
          return child;
          // return MediaQuery(
          //     data:
          //         MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          //     child: child);
        } else {
          return Container();
        }
      },
      title: 'Mole Planner',
      theme: ThemeData(
          fontFamily: "OpenSans",
          colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: settingsManager.getCompanionMainColor(),
              brightness: Brightness.light,
              onPrimary: settingsManager.getCompanionTextColor(),
              onSecondary: settingsManager.getCompanionTextColor()),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              primary: settingsManager.getCompanionMainColor(), // Button color
              onPrimary: ColorConstants.sand, // Text color
            ),
          ),
          textTheme: const TextTheme(
            bodyText1: TextStyle(),
            bodyText2: TextStyle(),
          ).apply(
            bodyColor: settingsManager.getCompanionTextColor(),
            decorationColor: settingsManager.getCompanionTextColor(),
          ),
          cardTheme: CardTheme(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: ColorConstants.sand.withOpacity(0.5),
                    width: 2,
                  ))),
          bottomSheetTheme:
              BottomSheetThemeData(backgroundColor: ColorConstants.soil)
          // inputDecorationTheme: s
          ),
      initialRoute: "/",
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        EditNoteScreen.routeName: (context) => EditNoteScreen(
            note: ModalRoute.of(context)!.settings.arguments as Note?),
        EditChecklistScreen.routeName: (context) => EditChecklistScreen(
            checklist:
                ModalRoute.of(context)!.settings.arguments as Checklist?),
      },
    );
  }

  void _setScreenDimensions(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    ScreenManager().setScreenWidth(screenWidth);
    ScreenManager().setScreenHeight(screenHeight);
  }

  update() {
    setState(() {});
  }
}
