import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appointment_page.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  // Simulated appointments data
  final List<Appointment> _appointments = [
    Appointment(
      type: 'Blood Donation',
      date: DateTime.now().add(const Duration(days: 2)),
      time: '10:00 AM',
      location: 'City General Hospital',
      status: AppointmentStatus.upcoming,
    ),
    Appointment(
      type: 'Plasma Donation',
      date: DateTime.now().subtract(const Duration(days: 5)),
      time: '2:30 PM',
      location: 'Medical Center',
      status: AppointmentStatus.completed,
    ),
    // Add more appointments as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC2B2B),
        title: const Text(
          'My Appointments',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildAppointmentStats(),
          Expanded(
            child: _appointments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) {
                      return _buildAppointmentCard(_appointments[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AppointmentBookingPage()),
          );
        },
        backgroundColor: const Color(0xFFCC2B2B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Book Appointment',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAppointmentStats() {
    final upcomingCount = _appointments
        .where((appointment) => appointment.status == AppointmentStatus.upcoming)
        .length;
    final completedCount = _appointments
        .where((appointment) => appointment.status == AppointmentStatus.completed)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Upcoming',
              upcomingCount.toString(),
              Icons.calendar_today,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Completed',
              completedCount.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color),
              Text(
                count,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showAppointmentDetails(appointment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appointment.type,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(appointment.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMMM d, yyyy').format(appointment.date),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    appointment.time,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    appointment.location,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(AppointmentStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case AppointmentStatus.upcoming:
        color = Colors.blue;
        text = 'Upcoming';
        icon = Icons.calendar_today;
        break;
      case AppointmentStatus.completed:
        color = Colors.green;
        text = 'Completed';
        icon = Icons.check_circle;
        break;
      case AppointmentStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        icon = Icons.cancel;
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
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No appointments yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to schedule one',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(Appointment appointment) {
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
                  'Appointment Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(appointment.status),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Type', appointment.type),
            _buildDetailRow('Date', DateFormat('MMMM d, yyyy').format(appointment.date)),
            _buildDetailRow('Time', appointment.time),
            _buildDetailRow('Location', appointment.location),
            const SizedBox(height: 24),
            if (appointment.status == AppointmentStatus.upcoming)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle rescheduling
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reschedule feature coming soon!'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFCC2B2B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reschedule',
                        style: TextStyle(color: Color(0xFFCC2B2B)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle cancellation
                        Navigator.pop(context);
                        setState(() {
                          appointment.status = AppointmentStatus.cancelled;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Appointment cancelled'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC2B2B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
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
}

enum AppointmentStatus {
  upcoming,
  completed,
  cancelled,
}

class Appointment {
  final String type;
  final DateTime date;
  final String time;
  final String location;
  AppointmentStatus status;

  Appointment({
    required this.type,
    required this.date,
    required this.time,
    required this.location,
    required this.status,
  });
}

class AppointmentBookingPage extends StatelessWidget {
  const AppointmentBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppointmentPage();
  }
} 