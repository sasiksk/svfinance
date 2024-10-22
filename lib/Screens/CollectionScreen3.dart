import 'package:flutter/material.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';
// Adjust the import according to your project structure

class CollectionHomeScreen extends StatefulWidget {
  @override
  _CollectionHomeScreenState createState() => _CollectionHomeScreenState();
}

class _CollectionHomeScreenState extends State<CollectionHomeScreen> {
  String? _selectedLineId;
  List<Map<String, dynamic>> _lines = [];
  Future<List<Map<String, dynamic>>>? _partiesFuture;

  @override
  void initState() {
    super.initState();
    _fetchLineIdsAndNames();
  }

  Future<void> _fetchLineIdsAndNames() async {
    final lines = await DatabaseHelper.getLineIdsAndNames();
    setState(() {
      _lines = lines;
    });
  }

  void _onLineSelected(String? lineId) {
    setState(() {
      _selectedLineId = lineId;
      if (lineId != null) {
        _partiesFuture = DatabaseHelper.getPartiesByLine(lineId);
      } else {
        _partiesFuture = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collection Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              hint: Text('Select Line'),
              value: _selectedLineId,
              onChanged: _onLineSelected,
              items: _lines.map((line) {
                return DropdownMenuItem<String>(
                  value: line['Line_id'],
                  child: Text(line['Line_Name']),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            _selectedLineId == null
                ? Container()
                : Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _partiesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('No parties found'));
                        } else {
                          final parties = snapshot.data!;
                          return ListView.builder(
                            itemCount: parties.length,
                            itemBuilder: (context, index) {
                              final party = parties[index];
                              return Card(
                                child: ListTile(
                                  title: Text(party['P_Name']),
                                  subtitle: Text(party['P_Address']),
                                  trailing: Text(party['P_phone']),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
