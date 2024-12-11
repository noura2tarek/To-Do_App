import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlDB {
  static Database? _db;

// This function we use from the class to ensure that the database is initialized only once
  Future<Database?> get db async {
    if (_db == null) {
      _db = await initDB();
      return _db;
    } else {
      return _db;
    }
  }

  // Initialize function to initialize database, this will be called only once to create database
  // if we want to add table or edit table structure , version will change and the method (onUpgrade) will be called
  initDB() async {
    //Get a Database Location using getDataBasePath from ios or android phone
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'appDB.db'); //databasePath/ appDB.db
    Database myDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return myDatabase;
  }

  // onCreate method execute only once  in the start to create database
  _onCreate(Database db, int version) {
     db.execute('''
    CREATE TABLE Tasks(
     id INTEGER  PRIMARY KEY AUTOINCREMENT,
     title TEXT ,
     date TEXT ,
     time TEXT, 
     status TEXT
    )
    ''').then((value) => print('table created ======'));
    // the above statement creates table whose name is tasks in database.
    // To make another table execute another sql statement
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    //add a new column or drop column use on upgrade but first change the version of database
    //or delete all database and create it another time.
    await db.execute("ALTER TABLE Tasks ADD COLUMN color TEXT");
   // print('Database upgraded ======');
  }

  //CREATE done
  //SELECT to read data
  readDB(String sql) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }

  // insert data (row level)
  insertToDB(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  // update data (column level)
  updateDB(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

  // delete data
  deleteFromDB(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete(sql);
    return response;
  }

  // delete all database except the structure of it
  deleteMyDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'appDB.db');
    await deleteDatabase(path);
  }
}
