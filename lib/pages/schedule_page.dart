import 'package:flutter/material.dart';
import 'package:homecare_helper/data/model/helper.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  final Helper helper;

  const SchedulePage({Key? key, required this.helper}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mock data for schedules
  Map<DateTime, List<Schedule>> _schedules = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadMockSchedules();
  }

  void _loadMockSchedules() {
    final today = DateTime.now();
    _schedules = {
      today: [
        Schedule(
          id: '1',
          title: 'Chăm sóc bà Nguyễn Thị Lan',
          startTime: '08:00',
          endTime: '12:00',
          address: '123 Nguyễn Trãi, Q1, TP.HCM',
          status: ScheduleStatus.confirmed,
        ),
        Schedule(
          id: '2',
          title: 'Chăm sóc ông Trần Văn Nam',
          startTime: '14:00',
          endTime: '18:00',
          address: '456 Lê Lợi, Q3, TP.HCM',
          status: ScheduleStatus.pending,
        ),
      ],
      today.add(const Duration(days: 1)): [
        Schedule(
          id: '3',
          title: 'Chăm sóc bà Phạm Thị Hoa',
          startTime: '09:00',
          endTime: '15:00',
          address: '789 Hai Bà Trưng, Q1, TP.HCM',
          status: ScheduleStatus.confirmed,
        ),
      ],
      today.add(const Duration(days: 2)): [
        Schedule(
          id: '4',
          title: 'Nghỉ phép',
          startTime: '00:00',
          endTime: '23:59',
          address: '',
          status: ScheduleStatus.leave,
        ),
      ],
    };
  }

  List<Schedule> _getSchedulesForDay(DateTime day) {
    return _schedules[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lịch làm việc",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
            fontFamily: 'Quicksand',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _showAddScheduleDialog(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Card(
            margin: const EdgeInsets.all(8),
            child: TableCalendar<Schedule>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getSchedulesForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                markerDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                formatButtonTextStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),

          // Schedule list for selected day
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lịch trình ngày ${DateFormat('dd/MM/yyyy').format(_selectedDay ?? DateTime.now())}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildScheduleList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    final schedules = _getSchedulesForDay(_selectedDay ?? DateTime.now());

    if (schedules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không có lịch trình nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Quicksand',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return _buildScheduleCard(schedule);
      },
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (schedule.status) {
      case ScheduleStatus.confirmed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Đã xác nhận';
        break;
      case ScheduleStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Chờ xác nhận';
        break;
      case ScheduleStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Đã hủy';
        break;
      case ScheduleStatus.leave:
        statusColor = Colors.blue;
        statusIcon = Icons.beach_access;
        statusText = 'Nghỉ phép';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(statusIcon, color: Colors.white),
        ),
        title: Text(
          schedule.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Quicksand',
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${schedule.startTime} - ${schedule.endTime}'),
              ],
            ),
            if (schedule.address.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(schedule.address)),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 4),
                Text(statusText, style: TextStyle(color: statusColor)),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditScheduleDialog(schedule);
                break;
              case 'delete':
                _showDeleteConfirmDialog(schedule);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm lịch trình'),
        content: const Text('Chức năng thêm lịch trình sẽ được phát triển'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showEditScheduleDialog(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa lịch trình'),
        content: Text('Chỉnh sửa: ${schedule.title}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa lịch trình "${schedule.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa lịch trình')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

// Schedule model
class Schedule {
  final String id;
  final String title;
  final String startTime;
  final String endTime;
  final String address;
  final ScheduleStatus status;

  Schedule({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.address,
    required this.status,
  });
}

enum ScheduleStatus {
  confirmed,
  pending,
  cancelled,
  leave,
}

