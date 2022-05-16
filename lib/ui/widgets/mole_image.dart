import 'dart:math';

import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/managers/screen_manager.dart';
import 'package:remind_me/managers/settings_manager.dart';

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
  bool _isDirectionRight = true;
  double _angle = 0.4;
  bool _isAnimationEnabled = false;
  final settingsManager = SettingsManager();

  @override
  Widget build(BuildContext context) {
    final ratio = _moleOffset / ScreenManager().screenWidth;
    final ratio2 = widget.pages == 4 ? 1 : 4;
    final bottomOffset = (sin(ratio * pi * ratio2) * 25).abs();
    final leftOffset = (_moleOffset - ratio * 100) / (widget.pages - 1);
    double scaleX = _isDirectionRight ? -1 : 1;
    final angleNoWiggle = (sin(ratio * pi) * 25 / 100).abs() + 0.3;
    _angle = (sin(ratio * pi * 3) * 25 / 100) + 0.3;
    return Positioned(
        bottom: bottomOffset,
        left: leftOffset,
        child: InkWell(
            onTap: () async{
              setState(() {
              _isAnimationEnabled = true;
              });
              await Future.delayed(Duration(milliseconds: 1000));
              setState(() {
                _isAnimationEnabled = false;
              });
            },
            child: Container(
              width: MoleImage.moleWidth,
              height: MoleImage.moleHeight,
              child: ShakeAnimatedWidget(
                enabled: this._isAnimationEnabled,
                duration: Duration(milliseconds: 400),
                shakeAngle: Rotation.deg(z: 25),
                curve: Curves.linear,
                child: Transform.scale(
                    scaleX: scaleX,
                    child: Transform.rotate(
                        angle: _angle,
                        child: Image.asset(settingsManager.getCompanionBodyImage()))),
              ),
            )));
  }

  void setMoleOffset(double offset) {
    setState(() {
      if (offset == 0) {
        _isDirectionRight = true;
      } else if (offset == ScreenManager().screenWidth * (widget.pages - 1)) {
        _isDirectionRight = false;
      } else {
        _isDirectionRight = _moleOffset < offset;
      }
      _moleOffset = offset;
    });
  }
}
