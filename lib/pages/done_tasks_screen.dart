import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Shared/bloc/cubit.dart';
import '../Shared/bloc/states.dart';
import '../Shared/components/components.dart';

class DoneTasks extends StatelessWidget {
  const DoneTasks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Appcubit, AppStates>(
        listener: (BuildContext context, AppStates state) {},
        builder: ( BuildContext context,  AppStates state) {
          List<Map> tasks = Appcubit.get(context).doneTasks;

          return taskBuilder(tasks: tasks);
        }
    );
  }
}