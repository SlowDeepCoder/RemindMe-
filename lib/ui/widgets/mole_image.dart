import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:remind_me/services/screen_manager.dart';

class MoleImage extends StatefulWidget {
  static const double moleWidth = 100;
  static const double moleHeight = 50;

  const MoleImage({Key? key}) : super(key: key);

  @override
  State<MoleImage> createState() => MoleImageState();
}

class MoleImageState extends State<MoleImage> {
  double _moleOffset = 0;

  @override
  Widget build(BuildContext context) {
    final ratio = _moleOffset/ScreenManager().screenWidth;
    final bottomOffset = sin(ratio*pi)*75;
    final leftOffset = _moleOffset - ratio*100;
    final scaleX = ratio*2-1;
    return
      Positioned(
          bottom: bottomOffset,
          left: leftOffset,
          child:
          Container(
              width: MoleImage.moleWidth,
              height: MoleImage.moleHeight,
              child: Transform.scale(
                  scaleX: scaleX,
                  child: Transform.rotate(
                      angle: 0.4,
                      child: Image.asset(
                          "assets/images/mole.png")))));
  }

  void setMoleOffset(double offset) {
    setState(() {
      _moleOffset = offset;
    });
  }
}
