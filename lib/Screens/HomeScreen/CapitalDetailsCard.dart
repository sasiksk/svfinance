import 'package:flutter/material.dart';
import 'package:svfinance/operations/CaptialOperations.dart';

class CapitalDetailsCard extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;

  CapitalDetailsCard({required this.screenHeight, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      height: screenHeight * 0.2, // Slightly increased height to avoid overflow
      width: screenWidth - 40, // Full width minus padding (20 on each side)
      child: Card(
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                Colors.blueGrey.shade700,
                Colors.black87
              ], // Gradient background
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Increased padding
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align content to start
              children: <Widget>[
                Text(
                  'Capital Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // White text color
                  ),
                ),
                SizedBox(height: 15), // Increased spacing for better layout
                FutureBuilder<Map<String, dynamic>>(
                  future: CapitalOperations.getCapitalTotals(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.redAccent),
                      );
                    } else if (snapshot.hasData) {
                      final data = snapshot.data!;
                      final totalAmtInvested = data['cTotal_Amt_Inv'];
                      final amtRemaining = data['cTotal_Amt_Rem'];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Invested:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                '\$${totalAmtInvested.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Remaining:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                '\$${amtRemaining.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return Text(
                        'No data available',
                        style: TextStyle(color: Colors.white70),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
