import 'package:camera/camera.dart';
import 'package:courier_help/FIrebaseTransaction.dart';
import 'package:courier_help/LottieForward.dart';
import 'package:courier_help/ScanListPage.dart';
import 'package:courier_help/SqlTransaction.dart';
import 'package:courier_help/LottiePageComplete.dart';
import 'package:courier_help/text_detector_painter.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart'; // for date
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io'; // we need this for the sleep method

import 'ScannerUtils.dart';

class CameraPage extends StatefulWidget {
  final CameraDescription camera;

  const CameraPage({Key key, this.camera}) : super(key: key);

  @override
  CameraPageState createState() {
    return CameraPageState();
  }
}

class CameraPageState extends State<CameraPage> {
  Database db;
  int sensitivity = 8;

  bool _isDetecting = false;
  VisionText _textScanResults;
  CameraController camera;

  final TextRecognizer _textRecognizer =
      FirebaseVision.instance.textRecognizer();

  CameraLensDirection _direction = CameraLensDirection.back;

  SqlTransaction sqlTransaction = new SqlTransaction();
  var sqlTransFuture;

  int lastId = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    initializeTransFuture();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xff957dad),
        onPressed: () => showListPage(context),
        icon: Icon(Icons.list),
        label: Text("Scanned list"),
      ),
      body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity < - 100) {
              showListPage(context);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              camera == null
                  ? Container(
                      color: Colors.black,
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height - 150,
                      child: CameraPreview(camera)),
              _buildResults(_textScanResults, context),
            ],
          )),
    );
  }

  void _initializeCamera() async {
    final CameraDescription description =
        await ScannerUtils.getCamera(_direction);

    camera = CameraController(
      description,
      ResolutionPreset.high,
    );

    await camera.initialize();

    camera.startImageStream((CameraImage image) {
      if (_isDetecting) return;

      setState(() {
        _isDetecting = true;
      });
      ScannerUtils.detect(
        image: image,
        detectInImage: _getDetectionMethod(),
        imageRotation: description.sensorOrientation,
      ).then(
        (results) {
          setState(() {
            if (results != null) {
              setState(() {
                _textScanResults = results;
              });
            }
          });
        },
      ).whenComplete(() => _isDetecting = false);
    });
  }

  Future<VisionText> Function(FirebaseVisionImage image) _getDetectionMethod() {
    return _textRecognizer.processImage;
  }

  Widget _buildResults(VisionText scanResults, BuildContext context) {
    CustomPainter painter;
    if (scanResults != null) {
      final Size imageSize = Size(
        camera.value.previewSize.height - 100,
        camera.value.previewSize.width,
      );
      painter = TextDetectorPainter(imageSize, scanResults);
      getWords(scanResults, context);

      return CustomPaint(
        painter: painter,
      );
    } else {
      return Container();
    }
  }

  void initializeTransFuture() async {
    // get old table name
    final prefs = await SharedPreferences.getInstance();

    final tableName = prefs.getString('table_name') ?? "stops_${getDate()}";
    sqlTransFuture = sqlTransaction.init(tableName, tableName, false);
  }

  void getWords(VisionText scanResults, BuildContext context) async {
    List<TextBlock> blocks = scanResults.blocks;
    FirebaseTransaction firebaseTransaction =
        new FirebaseTransaction(getDate(), 'csv_files_fdx');

    for (final block in blocks) {
      for (final line in block.lines) {
        sqlTransFuture.then((value) async {
          var id = (await sqlTransaction.isNameInSql(line.text
              .substring(3))); // substring(3) to omit 'to ' in 'to Oluwatise'
          if (id > 0 && id != lastId) {
            String recipientName = line.text.substring(3);
            print('Oluwatise found: $recipientName} at id = $id');
            await firebaseTransaction.checkFireBaseItem(id).whenComplete(() {
              notifyScan(recipientName, context);
              lastId = id;
            });
            return;
          }
        });
      }
    }
  }

  String getDate() {
    var formatter = new DateFormat('MM_dd_yyy');
    String date = formatter.format(new DateTime.now());
    return date;
  }

  void notifyScan(String recipientName, BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LottiePageComplete(recipientName)));
  }

  void showListPage(context){
    Navigator.push(context,
    MaterialPageRoute(builder: (context) => ScanListPage(getDate()))
    );
  }
}
