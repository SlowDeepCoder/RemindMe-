import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:remind_me/services/screen_manager.dart';

class MoleImage extends StatefulWidget {
  static const double moleWidth = 100;
  static const double moleHeight = 50;

  final int pages;

  const MoleImage({required this.pages, Key? key}) : super(key: key);

  @override
  State<MoleImage> createState() => MoleImageState();
}

class MoleImageState extends State<MoleImage> {
  double _moleOffset = 0;
  bool isDirectionRight = true;
  double angle = 0.4;

  @override
  Widget build(BuildContext context) {
    final ratio = _moleOffset/ScreenManager().screenWidth;
    final ratio2 = widget.pages == 4 ? 1 : 4;
    final bottomOffset = (sin(ratio*pi*ratio2)*25).abs();
    final leftOffset = (_moleOffset - ratio*100)/(widget.pages-1);
    double scaleX = isDirectionRight ? -1 : 1;
    final angleNoWiggle = (sin(ratio*pi)*25/100).abs()+0.3;
    angle = (sin(ratio*pi*3)*25/100)+0.3;
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
                      angle: angle,
                      child: Image.asset(
                          "assets/images/mole.png")))));
  }

  void setMoleOffset(double offset) {
    setState(() {
      if(offset == 0){
        isDirectionRight = true;
      }
      else if(offset == ScreenManager().screenWidth*(widget.pages-1)){
        isDirectionRight = false;
      }
      else {
        isDirectionRight = _moleOffset < offset;
      }
      _moleOffset = offset;
    });
  }
}
