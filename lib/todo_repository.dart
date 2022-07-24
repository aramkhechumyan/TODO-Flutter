import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> createDB() async {
  return openDatabase(
    join(await getDatabasesPath(), 'todo_database.db'),
    onCreate: (db, version) {
      return db.execute(
        '''
        CREATE TABLE todo (
          id INTEGER PRIMARY KEY AUTO_INCREMENT,
          date TEXT,
          text TEXT
        )
        ''',
      );
    },
    version: 1,
  );
}

void addToDB(Database db,int id,String date, String text) {
  db.rawQuery(
    '''
    INSERT INTO todo (
      id,
      date,
      text
    )
    VALUES(
      0,
      'date',
      'text'
    );
    '''
  ).then((value) => print(value)).onError((error, stackTrace) => print(stackTrace));
}

Future<List<Map<String, Object>>> getItems(Database db){
  return db.rawQuery("SELECT * FROM todo;");
}

void removeFromDB(int id) {}
