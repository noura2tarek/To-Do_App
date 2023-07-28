import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/Shared/bloc/cubit.dart';
import 'package:todo_app/Shared/bloc/states.dart';
import 'package:todo_app/Shared/components/components.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class HomeLayout extends StatelessWidget {
  HomeLayout({super.key});

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => Appcubit()..createDatabase(context),
      child: BlocConsumer<Appcubit, AppStates>(
        listener: (BuildContext context, AppStates state) {
          if (state is InsertDatabaseState) {
            Navigator.pop(context);
            titleController.text = '';
            dateController.text = '';
            timeController.text = '';
            Appcubit.get(context)
                .changeBottomSheetState(isShown: false, icon: Icons.edit);
          }
        },
        builder: (BuildContext context, AppStates state) {
          Appcubit cubit = Appcubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.titles[cubit.currentIndex]),
            ),
            body: ConditionalBuilder(
              condition: state is! GetDatabaseLoadingState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(
                cubit.fabIcon,
              ),
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertToDatabase(
                        title: titleController.text,
                        date: dateController.text,
                        time: timeController.text);
                  } else {
                    return;
                  }
                } else {
                  scaffoldKey.currentState
                      ?.showBottomSheet(
                        elevation: 20.0,
                        (context) => Container(
                          padding: const EdgeInsetsDirectional.all(20.0),
                          color: Colors.grey[100],
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                    preficon: Icons.title,
                                    type: TextInputType.text,
                                    controller: titleController,
                                    label: 'Task Title',
                                    validator: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'Task title must not be null';
                                      }
                                      return null;
                                    }),
                                const SizedBox(
                                  height: 12.0,
                                ),
                                defaultFormField(
                                  preficon: Icons.watch_later_outlined,
                                  type: TextInputType.none,
                                  controller: timeController,
                                  label: "Task Time",
                                  validator: (String? value) {
                                    if (value!.isEmpty) {
                                      return 'Task time must not be null';
                                    }
                                    return null;
                                  },
                                  onTab: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then(
                                      (TimeOfDay? value) {
                                        timeController.text =
                                            value!.format(context);
                                      },
                                    ).catchError((error) {
                                      print('error${error.toString()}');
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 12.0,
                                ),
                                defaultFormField(
                                  preficon: Icons.date_range,
                                  type: TextInputType.none,
                                  controller: dateController,
                                  label: "Task Date",
                                  validator: (String? value) {
                                    if (value!.isEmpty) {
                                      return 'Task date must not be null';
                                    }
                                    return null;
                                  },
                                  onTab: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2023-08-20'),
                                    ).then((DateTime? value) {
                                      dateController.text = DateFormat.yMMMd()
                                          .format(value!); // to format date as year, month day using intl package
                                    }).catchError((error) {
                                      print('${error.toString()}');
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(
                        isShown: false, icon: Icons.edit);
                  });
                  cubit.changeBottomSheetState(isShown: true, icon: Icons.add);
                }
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              // show the selected label or not
              showUnselectedLabels: true,
              // show the unselected labels or not
              onTap: (index) {
                cubit.changeIndex(index);
              },
              currentIndex: cubit.currentIndex,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.done_all_outlined),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive_outlined),
                  label: 'Archived',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// to create database locally:
//1. use sqfLite package
//2. create database
//3. create table
//4. open database
//5. insert to database
//6. get from database
//7. update in database
//8. delete from database
