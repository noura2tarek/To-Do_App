import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/Shared/bloc/states.dart';
import '../../pages/archived_screen.dart';
import '../../pages/done_tasks_screen.dart';
import '../../pages/tasks_screen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppIntialState());

  int currentIndex = 0;
  List<Widget> screens = [
    Tasks(),
    DoneTasks(),
    ArchivedTasks(),
  ];

  List<String> titles = [
    'My Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  static AppCubit get(context) {
    return BlocProvider.of(context);
  }

  void changeIndex(int index) {
    currentIndex = index;
    emit(ChangeBottomNavBarState());
  }

  void changeBottomSheetState({
    required bool isShown,
    required IconData icon,
  }) {
    isBottomSheetShown = isShown;
    fabIcon = icon;
    emit(ChangeBottomSheetState());
  }

  void cancelDelete(BuildContext context) {
    Navigator.of(context).pop();
  }

//************************************ sql database ************************************//
  late Database database;

  void createDatabase(BuildContext context) {
    openDatabase('todo.db',
        version: 1,
        onCreate: (Database database, int version) {
          database.execute('''
          CREATE TABLE Tasks (
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           title TEXT,
           date TEXT,
           time TEXT ,
           status TEXT,
           filled INTEGER
          )
          ''').then((value) {
            print('Table created');
          }).catchError((Error) {
            print('Error occurred while creating table! ${Error.toString()}');
          });
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) {},
        onOpen: (database) {
          readData(database);
        }).then((value) {
      database = value;
      emit(CreateDatabaseState());
    }).catchError((error) {
      print('Error  ${error.toString()}');
    });
  }

  insertToDatabase({
    required String title,
    required String date,
    required String time,
  }) async {
    await database.transaction((txn) async {
      await txn
          .rawInsert(
          'INSERT INTO Tasks(title, date, time, status, filled) VALUES ("${title}", "${date}" ,"${time}", "new" ,0)')
          .then((value) {
        print(" row inserted successfully");
        emit(InsertDatabaseState());
        readData(database); // to reload ang get new data
      }).catchError((error) {
        print(error.toString());
      });
    });
  }

  void readData(Database database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(GetDatabaseLoadingState());
    database.rawQuery('SELECT * FROM Tasks').then((value) {
      for (Map<String, Object?> element in value) {
        if (element['status'] == "new") {
          newTasks.add(element);
        } else if (element['status'] == "done") {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      }

      emit(GetDatabaseState());
    }).catchError((error) {
      print('Error occurred ! ${error.toString()}');
    });
  }

  void updateMyDatabase(
      {required String status, required int filled, required int id}) {
    database.rawUpdate('UPDATE Tasks SET status = ? , filled = ?  WHERE id = ?',
        ['$status', filled, id]).then((value) {
      readData(database); // to reload tasks in the page
      emit(UpdateDatabaseState());
    }).catchError((error) {
      print(error.toString());
    });
  }

  void deleteMyDatabase() {
    deleteDatabase('todo.db').then((value) {
      emit(DeleteDatabaseState());
    });
    // print('deleted successfully');
  }

  void deleteFromMyDatabase({required int id}) {
    database.rawDelete('DELETE FROM Tasks WHERE id = ?', [id]).then((value) {
      readData(database); //to reload tasks in the page
      emit(DeleteFromDatabaseState());
    }).catchError((error) {
      print('Error  ${error.toString()}');
    });
  }
//*****************************************sql database****************************************/////////
} //class end
