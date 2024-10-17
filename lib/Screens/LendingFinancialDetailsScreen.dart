import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:svfinance/CustomTextField.dart';
import 'package:svfinance/operations/LendingOperations.dart';

class LendingFinancialDetailsScreen extends StatefulWidget {
  final String lendingId;
  final String selectedLineId;
  final String selectedPartyId;
  final String selectedType;
  final String dateOfLent;
  final int dueDays;

  LendingFinancialDetailsScreen({
    required this.lendingId,
    required this.selectedLineId,
    required this.selectedPartyId,
    required this.selectedType,
    required this.dateOfLent,
    required this.dueDays,
  });

  @override
  _LendingFinancialDetailsScreenState createState() =>
      _LendingFinancialDetailsScreenState();
}

class _LendingFinancialDetailsScreenState
    extends State<LendingFinancialDetailsScreen> {
  final TextEditingController _amountLentController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final TextEditingController _totalAmountPayableController =
      TextEditingController();
  final TextEditingController _dateOfPaymentController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountLentController.addListener(_calculateTotalAmountPayable);
    _interestController.addListener(_calculateTotalAmountPayable);
    _dateOfPaymentController.text = _calculateDueDate();
  }

  @override
  void dispose() {
    _amountLentController.removeListener(_calculateTotalAmountPayable);
    _interestController.removeListener(_calculateTotalAmountPayable);
    _amountLentController.dispose();
    _interestController.dispose();
    _totalAmountPayableController.dispose();
    _dateOfPaymentController.dispose();
    super.dispose();
  }

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

  String _calculateDueDate() {
    DateTime dateOfLent = DateTime.parse(widget.dateOfLent);
    DateTime dueDate = dateOfLent.add(Duration(days: widget.dueDays));
    return DateFormat('yyyy-MM-dd').format(dueDate);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        double amountLent = double.parse(_amountLentController.text);
        double totalAmountPayable =
            double.parse(_totalAmountPayableController.text);

        await LendingOperations.insertLending(
          widget.lendingId,
          widget.selectedLineId,
          widget.selectedPartyId,
          widget.selectedType,
          amountLent,
          totalAmountPayable,
          widget.dateOfLent,
          widget.dueDays,
          _dateOfPaymentController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lending entry added successfully')),
        );
        Navigator.pop(context);
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
        title: Text('Lending Financial Details'),
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
                  controller: _interestController,
                  labelText: 'Interest',
                  hintText: 'Enter Interest',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Interest';
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
                  controller: _dateOfPaymentController,
                  labelText: 'Date of Payment',
                  hintText: 'Enter Date of Payment',
                  readOnly: true,
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Back'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
