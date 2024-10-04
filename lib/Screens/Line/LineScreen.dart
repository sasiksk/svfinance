import 'package:flutter/material.dart';
import 'package:svfinance/CustomTextField.dart';

import 'package:svfinance/operations/Line_operations.dart';

class LineScreen extends StatefulWidget {
  final Map<String, dynamic>? entry; // Add this line

  LineScreen({this.entry}); // Update the constructor

  @override
  _LineScreenState createState() => _LineScreenState();
}

class _LineScreenState extends State<LineScreen> {
  final TextEditingController _lineIdController = TextEditingController();
  final TextEditingController _lineNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _lineIdController.text = widget.entry!['Line_id'];
      _lineNameController.text = widget.entry!['Line_Name'];
    }
  }

  @override
  void dispose() {
    _lineIdController.dispose();
    _lineNameController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _lineIdController.clear();
    _lineNameController.clear();
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await LineOperations.insertLine(
          _lineIdController.text,
          _lineNameController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Line entry added successfully')),
        );
        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Line Screen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _lineIdController,
                labelText: 'Line ID',
                hintText: 'Enter Line ID',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Line ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              CustomTextField(
                controller: _lineNameController,
                labelText: 'Line Name',
                hintText: 'Enter Line Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Line Name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Submit'),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _resetForm,
                      child: Text('Reset'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}