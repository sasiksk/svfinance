import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:svfinance/operations/CollectionOperations.dart';
import 'package:svfinance/operations/LendingOperations.dart';
import 'package:svfinance/operations/Line_operations.dart';
import 'package:svfinance/operations/PartyOperations.dart';

class CollectionScreen2 extends StatefulWidget {
  @override
  _CollectionScreen2State createState() => _CollectionScreen2State();
}

class _CollectionScreen2State extends State<CollectionScreen2> {
  final TextEditingController _collectionIdController = TextEditingController();
  final TextEditingController _dateOfPaymentController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  final _formKey = GlobalKey<FormState>();

  String? _selectedLineId;
  String _lineName = '';
  List<Map<String, dynamic>> _parties = [];

  @override
  void dispose() {
    _collectionIdController.dispose();
    _dateOfPaymentController.dispose();
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
        _dateOfPaymentController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _fetchLineName(String lineId) async {
    final lines = await LineOperations.getAllLines();
    final line =
        lines.firstWhere((line) => line['Line_id'] == lineId, orElse: () => {});
    setState(() {
      _lineName = line['Line_Name'] ?? '';
    });
  }

  Future<void> _fetchParties(String lineId) async {
    final lendings = await LendingOperations.getAllLendings();
    final parties =
        lendings.where((lending) => lending['Line_id'] == lineId).toList();
    for (var party in parties) {
      final partyDetails =
          await PartyOperations.getPartyById(party['P_id'], lineId);
      party['P_Name'] = partyDetails['P_Name'];
    }
    setState(() {
      _parties = parties;
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _collectionIdController.clear();
    _selectedLineId = null;
    _lineName = '';
    _dateOfPaymentController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    _parties.clear();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        for (var party in _parties) {
          await CollectionOperations.insertCollection(
            _collectionIdController.text,
            party['Len_id'],
            _dateOfPaymentController.text,
            double.parse(party['Amt_Collected']),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Collection entries added successfully')),
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
          'Collection Screen 2',
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
                TextFormField(
                  controller: _collectionIdController,
                  decoration: InputDecoration(
                    labelText: 'Collection ID',
                    hintText: 'Enter Collection ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Collection ID';
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
                          _fetchLineName(value!);
                          _fetchParties(value);
                        });
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
                TextFormField(
                  controller: _dateOfPaymentController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date of Payment',
                    hintText: 'Enter Date of Payment',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Date of Payment';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                _parties.isEmpty
                    ? Text('No parties found for the selected line.')
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Collection ID')),
                            DataColumn(label: Text('Party ID')),
                            DataColumn(label: Text('Party Name')),
                            DataColumn(label: Text('Amount Collected')),
                          ],
                          rows: _parties.map((party) {
                            return DataRow(cells: [
                              DataCell(Text(_collectionIdController.text)),
                              DataCell(Text(party['P_id'] ?? '')),
                              DataCell(Text(party['P_Name'] ?? '')),
                              DataCell(
                                TextFormField(
                                  initialValue:
                                      party['Amt_Collected']?.toString() ?? '',
                                  decoration: InputDecoration(
                                    hintText: 'Enter Amount Collected',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    party['Amt_Collected'] = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Amount Collected';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
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
