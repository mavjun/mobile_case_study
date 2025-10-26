import 'package:flutter/material.dart';

class AllRequestsScreen extends StatelessWidget {
  const AllRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Requests'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0, // subtle shadow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Requests',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildRequestCard('Barangay Clearance', 'Pending'),
                  _buildRequestCard('Business Clearance', 'Processing'),
                  _buildRequestCard('Certificate', 'Approved'),
                  _buildRequestCard('Other Request', 'Pending'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(String title, String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'processing':
        statusColor = Colors.blue;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        break;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          status,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
