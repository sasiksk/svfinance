import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:svfinance/CustomTextField.dart';
import 'package:svfinance/operations/Investmentoperations.dart';
import 'package:svfinance/operations/Line_operations.dart';

class InvestmentScreen extends StatefulWidget {
  @override
  _InvestmentScreenState createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  final TextEditingController _investmentIdController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  final TextEditingController _amountInvestedController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedLineId;
  String _lineName = '';

  @override
  void dispose() {
    _investmentIdController.dispose();
    _dateController.dispose();
    _amountInvestedController.dispose();
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
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _investmentIdController.clear();
    _selectedLineId = null;
    _lineName = '';
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _amountInvestedController.clear();
  }

  Future<void> _fetchLineName(String lineId) async {
    final lines = await LineOperations.getAllLines();
    final line =
        lines.firstWhere((line) => line['Line_id'] == lineId, orElse: () => {});
    setState(() {
      _lineName = line['Line_Name'] ?? '';
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await InvestmentOperations.insertInvestment(
          _investmentIdController.text,
          _selectedLineId!,
          _dateController.text,
          double.parse(_amountInvestedController.text),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Investment entry added successfully')),
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
          'Investment Screen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _investmentIdController,
                  labelText: 'Investment ID',
                  hintText: 'Enter Investment ID',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Investment ID';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: LineOperations.getAllLines(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final lines = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: _selectedLineId,
                      items: lines.map((line) {
                        return DropdownMenuItem<String>(
                          value: line['Line_id'],
                          child: Text(line['Line_id']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLineId = value;
                        });
                        _fetchLineName(value!);
                      },
                      decoration: InputDecoration(
                        labelText: 'Line ID',
                        hintText: 'Select Line ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select Line ID';
                        }
                        return null;
                      },
                    );
                  },
                ),
                SizedBox(height: 16.0),
                Text(
                  'Line Name: $_lineName',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 16.0),
                CustomTextField(
                  controller: _dateController,
                  labelText: 'Date of Investment',
                  hintText: 'Enter Date of Investment',
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Date of Investment';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                CustomTextField(
                  controller: _amountInvestedController,
                  labelText: 'Amount Invested',
                  hintText: 'Enter Amount Invested',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Amount Invested';
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
      ),
    );
  }
}
