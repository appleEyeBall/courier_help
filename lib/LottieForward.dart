import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class LottieForward extends StatefulWidget {
  LottieForward({
    Key key,
  }) : super(key: key);

  @override
  _LottiePageState createState() => _LottiePageState();
}

class _LottiePageState extends State<LottieForward> {
  BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/forward.json',
                repeat: true, reverse: false, animate: true)
        ],
      ),
    );
  }
}
