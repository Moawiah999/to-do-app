import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todolistapp/screen/auth/login.dart';
import 'package:todolistapp/screen/edit_todo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Todo extends StatefulWidget {
  const Todo({super.key});

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  String? todayDate;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return AddToDoBottomSheet();
            },
          );
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("To Do"),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Confirm Logout"),
                  content:
                      Text("Are you sure you want to exit the application?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: Text("Yes"),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('todos')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          final todos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return EditTodo(
                            todoId: todo.id,
                            todoData: todo.data() as Map<String, dynamic>,
                          );
                        },
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Checkbox(
                              value: todo['completed'],
                              onChanged: (value) {
                                FirebaseFirestore.instance
                                    .collection('todos')
                                    .doc(todo.id)
                                    .update({'completed': value});
                              },
                            ),
                            title: Text(todo['title']),
                            subtitle: Text(todo['description']),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Confirm delete"),
                                    content: Text(
                                        "Are you sure you want to delete this To Do?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('todos')
                                              .doc(todo.id)
                                              .delete();
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Yes"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              "Importance: ${todo['importance']}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomRight,
                            child: Text(todo['date']),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AddToDoBottomSheet extends StatefulWidget {
  const AddToDoBottomSheet({
    super.key,
  });

  @override
  State<AddToDoBottomSheet> createState() => _AddToDoBottomSheetState();
}

class _AddToDoBottomSheetState extends State<AddToDoBottomSheet> {
  String? importance_task;
  TextEditingController dateController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  DateTime? selectedDate;
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 30,
        left: 10,
        right: 10,
        bottom:
            MediaQuery.of(context).viewInsets.bottom, // Adjusts for keyboard
      ),
      child: SingleChildScrollView(
        // Makes the sheet scrollable when keyboard shows
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important for bottom sheets
          children: [
            TextFormField(
              validator: (data) {
                if (data == null || data.isEmpty) {
                  return "Required field";
                }
                return null;
              },
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the Title',
              ),
            ),
            const SizedBox(height: 40),
            TextFormField(
              validator: (data) {
                if (data == null || data.isEmpty) {
                  return "Required field";
                }
                return null;
              },
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the description',
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Importance',
              ),
              value: importance_task,
              items: ['High', 'Medium', 'Low']
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  importance_task = value;
                });
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: dateController,
              readOnly: true,
              onTap: () => _pickDate(context),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a date';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    importance_task == null ||
                    selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in all fields")),
                  );
                  return;
                }
                await FirebaseFirestore.instance.collection('todos').add({
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'completed': false,
                  'importance': importance_task,
                  'date': dateController.text,
                  'userId': FirebaseAuth.instance.currentUser!.uid,
                });
                Navigator.of(context).pop();
              },
              child: const Text("Create"),
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}
