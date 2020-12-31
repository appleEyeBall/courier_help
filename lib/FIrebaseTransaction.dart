import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'dart:async';

/*
* Many of the functions in this class wait for storageFuture to be complete before performing actions
* This is because when storageFuture is the last .then() in the initialization in the constructor.
* Therefore other firebase fields will have values by the time storageFuture has a value
* */

class FirebaseTransaction {
  Future<firebase_storage.FirebaseStorage> storageFuture;
  FirebaseFirestore firestore;
  firebase_storage.FirebaseStorage storage;
  String today;

  FirebaseTransaction(today, bucketName) {
    this.today = today;
    // initialize Firebase, firestore and storage, then return a storage Future. When storage future is initialized,
    // then everything else is initialized
    storageFuture = Firebase.initializeApp().then((value) {
      firestore = FirebaseFirestore.instance;
    }).then((value) => storage =
        firebase_storage.FirebaseStorage.instanceFor(bucket: bucketName));
  }

  Future<File> downloadTodayFile() async {
    // Download file from Firebase-storage

    print('Oluwatise: app is started');
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File downloadToFile = File('${appDocDir.path}/fileToday.xlsx');
    print('Oluwatise: path is ${downloadToFile.path}');

    return await storageFuture.then((value) async {
      await storage.ref('/excel/${today}.xlsx').writeToFile(downloadToFile);
    }).then((value) => downloadToFile);
  }

  Future<List<List<dynamic>>> getTable(File file) {
    /*Returns a list of lists. where the first list is the heading of the table*/
    return new Future(() {
      List<List<dynamic>> result = new List(); // list of list
      var bytes = File(file.path).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table].rows) {
          result.add(row);
        }
      }
      return result;
    });
  }

  void storeInFireStore(List<List<dynamic>> tableValues) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection(today);

    Map row = Map<dynamic, dynamic>();
    //TODO: add ' ' around elements of columns
    var columns = tableValues[0];
    columns.add("checked"); // for checking and un-checking items

    for (int i = 1; i < tableValues.length; i++) {
      List<dynamic> values = tableValues[i];
      values.add(false);
      row = Map.fromIterables(columns, tableValues[i]).cast<String, dynamic>();
      // add row to sql
      print('Oluwatise firestore row is ${row}');

      print('Oluwatise firestore data is ${tableValues[i]}');
//      collection.add(row);
      collection.doc("$i").set(row);
    }
  }

  Future<void> checkFireBaseItem(int id) async {
    return new Future(() {
      CollectionReference collection =
          FirebaseFirestore.instance.collection(today);
      collection.doc("$id").update({'checked': true});
    });
  }

  Future<bool> isTodayInStorage() async {
    /* check if file with name=today exists in firebase storage */
    return await storageFuture.then((value) async {
      firebase_storage.ListResult result =
          await storage.ref("/excel").listAll();
      for (firebase_storage.Reference x in result.items) {
        if (x.name == "${today}.xlsx") {
          return true;
        }
      }
      return false;
    });
  }

  Future<bool> isFirebaseDbPopulated() async {
    /* check if firestore collection with name==today exists */
    return await storageFuture.then((value) {
      bool result = false;
      CollectionReference firebaseCollection = firestore.collection(today);
      return firebaseCollection.get().then((value) {
        print('Oluwatise: size is ${value.size}');
        if (value.size > 0) {
          print('Value was greater than zero');
          result = true;
        }
        return result;
      });
    });
  }

  Future<List<Map<String, dynamic>>> getPackages() async {
    return await FirebaseFirestore.instance.collection(today).get().then((snapshot) {
      List<Map<String, dynamic>> result = new List();
      snapshot.docs.forEach((element) {
        result.add(element.data());
      });
      return result;
    });
  }

  void uploadOutput(File file){
    try{
      firebase_storage.UploadTask uploadTask = storage.ref("/scanned/${today}_new_file.xlsx")
            .putFile(file);
      uploadTask.whenComplete(() => print("Oluwatise: upload completed"));
    }
    on FirebaseException catch (e){
      print("Oluwatise: error could not upload file");
    }
  }
}
