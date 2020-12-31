import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class LottiePageError extends StatefulWidget {
	LottiePageError({Key key,}): super(key: key);

	@override
	_LottiePageState createState() => _LottiePageState();
}

class _LottiePageState extends State<LottiePageError> {
	BuildContext context;

	@override
	Widget build(BuildContext context) {
		return Stack(
			children:
			[
				Center(
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Lottie.asset('assets/error.json',
								  repeat: false, reverse: false, animate: true)
						],
					),
				),
				Container(
					child: Text("A manager hasn't uploaded the Excel Spreadsheet for today. Upload file then restart app",
						  textDirection: TextDirection.ltr,
						  style: TextStyle(
								fontSize: 18,
								color: Colors.redAccent,
								decoration: TextDecoration.none)),
					alignment: Alignment.bottomCenter,
					padding: EdgeInsets.only(left: 12, right: 12, bottom: 42),
				)
			],
		);
	}

}
