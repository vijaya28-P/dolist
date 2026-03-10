import 'package:dolist/views/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/task_provider.dart';
import '../models/task.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);
  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {

  TextEditingController taskController = TextEditingController();

  void addTaskDialog([Task? task]) {
    if (task != null) {
      taskController.text = task.title;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:Text(task == null ? "Add Task" : "Edit Task"),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(
              hintText: "Enter task",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                taskController.clear();
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
              ),
              onPressed: () {
                if (taskController.text.isNotEmpty) {

        if (task == null) {
        context.read<TaskProvider>()
            .addTask(taskController.text);
        } else {

        context.read<TaskProvider>()
            .updateTask(task.id, taskController.text);
        }

        taskController.clear();
        Navigator.pop(context);
        }

              },
              child: Text(
                task == null ? "Add" : "Update",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text("My Tasks",style: TextStyle(color: Colors.white),),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,

        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            DrawerHeader(

              decoration: const BoxDecoration(
                color: Colors.deepPurpleAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 50),
                  const SizedBox(height: 10),
                   Text(
                    "Welcome" ,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? "User",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                )
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.task),
              title: const Text("Tasks"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async{

                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) =>  LoginPage()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      // body: Consumer<TaskProvider>(
      //   builder: (context, provider, child) {
      //
      //     if (provider.tasks.isEmpty) {
      //       return const Center(
      //         child: Text("No Tasks Available"),
      //       );
      //     }
      //
      //     return ListView.builder(
      //       itemCount: provider.tasks.length,
      //       itemBuilder: (context, index) {
      //
      //         Task task = provider.tasks[index];
      //
      //         return Card(
      //           color: task.isCompleted ? Colors.deepPurple[100] : Colors.white,
      //           margin: const EdgeInsets.symmetric(
      //               horizontal: 10, vertical: 5),
      //           child: ListTile(
      //
      //             title: Text(
      //               task.title,
      //             ),
      //
      //             leading: Checkbox(
      //               value: task.isCompleted,
      //               onChanged: (value) {
      //                 provider.toggleTask(task.id);
      //               },
      //             ),
      //
      //             trailing:
      //                 Wrap(
      //                   children: [
      //                     IconButton(
      //                       icon: const Icon(Icons.edit),
      //                       onPressed: () {
      //                         addTaskDialog(task);
      //                       },
      //                     ),
      //                     SizedBox(width: 2,),
      //                     IconButton(
      //                       icon: const Icon(Icons.delete),
      //                       onPressed: () {
      //                         provider.deleteTask(task.id);
      //                       },
      //                     ),
      //                   ],
      //                 ),
      //             // IconButton(
      //             //   icon: const Icon(Icons.delete),
      //             //   onPressed: () {
      //             //     provider.deleteTask(task.id);
      //             //   },
      //             // ),
      //           ),
      //         );
      //       },
      //     );
      //
      //   },
      // ),
      body: StreamBuilder<List<Task>>(
        stream: context.read<TaskProvider>().getTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Tasks Available"));
          }

          final tasks = snapshot.data!;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                color: task.isCompleted ? Colors.deepPurple[100] : Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(task.title),
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      context.read<TaskProvider>().toggleTask(task.id);
                    },
                  ),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => addTaskDialog(task),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          context.read<TaskProvider>().deleteTask(task.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),



      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: addTaskDialog,
        child: const Icon(Icons.add,color: Colors.white,)
      ),
    );
  }
}