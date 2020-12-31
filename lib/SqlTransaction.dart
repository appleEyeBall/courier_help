import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';


class SqlTransaction{
	Database sqlDb;
	String tableName;

	Future<void> init(String oldTableName, String tableName, bool createNew) async{
		print('Oluwatise: dropping table');
		final Future<Database> sqlDatabase = openDatabase(
			join(await getDatabasesPath(), 'delivery.db'),
			version: 1,
		);

		sqlDb =  await sqlDatabase;
		this.tableName = tableName;
		// get and delete previous table
		if (createNew){
			await sqlDb.execute("DROP TABLE IF EXISTS $oldTableName");
		}
	}

	Future<void> addHeaders(columns, tableName) async{
		//NOTE: make sure you pass in tableValues[0] as columns

		return Future(() async{
			// formulate column heading e.g:
			// 'Ship to Name' TEXT, 'Street 1' TEXT, 'Street 2' TEXT, City TEXT, 'State/Province' TEXT, Postal TEXT, Route TEXT
			print('Oluwatise: adding headers');
			String headingQuery = "";
			for (int i=0; i<columns.length; i++){
				String col = columns[i];
				headingQuery += "`$col` Text";
				// add a comma after each iteration except last iteration
				if (i != columns.length-1){
					headingQuery+= ", ";
				}
			}

			print('Oluwatise: The heading query is $headingQuery');
			await sqlDb.execute("Create Table $tableName (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $headingQuery)");
		});
	}

	void storeInSQL(List<List<dynamic>> tableValues, tableName) async{
		Map row = Map<dynamic, dynamic>();
		//TODO: add ' ' around elements of columns
		var columns_temp = tableValues[0];
		var columns = List<dynamic>();
		// add ' ' around each element in column
		for (String elem in columns_temp){
			columns.add("'${elem}'");
		}


		for (int i=1; i< tableValues.length; i++){
			List<dynamic> values = tableValues[i];
			row = Map.fromIterables(columns, tableValues[i]).cast<String, dynamic>();
			// add row to sql
			print('Oluwatise row is ${row}');

			print('Oluwatise data is ${tableValues[i]}');
			sqlDb.insert(tableName, row, conflictAlgorithm: ConflictAlgorithm.replace);
		}
	}

//	List<dynamic> makeUpper(values){
//		List<dynamic> res = new List();
//		for (String val in values){
//			res.add(val.toUpperCase());
//		}
//		return res;
//	}

	Future<List<dynamic>> showTable() async {
		// Query the table for all The Dogs.
		final List<Map<String, dynamic>> maps = await sqlDb.query(tableName);

		// Convert the List<Map<String, dynamic> into a List<Dog>.
		print('Oluwatise: list is $maps');
		return maps;
	}

	Future<int> isNameInSql(String value) async{
		print("Oluwatise: searching sql");
		value = value.toUpperCase();
		print("Oluwatise: tableName is $tableName and value is $value");
		var dbRes = await sqlDb.rawQuery("SELECT * FROM $tableName WHERE UPPER(`Ship to Name`) = UPPER('$value')");
		if (dbRes.isEmpty){
			return 0;
    	}
		else{
			print('Oluwatise:: showing ${dbRes[0]['id']}');
			int res = dbRes[0]['id'];
			print('Oluwatise:: not empty $dbRes');
			print('Oluwatise:: gonna return $res');
			return res;
		}
	}

//	Future<int> isStreetInSql(String value) async{
//		print("Oluwatise: searching sql");
//		value = value.toUpperCase();
//		print("Oluwatise: tableName is $tableName and value is $value");
//		var dbRes = await sqlDb.rawQuery("SELECT * FROM $tableName WHERE UPPER(`Street 1`) LIKE UPPER('$value'%)");
////		var dbRes = await sqlDb.query(tableName, where: "`Ship to Name` = ?", whereArgs: [value]);
//		if (dbRes.isEmpty){
//			return 0;
//		}
//		else{
//			print('Oluwatise:: showing ${dbRes[0]['id']}');
//			int res = dbRes[0]['id'];
//			print('Oluwatise:: not empty $dbRes');
//			print('Oluwatise:: gonna return $res');
//			return res;
//		}
//	}
}