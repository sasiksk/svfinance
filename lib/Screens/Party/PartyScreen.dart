import 'package:flutter/material.dart';
import 'package:svfinance/CustomTextField.dart';

import '../DatabaseHelper.dart';
import 'package:sqflite/sqflite.dart';

class PartyScreen extends StatefulWidget {
  final String? partyId;
  final String? lineId;
  final String? partyName;
  final String? partyPhoneNumber;
  final String? address;

  PartyScreen({
    this.partyId,
    this.lineId,
    this.partyName,
    this.partyPhoneNumber,
    this.address,
  });

  @override
  _PartyScreenState createState() => _PartyScreenState();
}

class _PartyScreenState extends State<PartyScreen> {
  final TextEditingController _partyIdController = TextEditingController();
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _partyPhoneNumberController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedLineId;
  String _lineName = '';

  @override
  void initState() {
    super.initState();
    if (widget.partyId != null) {
      _partyIdController.text = widget.partyId!;
      _selectedLineId = widget.lineId;
      _partyNameController.text = widget.partyName!;
      _partyPhoneNumberController.text = widget.partyPhoneNumber!;
      _addressController.text = widget.address!;
      _fetchLineName(widget.lineId!);
    }
  }

  @override
  void dispose() {
    _partyIdController.dispose();
    _partyNameController.dispose();
    _partyPhoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _selectedLineId = null;
    _lineName = '';
    _partyIdController.clear();
    _partyNameController.clear();
    _partyPhoneNumberController.clear();
    _addressController.clear();
  }

  Future<void> _fetchLineName(String lineId) async {
    final db = await DatabaseHelper.getDatabase();
    final lines =
        await db.query('Line', where: 'Line_id = ?', whereArgs: [lineId]);
    final line = lines.isNotEmpty ? lines.first : {};
    setState(() {
      _lineName = line['Line_Name'] ?? '';
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final db = await DatabaseHelper.getDatabase();
      try {
        await db.insert(
          'party',
          {
            'P_id': _partyIdController.text,
            'Line_id': _selectedLineId!,
            'P_Name': _partyNameController.text,
            'P_phone': _partyPhoneNumberController.text,
            'P_Address': _addressController.text,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Party entry added successfully')),
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
          'Party Screen',
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
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchAllLines(),
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
                  controller: _partyIdController,
                  labelText: 'Party ID',
                  hintText: 'Enter Party ID',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Party ID';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                CustomTextField(
                  controller: _partyNameController,
                  labelText: 'Party Name',
                  hintText: 'Enter Party Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Party Name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                CustomTextField(
                  controller: _partyPhoneNumberController,
                  labelText: 'Party Phone Number',
                  hintText: 'Enter Party Phone Number',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Party Phone Number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                CustomTextField(
                  controller: _addressController,
                  labelText: 'Address',
                  hintText: 'Enter Address',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _submitForm();
                          }
                        },
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

  Future<List<Map<String, dynamic>>> _fetchAllLines() async {
    final db = await DatabaseHelper.getDatabase();
    return await db.query('Line');
  }
}
