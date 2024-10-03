import 'package:flutter/material.dart';
import 'package:svfinance/Screens/update_entry_screen.dart';

class EntryCard extends StatefulWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onUpdate;

  EntryCard({required this.entry, required this.onUpdate});

  @override
  _EntryCardState createState() => _EntryCardState();
}

class _EntryCardState extends State<EntryCard> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 150),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _isChecked ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          height: 140,
          child: Card(
            color: Colors.amberAccent.shade100,
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _isChecked,
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value!;
                            _showUpdateStatusDialog();
                          });
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.entry['title'] ?? 'No Title',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: _isChecked
                                        ? const TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.red,
                                            fontSize: 16)
                                        : const TextStyle(
                                            fontSize: 16,
                                            color:
                                                Color.fromARGB(255, 2, 1, 41),
                                            fontWeight: FontWeight.w100),
                                  ),
                                ),
                                Text(
                                  'Due: ${widget.entry['dueDate'] ?? 'No due date'}',
                                  overflow: TextOverflow.ellipsis,
                                  style: _isChecked
                                      ? const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.red,
                                        )
                                      : const TextStyle(
                                          color: Color.fromARGB(255, 2, 1, 41)),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (context) => UpdateEntryScreen(
                                          tableName: 'YourTableName',
                                          entry: widget.entry,
                                        ),
                                      ),
                                    )
                                        .then((_) {
                                      widget.onUpdate();
                                    });
                                  },
                                  icon:
                                      const Icon(Icons.drag_indicator_rounded),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Displaying the column names and values
                  Text(
                    'Column 1: ${widget.entry['column1'] ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.black,
                      decoration: _isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Column 2: ${widget.entry['column2'] ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.black,
                      decoration: _isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Column 3: ${widget.entry['column3'] ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.black,
                      decoration: _isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Status: ${widget.entry['status'] ?? 'Unknown'}',
                        style: TextStyle(
                          color: widget.entry['status'] == 'Completed'
                              ? Colors.green
                              : Colors.black,
                          decoration: _isChecked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUpdateStatusDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(_isChecked ? 'Mark as Not Completed' : 'Mark as Completed'),
          content: const Text('Do you want to update the status?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await _updateStatus();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isChecked = !_isChecked; // Toggle the checkbox back
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateStatus() async {
    // Implement your update status logic here
    widget.onUpdate(); // Call the callback after updating status
  }
}
