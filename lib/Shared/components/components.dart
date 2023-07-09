import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/Shared/bloc/cubit.dart';
import 'package:todo_app/Shared/bloc/states.dart';

Widget defaultFormField({
  required TextInputType type,
  required TextEditingController controller,
  required String label,
  IconData? preficon,
  IconData? sufficon,
  String? Function(String?)? validator,
  void Function()? suffixPreesed,
  void Function(String)? onSubmit,
  void Function(String)? onChange,
  bool isObsecure = false,
  void Function()? onTab,
}) {
  return TextFormField(
    keyboardType: type,
    controller: controller,
    validator: validator,
    obscureText: isObsecure,
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      labelText: label,
      prefixIcon: Icon(
        preficon,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          sufficon,
        ),
        onPressed: suffixPreesed,
      ),
    ),
    onTap: onTab,
    onFieldSubmitted: onSubmit,
    onChanged: onChange,
  );
}

Widget buildTaskItem(Map taskModel, BuildContext context) {
  Appcubit myCubit = Appcubit.get(context);
  return GestureDetector(
    onLongPress: (){
      showAlertDialog(taskModel:taskModel ,context: context);
    },
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                //update data
                if (taskModel['status'] == 'done' ||
                    taskModel['status'] == 'archived') {
                  return;
                } else {
                  myCubit.updateMydatabase(
                      status: 'done', id: taskModel['id'], filled: 1);
                }
              },
              icon: Icon(
                taskModel['filled'] == 1
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: taskModel['filled'] == 1 ? Colors.green : Colors.black45,
                size: 32.0,
              ),
            ),
            SizedBox(
              width: 6.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${taskModel['title']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(
                    height: 6.0,
                  ),
                  Row(
                    children: [
                      Text(
                        '${taskModel['date']}',
                        style: TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.symmetric(horizontal: 6.0),
                        child: CircleAvatar(
                          radius: 1.0,
                          backgroundColor: Colors.black45,
                        ),
                      ),
                      Text(
                        '${taskModel['time']}',
                        style: TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            IconButton(
              onPressed: () {
                if (taskModel['status'] == 'archived') {
                  return;
                } else {
                  Appcubit.get(context).updateMydatabase(
                      status: 'archived',
                      id: taskModel['id'],
                      filled: taskModel['filled']);
                }
              },
              icon: Icon(
                Icons.archive,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget taskBuilder({required List<Map> tasks}) {
  return ConditionalBuilder(
      condition: tasks.isNotEmpty,
      builder: (context) => ListView.separated(
            itemBuilder: (BuildContext context, int index) =>
                buildTaskItem(tasks[index], context),
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(
              height: 1,
              indent: 15.0,
              endIndent: 15.0,
            ),
            itemCount: tasks.length,
          ),
      fallback: (context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu,
                color: Colors.black45,
                size: 100.0,
              ),
              Text(
                'No Tasks Yet, Please Add Some Tasks',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      });
}

void showAlertDialog(
    {required BuildContext context,
    required Map taskModel,}) {
// Set up the buttons
  Widget cancelButton = MaterialButton(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    color: Colors.grey,
    onPressed: () {
      Appcubit.get(context).cancelDelete(context);
    },
    child: const Text(
      'Cancel',
      style: TextStyle(color: Colors.white),
    ),
  );
  Widget continueButton = MaterialButton(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
    ),
    color: Colors.teal,
    onPressed: () {
      Appcubit.get(context).deleteFromMydatabase(id: taskModel['id']);
      Navigator.of(context).pop();
    },
    child: const Text(
      'Yes',
      style: TextStyle(
        color: Colors.white,
      ),
    ),
  );

  // Set up the alert dialog
  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    title: const Text(
      'Delete Task',
    ),
    content: const Text(
      'Are you sure?',

    ),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  showDialog(
      barrierDismissible:false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      });
}
