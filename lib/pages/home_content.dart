import 'dart:math';

import 'package:flutter/material.dart';
import 'package:homecare_helper/data/model/customer.dart';
import 'package:homecare_helper/data/model/helper.dart';
import 'package:homecare_helper/data/model/request.dart';
import 'package:homecare_helper/data/repository/repository.dart';

class HomeContent extends StatefulWidget {
  final Helper helper; // Accept Helper object
  final List<Requests> requests;
  final List<Customer> customers;

  const HomeContent({
    super.key,
    required this.helper,
    required this.requests,
    required this.customers,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _selectedStatus = "Tất cả";
  final List<String> _statusFilters = [
    "Tất cả",
    "Chờ xác nhận",
    "Đã nhận",
    "Đang thực hiện"
  ];

  Future<void> assignedRequest(Requests request) async{
    var repository = DefaultRepository();
    await repository.remoteDataSource.assignedRequest(request.scheduleIds.first);
    setState(() {
      request.status = 'assigned';
    });
  }

  Future<void> processingRequest(Requests request) async{
    var repository = DefaultRepository();
    await repository.remoteDataSource.processingRequest(request.scheduleIds.first);
    setState(() {
      request.status = 'processing';
    });
  }

  Future<void> finishRequest(Requests request) async{
    var repository = DefaultRepository();
    await repository.remoteDataSource.finishRequest(request.scheduleIds.first);
    setState(() {
      request.status = 'waitPayment';
    });
  }

  Future<void> finishPayment(Requests request) async{
    var repository = DefaultRepository();
    await repository.remoteDataSource.finishPayment(request.scheduleIds.first);
    setState(() {
      request.status = 'done';
    });
  }

  Future<void> cancelRequest(Requests request) async{
    var repository = DefaultRepository();
    await repository.remoteDataSource.cancelRequest(request.id);
    print("thông tin huỷ request $request");
    setState(() {
      request.status = 'cancelled';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter requests assigned to the logged-in helper
    List<Requests> helperRequests = widget.requests;
    print("độ dài: ${helperRequests.length}");
    // Further filter requests based on selected status
    List<Requests> filteredRequests = _selectedStatus == "Tất cả"
        ? helperRequests
        : helperRequests.where((req) => req.status == _selectedStatus).toList();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with greeting and helper info
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage('${widget.helper.avatar}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Xin chào,",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                      Text(
                        '${widget.helper.fullName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Trực tuyến",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Summary cards
            Row(
              children: [
                Flexible(
                  child: _buildSummaryCard(
                    icon: Icons.work,
                    color: Colors.blue,
                    title: "Công việc hôm nay",
                    value: _countTodayJobs(helperRequests).toString(),
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: _buildSummaryCard(
                    icon: Icons.monetization_on,
                    color: Colors.green,
                    title: "Thu nhập tháng",
                    value: _calculateMonthlyIncome(helperRequests),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Filter chips
            const Text(
              "Yêu cầu công việc tuần này",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Quicksand',
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                children: _statusFilters.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: FilterChip(
                      label: Text(status),
                      labelStyle: TextStyle(
                        color: _selectedStatus == status
                            ? Colors.green
                            : Colors.grey[600],
                        fontFamily: 'Quicksand',
                      ),
                      selected: _selectedStatus == status,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = status;
                        });
                      },
                      selectedColor: Colors.green.withOpacity(0.2),
                      checkmarkColor: Colors.green,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Job listings
            Expanded(
              child: filteredRequests.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: filteredRequests.length,
                      itemBuilder: (context, index) {
                        final request = filteredRequests[index];
                        return _buildJobCard(request);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Count jobs scheduled for today
  int _countTodayJobs(List<Requests> requests) {
    final today = DateTime.now().toString().split(' ')[0]; // Get YYYY-MM-DD
    return requests
        .where((req) => req.startDate?.contains(today) ?? false)
        .length;
  }

  // Calculate monthly income from job profits
  String _calculateMonthlyIncome(List<Requests> requests) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    int totalIncome = 0;

    for (var req in requests) {
      if (req.startDate != null) {
        try {
          final date = DateTime.parse(req.startDate!);
          if (date.month == currentMonth && date.year == currentYear) {
            totalIncome += req.profit.toInt();
          }
        } catch (e) {
          // Skip if date can't be parsed
        }
      }
    }

    // Format as Vietnamese currency
    return '${totalIncome.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_off_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          Text('${widget.requests.length}'),
          const SizedBox(height: 16),
          Text(
            "Không có yêu cầu nào",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand',
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Hiện tại chưa có yêu cầu nào phù hợp với bộ lọc",
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Quicksand',
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Quicksand',
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Requests request) {
    // Get job status
    String status = request.status;
    // Define status color
    Color statusColor;
    if (status == "Chờ xác nhận") {
      statusColor = Colors.orange;
    } else if (status == "Đã nhận") {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.blue;
    }

    // Format cost as currency
    String price =
        '${request.totalCost.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';

    // Extract date and time information
    String date = "Chưa có lịch";
    String time = "${request.startTime} - ${request.endTime}";
    if (request.startDate != null) {
      try {
        final dateTime = DateTime.parse(request.startDate!);
        date = '${dateTime.day}/${dateTime.month}';
      } catch (e) {
        // Use default if date can't be parsed
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Job header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.cleaning_services,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.service.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Quicksand',
                          color: Colors.red[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          // Job details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(Icons.person,
                    "Khách hàng: ${request.customerInfo.fullName}"),
                const SizedBox(height: 8),
                _buildDetailRow(
                    Icons.phone, "Điện thoại: ${request.customerInfo.phone}"),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.location_city,
                    "${request.location.ward}, ${request.location.district}, ${request.location.province}"),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal, // Cuộn ngang nếu nội dung quá dài
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Ngày bắt đầu: $date",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('lúc $time'),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (status == "notDone") ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _showRejectConfirmationDialog(request);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Từ chối",
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _showAcceptConfirmationDialog(request);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Nhận việc",
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ] else if (status == "assigned") ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            processingRequest(request);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Bắt đầu làm việc",
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ] else if (status == "Đang thực hiện") ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle finish work
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Hoàn thành",
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 15,
              fontFamily: 'Quicksand',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showRejectConfirmationDialog(Requests request) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Xác nhận từ chối',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Bạn có chắc chắn muốn từ chối công việc này?',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Dịch vụ: ${request.service.title}',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Khách hàng: ${request.customerInfo.fullName}',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Hủy',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  color: Colors.grey[700],
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop;
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Từ chối',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                //Handle job rejection logic here
                cancelRequest(request);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã từ chối công việc thành công',
                      style: TextStyle(fontFamily: 'Quicksand'),
                    ),
                    backgroundColor: Colors.red[700],
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAcceptConfirmationDialog(Requests request) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Xác nhận nhận việc',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Bạn có chắc chắn muốn nhận công việc này?',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Dịch vụ: ${request.service.title}',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Khách hàng: ${request.customerInfo.fullName}',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Địa chỉ: ${request.customerInfo.address}',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Thời gian: ${request.startTime} - ${request.endTime}',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Tổng tiền: ${request.profit.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w500,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Hủy',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  color: Colors.grey[700],
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Nhận việc',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                // Handle job acceptance logic here
                assignedRequest(request);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã nhận việc thành công',
                      style: TextStyle(fontFamily: 'Quicksand'),
                    ),
                    backgroundColor: Colors.green[700],
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
