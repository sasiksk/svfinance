import 'package:flutter/material.dart';
import 'package:svfinance/Screens/Line/LineScreen.dart';
import 'package:svfinance/MainScreens/Line/Line_operations.dart'; // Ensure this import is correct

class LineScreenHome extends StatefulWidget {
  @override
  _LineScreenHomeState createState() => _LineScreenHomeState();
}

class _LineScreenHomeState extends State<LineScreenHome> {
  Future<List<Map<String, dynamic>>>? lineEntries;
  Future<Map<String, dynamic>>? totalAmounts;

  @override
  void initState() {
    super.initState();
    loadLineEntries();
    loadTotalAmounts();
  }

  void loadLineEntries() {
    setState(() {
      lineEntries = LineOperations.getAllLines();
    });
  }

  void loadTotalAmounts() {
    setState(() {
      totalAmounts = LineOperations.getTotalAmounts();
    });
  }

  void _navigateToAddScreen() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => LineScreen(),
      ),
    )
        .then((_) {
      loadLineEntries(); // Refresh the list after adding new entry
      loadTotalAmounts(); // Refresh the total amounts after adding new entry
    });
  }

  void _navigateToUpdateScreen(Map<String, dynamic> entry) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => LineScreen(entry: entry), // Update this line
      ),
    )
        .then((_) {
      loadLineEntries(); // Refresh the list after updating entry
      loadTotalAmounts(); // Refresh the total amounts after updating entry
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final cardHeight = mediaQuery.size.height * 0.15;
    final cardWidth = mediaQuery.size.width * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: Text('Line Screen'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: totalAmounts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No data available'));
                } else {
                  final totalData = snapshot.data!;
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: cardHeight,
                      width: cardWidth,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Line Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Total Lines:',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${totalData['totalLines']}',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: lineEntries,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No entries available'));
                  } else {
                    final data = snapshot.data!;
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final entry = data[index];
                        return Card(
                          child: ListTile(
                            title: Text('Line ID: ${entry['Line_id']}'),
                            subtitle: Text('Line Name: ${entry['Line_Name']}'),
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _navigateToUpdateScreen(entry),
                            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddScreen,
        child: Icon(Icons.add),
      ),
    );
  }
}
