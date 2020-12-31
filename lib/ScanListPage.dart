import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courier_help/FIrebaseTransaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ScanListPage extends StatefulWidget {
  String today;

  ScanListPage(
    this.today, {
    Key key,
  }) : super(key: key);

  @override
  _ScanListPageState createState() => _ScanListPageState();
}

class _ScanListPageState extends State<ScanListPage> {
  FirebaseTransaction firebaseTransaction;
  List<Map<String, dynamic>> packages = new List();   // raw result from firestore
  List<DeliveryItem> deliveries = new List();   // contains widgets to be displayed (data from packages)


  @override
  Widget build(BuildContext context) {
    print("Oluwatise: size of packages is ${deliveries.length}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff957dad),
        title: Text("Scanned List"),
        actions: [
          Padding(padding: EdgeInsets.only(right: 40),
          child: Builder(
            builder: (scaffoldContext) => GestureDetector(
                  onTap: () => getExcel(scaffoldContext),
                  child: Icon(Icons.cloud_download)),
          ),
          )
        ],
      ),
      backgroundColor: Color(0xffFBEBFF),
      body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity > 100) {
              Navigator.pop(context);
            }
          },
          child: ListView.builder(
            padding: EdgeInsets.only(top: 4, bottom: 4),
            itemCount: deliveries.length,
            itemBuilder: (context, index) {
              return deliveries[index];
            },
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    firebaseTransaction = FirebaseTransaction(widget.today, 'csv_files_fdx');
    firebaseTransaction.getPackages().then((result) {
      setState(() {
        packages = result;
        print(packages);
        for (var val in result) {
          deliveries.add(DeliveryItem(val['Ship to Name'], val['Street 1'],
              val['Street 2'], val['checked']));
        }
      });
    });
  }

  void getExcel(BuildContext context) async{
    TextStyle style = new TextStyle(color: Color(0xFFCFF0CC), fontSize: 18);
    var snackbar = SnackBar(content: Text("Spreadsheet uploaded to 'scanned' folder ", style: style));

    Scaffold.of(context).showSnackBar(snackbar);
    File spreadSheet = await createSpreadSheet();
    firebaseTransaction.uploadOutput(spreadSheet);


  }

  Future<File> createSpreadSheet() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = "${directory.path}/new_${widget.today}.xlsx";

    // create a spreadsheet
    var newExcel = Excel.createExcel();
    Sheet sheetObject = newExcel['Sheet1'];
    // populate and style the header
    SplayTreeMap sortedHeader = SplayTreeMap.from(packages[0]);   // convert to splayTree to preserve order
    var header = sortedHeader.keys.toList();
    sheetObject.appendRow(header);
    for (int i=0; i<header.length; i++){
      var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      CellStyle headerStyle = CellStyle(bold: true);
      cell.cellStyle = headerStyle;
    }

    // populate and style the rest of the spreadsheet
    int checkedPos = header.indexOf("checked");   // remember the col number of the checked column
    print("Oluwatise: checkedPos is $checkedPos");
    int totalRows = 0;
    int totalChecked = 0;
    for (int i=0; i<packages.length; i++){
      var sortedRow = SplayTreeMap.from(packages[i]);   // convert to splayTree to preserve order
      var row = sortedRow.values.toList();
      print("Oluwatise: row is $row");
      sheetObject.appendRow(row);
      CellStyle greenBackground = CellStyle(backgroundColorHex: "#CFFFE5");

      // if it has been scanned, set to background color
      if (packages[i]["checked"]){
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: checkedPos, rowIndex: i+1));    // +1 to skip header
        cell.cellStyle = greenBackground;
        totalChecked++;
      }
      totalRows++;
    }

    // add another row to show total
    var aggregateRow = ["Scanned:",  "$totalChecked", "out of", "$totalRows", "Packages"];
    sheetObject.appendRow([" ", " "]);  sheetObject.appendRow([" ", " "]);
    sheetObject.appendRow(aggregateRow);




    print("Oluwatise: Write complete");
    return newExcel.encode().then((value) {
      return File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(value);
    });
  }
}

class DeliveryItem extends StatelessWidget {
  final String name;
  final String address;
  String address2;
  final bool checked;

  DeliveryItem(this.name, this.address, this.address2, this.checked);

  @override
  Widget build(BuildContext context) {
    if (this.address2 == null) {
      this.address2 = "";
    }
    return Card(
      color: Color(0x2a816C96),
      child: Container(
        height: 68,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(right: 8),
        child: Row(
          children: [
            Container(
              width: 10,
              height: double.infinity,
              color: checked ? Colors.greenAccent : Color(0x00000000),
              margin: EdgeInsets.only(right: 8),
            ),
            Column(children: [
              Text("$address $address2", style: TextStyle(fontSize: 18, color: Colors.white)),
              Text(name, style: TextStyle(fontSize: 17, color: Colors.white70))
            ])
          ],
        ),
      ),
    );
  }
}
