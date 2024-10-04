import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:svfinance/CustomTextField.dart';
import 'package:svfinance/operations/CaptialOperations.dart';

class CapitalScreen extends StatefulWidget {
  final Map<String, dynamic>? entry; // Optional for edit functionality

  CapitalScreen({this.entry});

  @override
  _CapitalScreenState createState() => _CapitalScreenState();
}

class _CapitalScreenState extends State<CapitalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _capitalIdController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountInvestedController =
      TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set default or existing values if editing an entry
    if (widget.entry != null) {
      _capitalIdController.text = widget.entry!['Capital_id'];
      _dateController.text = widget.entry!['Date_of_Particulars'];
      _amountInvestedController.text = widget.entry!['Amt_Inv'].toString();
      _noteController.text = widget.entry!['Note'];
    } else {
      _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    }
  }

  @override
  void dispose() {
    _capitalIdController.dispose();
    _dateController.dispose();
    _amountInvestedController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final capitalId = _capitalIdController.text.isEmpty
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : _capitalIdController.text;

      final success = widget.entry == null
          ? await CapitalOperations.insertCapital(
              capitalId: capitalId,
              dateOfParticulars: _dateController.text,
              amountInvested: double.parse(_amountInvestedController.text),
              note: _noteController.text,
            )
          : await CapitalOperations.updateCapital(
              capitalId: capitalId,
              dateOfParticulars: _dateController.text,
              amountInvested: double.parse(_amountInvestedController.text),
              note: _noteController.text,
            );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.entry == null
                  ? 'Capital entry added successfully'
                  : 'Capital entry updated successfully')),
        );
        Navigator.pop(context); // Close the screen after successful submission
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Unique key violated: Capital ID already exists.')),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _capitalIdController.clear();
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _amountInvestedController.clear();
    _noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'Add Capital' : 'Update Capital'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _capitalIdController,
                  labelText: 'Capital ID',
                  readOnly: widget.entry != null, // Read-only in edit mode
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Capital ID';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                CustomTextField(
                  controller: _dateController,
                  labelText: 'Date of Particulars',
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Date of Particulars';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                CustomTextField(
                  controller: _amountInvestedController,
                  labelText: 'Amount Invested',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Amount Invested';
                    }
                    final number = num.tryParse(value);
                    if (number == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                CustomTextField(
                  controller: _noteController,
                  labelText: 'Particulars',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Particulars';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Submit'),
                    ),
                    ElevatedButton(
                      onPressed: _resetForm,
                      child: Text('Reset'),
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
      ),
    );
  }
}
