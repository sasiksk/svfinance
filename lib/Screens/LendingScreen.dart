import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:svfinance/CustomTextField.dart';
import 'package:svfinance/operations/Line_operations.dart';
import 'package:svfinance/operations/PartyOperations.dart';
import 'package:svfinance/operations/LendingOperations.dart';

class LendingScreen extends StatefulWidget {
  @override
  _LendingScreenState createState() => _LendingScreenState();
}

class _LendingScreenState extends State<LendingScreen> {
  final TextEditingController _lendingIdController = TextEditingController();
  final TextEditingController _amountLentController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final TextEditingController _totalAmountPayableController =
      TextEditingController();
  final TextEditingController _dateOfLentController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  final TextEditingController _duedaysController = TextEditingController();
  final TextEditingController _dateOfPaymentController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  final _formKey = GlobalKey<FormState>();

  String? _selectedLineId;
  String _lineName = '';
  String? _selectedPartyId;
  String _partyName = '';
  String? _selectedType;
  List<String> _types = ['Daily', 'Weekly'];

  void _calculateTotalAmountPayable() {
    if (_amountLentController.text.isNotEmpty &&
        _interestController.text.isNotEmpty) {
      double amountLent = double.parse(_amountLentController.text);
      double interest = double.parse(_interestController.text);
      double totalAmountPayable = amountLent + (amountLent * interest / 100);
      _totalAmountPayableController.text =
          totalAmountPayable.toStringAsFixed(2);
    }
  }

  void _calculateDueDate() {
    if (_dateOfLentController.text.isNotEmpty &&
        _duedaysController.text.isNotEmpty) {
      DateTime dateOfLent =
          DateFormat('yyyy-MM-dd').parse(_dateOfLentController.text);
      int dueLength = int.parse(_duedaysController.text);
      DateTime dueDate = dateOfLent.add(Duration(days: dueLength));
      _dateOfPaymentController.text = DateFormat('yyyy-MM-dd').format(dueDate);
    }
  }

  @override
  void initState() {
    super.initState();
    _amountLentController.addListener(_calculateTotalAmountPayable);
    _interestController.addListener(_calculateTotalAmountPayable);
    _dateOfLentController.addListener(_calculateDueDate);
    _duedaysController.addListener(_calculateDueDate);
  }

  @override
  void dispose() {
    _amountLentController.removeListener(_calculateTotalAmountPayable);
    _interestController.removeListener(_calculateTotalAmountPayable);
    _dateOfLentController.removeListener(_calculateDueDate);
    _duedaysController.removeListener(_calculateDueDate);
    _lendingIdController.dispose();
    _amountLentController.dispose();
    _interestController.dispose();
    _totalAmountPayableController.dispose();
    _dateOfLentController.dispose();
    _duedaysController.dispose();
    _dateOfPaymentController.dispose();
    super.dispose();
  }

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

  void _resetForm() {
    _formKey.currentState?.reset();
    _selectedLineId = null;
    _lineName = '';
    _selectedPartyId = null;
    _partyName = '';
    _selectedType = null;
    _lendingIdController.clear();
    _amountLentController.clear();
    _interestController.clear();
    _totalAmountPayableController.clear();
    _dateOfLentController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    _duedaysController.clear();
    _dateOfPaymentController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
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

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        double amountLent = double.parse(_amountLentController.text);
        double totalAmountPayable =
            double.parse(_totalAmountPayableController.text);

        await LendingOperations.insertLending(
          _lendingIdController.text,
          _selectedLineId!,
          _selectedPartyId!,
          _selectedType!,
          amountLent,
          totalAmountPayable,
          _dateOfLentController.text,
          int.parse(_duedaysController.text),
          _dateOfPaymentController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lending entry added successfully')),
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
          'Lending Screen',
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
                  controller: _amountLentController,
                  labelText: 'Amount Lent',
                  hintText: 'Enter Amount Lent',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Amount Lent';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                CustomTextField(
                  controller: _totalAmountPayableController,
                  labelText: 'Total Amount Payable',
                  hintText: 'Enter Total Amount Payable',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Total Amount Payable';
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
                CustomTextField(
                  controller: _dateOfPaymentController,
                  labelText: 'Date of Payment',
                  hintText: 'Enter Date of Payment',
                  readOnly: true,
                  onTap: () => _selectDate(context, _dateOfPaymentController),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Date of Payment';
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
}
