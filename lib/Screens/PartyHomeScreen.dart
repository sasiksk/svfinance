import 'package:flutter/material.dart';
import 'PartyScreen.dart';
import 'DatabaseHelper.dart';
import 'package:sqflite/sqflite.dart';

class PartyHomeScreen extends StatefulWidget {
  @override
  _PartyHomeScreenState createState() => _PartyHomeScreenState();
}

class _PartyHomeScreenState extends State<PartyHomeScreen> {
  late Future<Map<String, List<Map<String, dynamic>>>> _groupedPartyEntries;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _groupedPartyEntries = _getGroupedPartyEntries();
  }

  Future<Map<String, List<Map<String, dynamic>>>>
      _getGroupedPartyEntries() async {
    final db = await DatabaseHelper.getDatabase();
    final result = await db.rawQuery('''
      SELECT 
        party.Line_id, 
        Line.Line_Name,
        party.P_Name, 
        party.P_phone,
        party.P_Address,
        party.P_id
      FROM party
      JOIN Line ON party.Line_id = Line.Line_id
    ''');

    final Map<String, List<Map<String, dynamic>>> groupedEntries = {};

    for (var entry in result) {
      final String lineId = entry['Line_id'].toString();
      if (!groupedEntries.containsKey(lineId)) {
        groupedEntries[lineId] = [];
      }
      groupedEntries[lineId]!.add(Map<String, dynamic>.from(entry));
    }

    return groupedEntries;
  }

  void _editParty(Map<String, dynamic> party) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PartyScreen(
          partyId: party['P_id'],
          lineId: party['Line_id'],
          partyName: party['P_Name'],
          partyPhoneNumber: party['P_phone'],
          address: party['P_Address'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Party Home Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                future: _groupedPartyEntries,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No entries available');
                  } else {
                    final groupedEntries = snapshot.data!;
                    return ListView.builder(
                      itemCount: groupedEntries.keys.length,
                      itemBuilder: (context, index) {
                        final lineId = groupedEntries.keys.elementAt(index);
                        final parties = groupedEntries[lineId]!;
                        final lineName = parties.first['Line_Name'];

                        return Card(
                          child: ExpansionTile(
                            title: Text('Line Name: $lineName (ID: $lineId)'),
                            children: [
                              ...parties.map((party) {
                                return ListTile(
                                  title: Text('Party Name: ${party['P_Name']}'),
                                  subtitle:
                                      Text('Party Phone: ${party['P_phone']}'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => _editParty(party),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PartyScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
