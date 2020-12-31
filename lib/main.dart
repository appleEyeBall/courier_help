import 'dart:io';

import 'package:courier_help/FIrebaseTransaction.dart';
import 'package:courier_help/MainPage.dart';
import 'package:courier_help/SqlTransaction.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';    // for date


void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//		final Future<FirebaseApp> _initialization = Firebase.initializeApp();
//		final prefs = await SharedPreferences.getInstance();
//
//
//		// get the date
//		var formatter = new DateFormat('MM_dd_yyy');
//		String date = formatter.format(new DateTime.now());
//
//		var firebaseTransaction = FirebaseTransaction(date);   // object to interact with firebase services
//		SqlTransaction sqlTransaction = new SqlTransaction();
//
//		if ( isNewDay(prefs, date) ){
//			// if it's a new day on the user device. Note: doesn't necessarily mean firestore should be re-created
//			Future<File> csvFileFuture = firebaseTransaction.downloadTodayFile();
//			final oldTableName = prefs.getString('table_name') ?? "stops_$date";
//			String tableName = "stops_$date";
//			var tableValues = await csvFileFuture.then((value) => firebaseTransaction.getTable(value));
//
//			// create database, then add headers, then store tableValues in sql
//			sqlTransaction.init(oldTableName, tableName, true)
//				  .then((value) => sqlTransaction.addHeaders(tableValues[0], tableName))
//				  .then((value) => sqlTransaction.storeInSQL(tableValues, tableName))
//				  .then((value) => sqlTransaction.showTable())
//				  .whenComplete((){
//				// store name of new table in shared preference (gonna be used to retrieve the table and then delete, next day)
//				prefs.setString('table_name', "stops_$date")
//				.catchError((){
//					print("Oluwatise: there was an error");
//					prefs.clear();
//				});
//			});
//		}
//
//		if(!(await firebaseTransaction.isFirebaseDbPopulated())){
//			print("Oluwatise:: result is false");
//			if (await firebaseTransaction.isTodayInStorage()){
//				Future<File> csvFileFuture = firebaseTransaction.downloadTodayFile();
//				var tableValues = await csvFileFuture.then((value) => firebaseTransaction.getTable(value));
//				firebaseTransaction.storeInFireStore(tableValues);
//			}
//		}

    runApp(
          new MaterialApp(
              home: MainPage(),
          )
    );


}
