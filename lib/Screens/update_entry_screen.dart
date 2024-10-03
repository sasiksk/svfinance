import 'package:flutter/material.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';

class UpdateEntryScreen extends StatefulWidget {
  final String tableName;
  final Map<String, dynamic>? entry;

  UpdateEntryScreen({required this.tableName, this.entry});

  @override
  _UpdateEntryScreenState createState() => _UpdateEntryScreenState();
}

class _UpdateEntryScreenState extends State<UpdateEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    widget.entry?.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value.toString());
    });
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState?.validate() ?? false) {
      final entryData =
          _controllers.map((key, controller) => MapEntry(key, controller.text));
      if (widget.entry != null) {
        await DatabaseHelper.updateEntry(
            widget.tableName, entryData, widget.entry!['id']);
      } else {
        await DatabaseHelper.insertEntry(widget.tableName, entryData);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry != null ? 'Update Entry' : 'Add Entry'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ..._controllers.keys.map((key) {
                return TextFormField(
                  controller: _controllers[key],
                  decoration: InputDecoration(labelText: key),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter $key';
                    }
                    return null;
                  },
                );
              }).toList(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEntry,
                child: Text(widget.entry != null ? 'Update' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
