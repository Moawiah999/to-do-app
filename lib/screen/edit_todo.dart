import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditTodo extends StatefulWidget {
  final String todoId;
  final Map<String, dynamic> todoData;
  const EditTodo({super.key, required this.todoId, required this.todoData});

  @override
  State<EditTodo> createState() => _EditTodoState();
}

class _EditTodoState extends State<EditTodo> {
  TextEditingController dateController = TextEditingController();
  String? importance_task;
  DateTime? selectedDate;
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

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
        dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _updateTodo() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedTodo = {
        'title': widget.todoData['title'],
        'description': widget.todoData['description'],
        'importance': importance_task ?? widget.todoData['importance'],
        'date': selectedDate != null
            ? _formatDate(selectedDate!)
            : widget.todoData['date'],
      };

      try {
        await _firestore
            .collection('todos')
            .doc(widget.todoId)
            .update(updatedTodo);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Todo updated successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating Todo")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit To Do"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: widget.todoData['title'],
                validator: (data) {
                  if (data == null || data.isEmpty) {
                    return "Required field";
                  }
                  return null;
                },
                onChanged: (data) {
                  widget.todoData['title'] = data;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter the Title',
                ),
              ),
              SizedBox(height: 40),
              TextFormField(
                initialValue: widget.todoData['description'],
                validator: (data) {
                  if (data == null || data.isEmpty) {
                    return "Required field";
                  }
                  return null;
                },
                onChanged: (data) {
                  widget.todoData['description'] = data;
                },
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
                value: importance_task ?? widget.todoData['importance'],
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateTodo,
                child: Text("Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
