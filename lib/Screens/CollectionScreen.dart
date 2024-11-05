import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:svfinance/CustomTextField.dart';
import 'package:svfinance/operations/CollectionOperations.dart';
import 'package:svfinance/operations/LendingOperations.dart';

class CollectionScreen extends StatefulWidget {
  @override
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final TextEditingController _collectionIdController = TextEditingController();
  final TextEditingController _dateOfPaymentController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  final TextEditingController _amountCollectedController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedLendingId;

  @override
  void dispose() {
    _collectionIdController.dispose();
    _dateOfPaymentController.dispose();
    _amountCollectedController.dispose();
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
    _collectionIdController.clear();
    _selectedLendingId = null;
    _dateOfPaymentController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    _amountCollectedController.clear();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await CollectionOperations.insertCollection(
          _collectionIdController.text,
          _selectedLendingId!,
          _dateOfPaymentController.text,
          double.parse(_amountCollectedController.text),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Collection entry added successfully')),
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
          'Collection Screen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigoAccent.shade400,
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
                  controller: _collectionIdController,
                  labelText: 'Collection ID',
                  hintText: 'Enter Collection ID',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Collection ID';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: LendingOperations.getAllLendings(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final lendings = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: _selectedLendingId,
                      items: lendings.map((lending) {
                        return DropdownMenuItem<String>(
                          value: lending['Len_id'],
                          child: Text(lending['Len_id']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLendingId = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Lending ID',
                        hintText: 'Select Lending ID',
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
                          return 'Please select Lending ID';
                        }
                        return null;
                      },
                    );
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
                CustomTextField(
                  controller: _amountCollectedController,
                  labelText: 'Amount Collected',
                  hintText: 'Enter Amount Collected',
                  keyboardType:
                      TextInputType.number, // Set keyboard type to numeric
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Amount Collected';
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
