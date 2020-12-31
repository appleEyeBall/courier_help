import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class LottiePageComplete extends StatefulWidget {
  final String recipientName;

  LottiePageComplete(this.recipientName, {Key key,}): super(key: key);

  @override
  _LottiePageCompleteState createState() => _LottiePageCompleteState();
}

class _LottiePageCompleteState extends State<LottiePageComplete> {
  BuildContext context;

  @override
  Widget build(BuildContext context) {
    closePage().then((value) {
      Navigator.pop(context);
    });
    vibrate();
    playScanSound();
    return Stack(
      children:
	  [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/complete.json',
                  repeat: false, reverse: false, animate: true)
            ],
          ),
        ),
        Container(
          child: Text(widget.recipientName,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.lightGreen,
                  decoration: TextDecoration.none)),
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: 48),
        )
      ],
    );
  }

  Future<AudioPlayer> playScanSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("scan.mp3");
  }

  void vibrate() async{
    if (await Vibration.hasVibrator()) {
    Vibration.vibrate();
    }
  }

  Future closePage() async {
    await Future.delayed(Duration(seconds: 2));
  }
}
