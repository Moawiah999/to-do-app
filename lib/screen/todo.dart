import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todolistapp/screen/auth/login.dart';

class Todo extends StatelessWidget {
  const Todo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
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
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
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
                      title: Text("flutter title"),
                      subtitle: Text("Create your own app"),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.delete),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Importance: High",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: Text("May21 2021"),
                    ),
                  ],
                ),
              ),
            ),
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
      padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
      child: Column(
        children: [
          TextFormField(
            validator: (data) {
              if (data == null || data.isEmpty) {
                return "Required field";
              }
            },
            controller: titleController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter the Title',
            ),
          ),
          SizedBox(height: 40),
          TextFormField(
            validator: (data) {
              if (data == null || data.isEmpty) {
                return "Required field";
              }
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
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  importance_task == null ||
                  selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please fill in all fields")),
                );
              }
              FirebaseFirestore.instance.collection('todos').add({
                'title': titleController.text,
                'description': descriptionController.text,
                'importance': importance_task,
                'date': dateController.text,
                'completed': false,
              });
              Navigator.of(context).pop();
            },
            child: Text("Create"),
          ),
        ],
      ),
    );
  }
}
