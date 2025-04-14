import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTimeSlot;
  String? _selectedDonationType;
  final TextEditingController _notesController = TextEditingController();

  // Simulated available time slots
  final List<String> _timeSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '02:00 PM', '02:30 PM',
    '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
  ];

  final List<String> _donationTypes = [
    'Whole Blood Donation',
    'Plasma Donation',
    'Platelet Donation',
    'Double Red Cell Donation'
  ];

  // Simulated unavailable dates (holidays, weekends, etc.)
  final Set<DateTime> _unavailableDates = {
    DateTime.now().add(const Duration(days: 2)),
    DateTime.now().add(const Duration(days: 5)),
    DateTime.now().add(const Duration(days: 7)),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _isDateUnavailable(DateTime day) {
    return _unavailableDates.contains(day) || 
           day.weekday == DateTime.sunday || 
           day.isBefore(DateTime.now().subtract(const Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC2B2B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Schedule Appointment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepsIndicator(),
              _buildCalendarSection(),
              _buildTimeSlots(),
              _buildDonationTypeSection(),
              _buildNotesSection(),
              const SizedBox(height: 20),
              _buildScheduleButton(),
              const SizedBox(height: 20),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepsIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book Your Appointment',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStepCircle(1, true, 'Date'),
              _buildStepLine(true),
              _buildStepCircle(2, _selectedDay != null, 'Time'),
              _buildStepLine(_selectedDay != null),
              _buildStepCircle(3, _selectedDay != null && _selectedTimeSlot != null, 'Confirm'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, bool isActive, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFFCC2B2B) : Colors.grey[300],
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFCC2B2B) : Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? const Color(0xFFCC2B2B) : Colors.grey[300],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 90)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            if (!_isDateUnavailable(selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedTimeSlot = null; // Reset time slot when date changes
              });
            }
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            selectedDecoration: const BoxDecoration(
              color: Color(0xFFCC2B2B),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: const Color(0xFFCC2B2B).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: Color(0xFFCC2B2B),
              shape: BoxShape.circle,
            ),
            disabledTextStyle: const TextStyle(color: Colors.grey),
            weekendTextStyle: const TextStyle(color: Colors.red),
          ),
          enabledDayPredicate: (day) => !_isDateUnavailable(day),
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    if (_selectedDay == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Time Slots',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _timeSlots.length,
            itemBuilder: (context, index) {
              final timeSlot = _timeSlots[index];
              final isSelected = timeSlot == _selectedTimeSlot;

              return InkWell(
                onTap: () => setState(() => _selectedTimeSlot = timeSlot),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFCC2B2B) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFCC2B2B) : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      timeSlot,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDonationTypeSection() {
    if (_selectedDay == null || _selectedTimeSlot == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Donation Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDonationType,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Select donation type'),
                ),
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                items: _donationTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedDonationType = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    if (_selectedDay == null || _selectedTimeSlot == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Any special requirements or medical conditions...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleButton() {
    final bool canSchedule = _selectedDay != null && 
                           _selectedTimeSlot != null && 
                           _selectedDonationType != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: canSchedule ? _handleScheduleAppointment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCC2B2B),
          disabledBackgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Schedule Appointment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFCC2B2B)),
                SizedBox(width: 8),
                Text(
                  'Important Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem('Please arrive 15 minutes before your appointment'),
            _buildInfoItem('Bring a valid ID and any relevant medical records'),
            _buildInfoItem('Eat well and stay hydrated before donation'),
            _buildInfoItem('You can reschedule up to 24 hours before'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFCC2B2B), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _handleScheduleAppointment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.calendar_today, color: Color(0xFFCC2B2B)),
            SizedBox(width: 8),
            Text('Confirm Appointment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('MMMM d, yyyy').format(_selectedDay!)}'),
            Text('Time: $_selectedTimeSlot'),
            Text('Type: $_selectedDonationType'),
            if (_notesController.text.isNotEmpty)
              Text('Notes: ${_notesController.text}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC2B2B),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Success'),
          ],
        ),
        content: const Text(
          'Your appointment has been scheduled successfully! You will receive a confirmation email shortly.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC2B2B),
            ),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
} 