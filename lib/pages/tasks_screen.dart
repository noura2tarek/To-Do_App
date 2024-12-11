import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/Shared/bloc/cubit.dart';
import 'package:todo_app/Shared/bloc/states.dart';
import '../Shared/components/components.dart';

class Tasks extends StatelessWidget {
  const Tasks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {},
        builder: (BuildContext context, AppStates state) {
          List<Map> tasks = AppCubit.get(context).newTasks;

          return taskBuilder(tasks: tasks);
        });
  }
}
