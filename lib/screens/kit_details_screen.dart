import 'package:flutter/material.dart';
// import 'kit_details_screen.dart';

class MyFundedKitsScreen extends StatelessWidget {
  final Map<String, dynamic>? newKit;

  const MyFundedKitsScreen({super.key, this.newKit});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> fundedKits = [
      if (newKit != null) newKit!,
      {
        "name": "Solar Kit - Village A",
        "amount": 300,
        "status": "Active",
        "date": "25 Feb 2026",
        "location": "Kampala",
        "battery": 78,
        "energy": 15,
        "systemStatus": "Running",
        "totalCost": 600,
      },
      {
        "name": "Solar Kit - School B",
        "amount": 100,
        "status": "Pending",
        "date": "24 Feb 2026",
        "location": "Entebbe",
        "battery": 0,
        "energy": 0,
        "systemStatus": "Not Installed",
        "totalCost": 600,
      },
    ];

    double totalFunded =
        fundedKits.fold(0, (sum, item) => sum + (item["amount"] ?? 0));

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("My Kits"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// SUMMARY CARD
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Funded", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 5),
                    Text("\$$totalFunded",
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Kits", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 5),
                    Text(fundedKits.length.toString(),
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),

          /// LIST OF KITS
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: fundedKits.length,
              itemBuilder: (context, index) {
                final kit = fundedKits[index];

                Color statusColor;
                Color statusBg;

                switch (kit["status"]) {
                  case "Active":
                    statusColor = Colors.green;
                    statusBg = Colors.green.shade100;
                    break;
                  case "Pending":
                    statusColor = Colors.orange;
                    statusBg = Colors.orange.shade100;
                    break;
                  default:
                    statusColor = Colors.grey;
                    statusBg = Colors.grey.shade200;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.05 * 255).toInt()),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(kit["name"],
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Location: ${kit["location"]}"),
                      const SizedBox(height: 6),
                      Text("Amount Funded: \$${kit["amount"]}"),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(kit["status"],
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
                          ),
                          const Spacer(),
                          Text(kit["date"], style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Replace with actual KitDetailsScreen when ready
                            // Navigator.push(context, MaterialPageRoute(builder: (_) => KitDetailsScreen(kit: kit)));
                          },
                          child: const Text("View Details"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}