// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Models
class Appointment {
  final String patientName;
  final String patientId;
  final DateTime appointmentTime;
  final String appointmentType;
  final bool isUrgent;
  final String status;

  Appointment({
    required this.patientName,
    required this.patientId,
    required this.appointmentTime,
    required this.appointmentType,
    this.isUrgent = false,
    this.status = 'Pending',
  });
}

class ClaimStatus {
  final String claimId;
  final String status;
  final double amount;
  final String payerName;
  final DateTime submissionDate;
  final List<String> errors;

  ClaimStatus({
    required this.claimId,
    required this.status,
    required this.amount,
    required this.payerName,
    required this.submissionDate,
    this.errors = const [],
  });
}

// State Management
class BillingState extends ChangeNotifier {
  List<ClaimStatus> _claims = [];
  List<Appointment> _appointments = [];
  
  List<ClaimStatus> get claims => _claims;
  List<Appointment> get appointments => _appointments;
  
  void addClaim(ClaimStatus claim) {
    _claims.add(claim);
    notifyListeners();
  }
  
  void updateClaimStatus(String claimId, String newStatus) {
    final index = _claims.indexWhere((claim) => claim.claimId == claimId);
    if (index != -1) {
      _claims[index] = ClaimStatus(
        claimId: claimId,
        status: newStatus,
        amount: _claims[index].amount,
        payerName: _claims[index].payerName,
        submissionDate: _claims[index].submissionDate,
      );
      notifyListeners();
    }
  }
}

// UI Components
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(),
          Expanded(
            child: Column(
              children: [
                AppHeader(),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: ClaimsDashboard(),
                      ),
                      Expanded(
                        flex: 3,
                        child: AppointmentsList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Color(0xFF1A365D),
      child: Row(
        children: [
          Text(
            'UpRev',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          SearchBar(),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class ClaimsDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Claims Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ClaimsTable(),
          ClaimsAnalytics(),
        ],
      ),
    );
  }
}

class ClaimsTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final claims = context.watch<BillingState>().claims;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Claim ID')),
          DataColumn(label: Text('Patient')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Payer')),
          DataColumn(label: Text('Actions')),
        ],
        rows: claims.map((claim) => DataRow(
          cells: [
            DataCell(Text(claim.claimId)),
            DataCell(Text('Patient Name')), // Would come from patient data
            DataCell(Text('\$${claim.amount.toStringAsFixed(2)}')),
            DataCell(ClaimStatusChip(status: claim.status)),
            DataCell(Text(claim.payerName)),
            DataCell(Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {},
                ),
              ],
            )),
          ],
        )).toList(),
      ),
    );
  }
}

class ClaimStatusChip extends StatelessWidget {
  final String status;
  
  const ClaimStatusChip({required this.status});
  
  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;
    
    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange;
        break;
      case 'approved':
        backgroundColor = Colors.green;
        break;
      case 'denied':
        backgroundColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.grey;
    }
    
    return Chip(
      label: Text(
        status,
        style: TextStyle(color: textColor),
      ),
      backgroundColor: backgroundColor,
    );
  }
}

class ClaimsAnalytics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          AnalyticCard(
            title: 'Total Claims',
            value: '152',
            trend: '+12%',
            isPositive: true,
          ),
          AnalyticCard(
            title: 'Pending Claims',
            value: '45',
            trend: '-5%',
            isPositive: true,
          ),
          AnalyticCard(
            title: 'Denial Rate',
            value: '8.5%',
            trend: '-2.3%',
            isPositive: true,
          ),
          AnalyticCard(
            title: 'Average Processing Time',
            value: '3.2 days',
            trend: '-0.5 days',
            isPositive: true,
          ),
        ],
      ),
    );
  }
}

class AnalyticCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool isPositive;

  const AnalyticCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 16,
                ),
                Text(
                  trend,
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
