import 'package:courier_help/CameraPage.dart';
import 'package:courier_help/LottieForward.dart';
import 'package:courier_help/LottiePageError.dart';
import 'package:courier_help/SqlTransaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';

import 'package:courier_help/FIrebaseTransaction.dart';

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';    // for date





/*
* This class runs before the CameraPage. It decides weather the camera page should be
* rendered, depending on if firebase initialization was successful.
* */
class MainPage extends StatelessWidget{
	bool isNewDay(prefs, date) {
		// compare the date in sharedPref to current date
		var oldTableName = prefs.getString('table_name') ?? "";
		if ("stops_$date" != oldTableName){
			return true;
		}
		return false;
	}

	@override
  Widget build(BuildContext context) {
		return FutureBuilder(
		  // Initialize FlutterFire:
		  future: init(),
		  builder: (context, snapshot) {
			  // Check for errors
			  if (snapshot.hasError) {
//				  print('Error loading flutterFire:  '+snapshot.toString());
				  return LottiePageError();
			  }

			  // Once complete, show your application
			  if (snapshot.connectionState == ConnectionState.done) {
				if (!snapshot.data)  return LottiePageError();

				  return CameraPage();
			  }
			  else{
			  	return LottieForward();
			  }

		  },
	  );
  }


	Future<bool> init() async {
		WidgetsFlutterBinding.ensureInitialized();
		final Future<FirebaseApp> _initialization = Firebase.initializeApp();
		final prefs = await SharedPreferences.getInstance();


		// get the date
		var formatter = new DateFormat('MM_dd_yyy');
		String date = formatter.format(new DateTime.now());

		var firebaseTransaction = FirebaseTransaction(date, 'csv_files_fdx');   // object to interact with firebase services
		SqlTransaction sqlTransaction = new SqlTransaction();

		// check if there is data in sql
		if ( isNewDay(prefs, date)){
			// if it's a new day on the user device. Note: doesn't necessarily mean firestore should be re-created
			if (! await firebaseTransaction.isTodayInStorage())  return false;		// return false if there is no file uploaded yet
			Future<File> csvFileFuture = firebaseTransaction.downloadTodayFile();
			final oldTableName = prefs.getString('table_name') ?? "stops_$date";
			String tableName = "stops_$date";
			var tableValues = await csvFileFuture.then((value) => firebaseTransaction.getTable(value));

			// create database, then add headers, then store tableValues in sql
			sqlTransaction.init(oldTableName, tableName, true)
				  .then((value) => sqlTransaction.addHeaders(tableValues[0], tableName))
				  .then((value) => sqlTransaction.storeInSQL(tableValues, tableName))
				  .then((value) => sqlTransaction.showTable())
				  .whenComplete((){
				// store name of new table in shared preference (gonna be used to retrieve the table and then delete, next day)
				prefs.setString('table_name', "stops_$date")
				.catchError((){
					print("Oluwatise: there was an error");
					prefs.clear();
				});
			});
		}

		// check if there is data in firestore
		if(!(await firebaseTransaction.isFirebaseDbPopulated())){
			print("Oluwatise:: result is false");

			if (! await firebaseTransaction.isTodayInStorage())  return false;		// return false if there is no file uploaded yet

			Future<File> csvFileFuture = firebaseTransaction.downloadTodayFile();
			var tableValues = await csvFileFuture.then((value) => firebaseTransaction.getTable(value));
			firebaseTransaction.storeInFireStore(tableValues);
		}

		return true;
	}


}