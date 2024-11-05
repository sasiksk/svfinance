import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:svfinance/CustomTextField.dart';
import 'package:svfinance/MainScreens/Line/Line_operations.dart';
import 'package:svfinance/operations/PartyOperations.dart';
import 'LendingFinancialDetailsScreen.dart';

class LendingBasicDetailsScreen extends StatefulWidget {
  @override
  _LendingBasicDetailsScreenState createState() =>
      _LendingBasicDetailsScreenState();
}

class _LendingBasicDetailsScreenState extends State<LendingBasicDetailsScreen> {
  final TextEditingController _lendingIdController = TextEditingController();
  final TextEditingController _dateOfLentController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  final TextEditingController _duedaysController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedLineId;
  String _lineName = '';
  String? _selectedPartyId;
  String _partyName = '';
  String? _selectedType;
  List<String> _types = ['Daily', 'Weekly'];

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
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

  Future<void> _fetchPartyName(String partyId, String lineId) async {
    final parties = await PartyOperations.getPartiesByLineId(lineId);
    final party = parties.firstWhere((party) => party['P_id'] == partyId,
        orElse: () => {});
    setState(() {
      _partyName = party['P_Name'] ?? '';
    });
  }

  void _navigateToFinancialDetails() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LendingFinancialDetailsScreen(
            lendingId: _lendingIdController.text,
            selectedLineId: _selectedLineId!,
            selectedPartyId: _selectedPartyId!,
            selectedType: _selectedType!,
            dateOfLent: _dateOfLentController.text,
            dueDays: int.parse(_duedaysController.text),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lending Basic Details'),
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
                  controller: _lendingIdController,
                  labelText: 'Lending ID',
                  hintText: 'Enter Lending ID',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Lending ID';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _selectedLineId != null
                      ? PartyOperations.getPartiesByLineId(_selectedLineId!)
                      : Future.value([]),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final parties = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: _selectedPartyId,
                      items: parties.map((party) {
                        return DropdownMenuItem<String>(
                          value: party['P_id'],
                          child: Text(party['P_id']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPartyId = value;
                        });
                        _fetchPartyName(value!, _selectedLineId!);
                      },
                      decoration: InputDecoration(
                        labelText: 'Party ID',
                        hintText: 'Select Party ID',
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
                          return 'Please select Party ID';
                        }
                        return null;
                      },
                    );
                  },
                ),
                SizedBox(height: 16.0),
                Text(
                  'Party Name: $_partyName',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: _types.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Type',
                    hintText: 'Select Type',
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
                      return 'Please select Type';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                CustomTextField(
                  controller: _dateOfLentController,
                  labelText: 'Date of Lent',
                  hintText: 'Enter Date of Lent',
                  readOnly: true,
                  onTap: () => _selectDate(context, _dateOfLentController),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Date of Lent';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                CustomTextField(
                  controller: _duedaysController,
                  labelText: 'DueDays',
                  hintText: 'Enter DueDays',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter DueDays';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _navigateToFinancialDetails,
                  child: Text('Next'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
