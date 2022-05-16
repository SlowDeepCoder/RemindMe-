import 'package:flutter/cupertino.dart';
import 'package:remind_me/managers/settings_manager.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;

  const BackgroundContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration:  BoxDecoration(
          image: DecorationImage(
            image: AssetImage(SettingsManager().getCompanionBackgroundImage()),
            fit: BoxFit.cover,
          ),
        ),
        child: child);
  }
}
