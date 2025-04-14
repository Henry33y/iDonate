import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Accepted', 'Rejected', 'Pending'];

  final List<DonationHistory> _history = [
    DonationHistory(
      doctorName: "Dr. Will Tunde",
      location: "General Hospital, Barracks",
      address: "1, Abiola Way, Akure",
      date: DateTime(2021, 3, 3),
      status: DonationStatus.accepted,
      bloodType: "A+",
      amount: "450ml",
    ),
    DonationHistory(
      doctorName: "Dr. Will Tunde",
      location: "General Hospital, Barracks",
      address: "1, Abiola Way, Akure",
      date: DateTime(2021, 3, 3),
      status: DonationStatus.accepted,
      bloodType: "O+",
      amount: "500ml",
    ),
    DonationHistory(
      doctorName: "Dr. Will Tunde",
      location: "General Hospital, Barracks",
      address: "1, Abiola Way, Akure",
      date: DateTime(2021, 3, 3),
      status: DonationStatus.rejected,
      bloodType: "B+",
      amount: "0ml",
      rejectionReason: "Low hemoglobin levels",
    ),
    DonationHistory(
      doctorName: "Dr. Sarah Johnson",
      location: "City Medical Center",
      address: "15, Health Avenue",
      date: DateTime(2021, 2, 15),
      status: DonationStatus.pending,
      bloodType: "A-",
      amount: "Scheduled",
    ),
  ];

  List<DonationHistory> get filteredHistory {
    if (_selectedFilter == 'All') return _history;
    return _history.where((donation) {
      return donation.status.toString().split('.').last.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC2B2B),
        title: const Text(
          'Donation History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: Colors.white),
            onPressed: () => _showStatistics(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: _selectedFilter == filter,
                    label: Text(filter),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFFFFF3F3),
                    labelStyle: TextStyle(
                      color: _selectedFilter == filter ? const Color(0xFFCC2B2B) : Colors.black87,
                      fontWeight: _selectedFilter == filter ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),
          Expanded(
            child: filteredHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ${_selectedFilter.toLowerCase()} donations found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final donation = filteredHistory[index];
                      return _buildDonationCard(donation, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(DonationHistory donation, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        child: InkWell(
          onTap: () => _showDonationDetails(context, donation),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      donation.doctorName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusChip(donation.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        donation.location,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.map, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      donation.address,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(donation.date),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Spacer(),
                    if (donation.bloodType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC2B2B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          donation.bloodType!,
                          style: const TextStyle(
                            color: Color(0xFFCC2B2B),
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildStatusChip(DonationStatus status) {
    Color color;
    IconData icon;
    switch (status) {
      case DonationStatus.accepted:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case DonationStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case DonationStatus.pending:
        color = Colors.orange;
        icon = Icons.access_time;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status.toString().split('.').last,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDonationDetails(BuildContext context, DonationHistory donation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Donation Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(donation.status),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Doctor', donation.doctorName),
            _buildDetailRow('Location', donation.location),
            _buildDetailRow('Address', donation.address),
            _buildDetailRow('Date', _formatDate(donation.date)),
            if (donation.bloodType != null)
              _buildDetailRow('Blood Type', donation.bloodType!),
            if (donation.amount != null)
              _buildDetailRow('Amount', donation.amount!),
            if (donation.rejectionReason != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Rejection Reason:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(donation.rejectionReason!),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCC2B2B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatistics(BuildContext context) {
    final totalDonations = _history.length;
    final acceptedDonations = _history.where((d) => d.status == DonationStatus.accepted).length;
    final rejectedDonations = _history.where((d) => d.status == DonationStatus.rejected).length;
    final pendingDonations = _history.where((d) => d.status == DonationStatus.pending).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Donation Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Total Donations', totalDonations, Colors.blue),
            _buildStatRow('Accepted', acceptedDonations, Colors.green),
            _buildStatRow('Rejected', rejectedDonations, Colors.red),
            _buildStatRow('Pending', pendingDonations, Colors.orange),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum DonationStatus {
  accepted,
  rejected,
  pending,
}

class DonationHistory {
  final String doctorName;
  final String location;
  final String address;
  final DateTime date;
  final DonationStatus status;
  final String? bloodType;
  final String? amount;
  final String? rejectionReason;

  DonationHistory({
    required this.doctorName,
    required this.location,
    required this.address,
    required this.date,
    required this.status,
    this.bloodType,
    this.amount,
    this.rejectionReason,
  });
} 