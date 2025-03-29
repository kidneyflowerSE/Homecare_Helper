import 'dart:math';

import 'package:flutter/material.dart';
import 'package:homecare_helper/data/model/customer.dart';
import 'package:homecare_helper/data/model/helper.dart';
import 'package:homecare_helper/data/model/request.dart';
import 'package:homecare_helper/data/repository/repository.dart';

import '../data/model/request_detail.dart';

class HomeContent extends StatefulWidget {
  final Helper helper;

  const HomeContent({
    Key? key,
    required this.helper,
  }) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _selectedStatus = "notDone";
  Key pageKey = UniqueKey();
  List<Requests> requests = [];
  List<Requests> helperRequests = [];
  List<Customer> customers = [];
  List<RequestDetail> requestDetails = [];
  bool isLoading = true;

  final List<String> _statusFilters = [
    "notDone",
    "assigned",
    "processing",
    "waitPayment",
    "done",
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      var repository = DefaultRepository();

      var fetchedRequests = await repository.loadRequest();
      var fetchedCustomers = await repository.loadCustomer();
      var fetchedRequestDetails =
          await repository.getRequestDetailById(widget.helper.id);

      setState(() {
        requests = fetchedRequests ?? [];
        customers = fetchedCustomers ?? [];
        requestDetails = fetchedRequestDetails ?? [];
        updateHelperRequests();
        isLoading = false;
        print('cập nhật lại dữ liệu');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải dữ liệu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void updateHelperRequests() {
    helperRequests = requests
        .where((request) => request.scheduleIds.any((scheduleId) =>
            requestDetails
                .any((requestDetail) => requestDetail.id == scheduleId)))
        .toList();
  }

  String getVietnameseStatus(String status) {
    switch (status) {
      case "notDone":
        return "Chờ xác nhận";
      case "assigned":
        return "Đã nhận việc";
      case "processing":
        return "Đang tiến hành";
      case "waitPayment":
        return "Chờ thanh toán";
      case "done":
        return "Hoàn thành";
      default:
        return "Không xác định";
    }
  }

  Future<void> assignedRequest(Requests request) async {
    var repository = DefaultRepository();
    for (var id in request.scheduleIds) {
      await repository.remoteDataSource.assignedRequest(id);
    }
    setState(() {
      request.status = 'assigned';
    });
  }

  Future<void> processingRequest(Requests request, int index) async {
    var repository = DefaultRepository();
    for (var i=0;i<index;++i) {
      await repository.remoteDataSource.processingRequest(request.scheduleIds[i]);
    }
    setState(() {
      request.status = 'processing';
    });
  }

  Future<void> finishRequest(Requests request, int index) async {
    var isAllDone = true;
    var repository = DefaultRepository();

    for (var id = 0;id<index;++id) {
      await repository.remoteDataSource.finishRequest(request.scheduleIds[id]);
    }

    var details = await repository.loadRequestDetailId(request.scheduleIds);

    for (var detail in details!) {
      print(detail);
      print(details.length);
      if (detail.status != 'done') {
        isAllDone = false;
        break;
      }
    }

    if (isAllDone) {
      await repository.remoteDataSource.waitPayment(request.id);
      setState(() {
        request.status = 'waitPayment';
      });
    }
  }

  Future<void> finishPayment(Requests request) async {
    var repository = DefaultRepository();
    await repository.remoteDataSource.finishPayment(request.scheduleIds.first);
    setState(() {
      request.status = 'done';
    });
  }

  Future<void> cancelRequest(Requests request) async {
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
    updateHelperRequests();
    // print("độ dài: ${helperRequests.length}");
    // Further filter requests based on selected status
    List<Requests> filteredRequests =
        helperRequests.where((req) => req.status == _selectedStatus).toList();

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
                      label: Text(getVietnameseStatus(status)),
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
              child: RefreshIndicator(
                onRefresh: () async {
                  loadData();
                  setState(() {
                    pageKey = UniqueKey(); // Thay đổi key để cập nhật lại UI
                  });
                },
                child: KeyedSubtree(
                  key: pageKey,
                  child: filteredRequests.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          key: const PageStorageKey<String>('job_list'),
                          itemCount: filteredRequests.length,
                          itemBuilder: (context, index) {
                            final request = filteredRequests[index];
                            return _buildJobCard(request);
                          },
                        ),
                ),
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
          Text('${helperRequests.length}'),
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
    DateTime now = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime start = DateTime(
        DateTime.parse(request.startTime).year,
        DateTime.parse(request.startTime).month,
        DateTime.parse(request.startTime).day);

    String status = request.status;
    Color statusColor;

    if (status == "notDone") {
      statusColor = Colors.red;
    } else if (status == "assigned") {
      statusColor = Colors.orange;
    } else if (status == "processing") {
      statusColor = Colors.teal;
    } else if (status == "waitPayment") {
      statusColor = Colors.blue;
    } else if (status == "done") {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.grey;
    }

    String price =
        '${request.totalCost.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';

    String time = "${request.startTime} - ${request.endTime}";

    int index = -1; // Mặc định
    if ((status == "processing" || status == 'assigned')&& (start.isBefore(now) || start.isAtSameMomentAs(now))) {
      index = now.difference(start).inDays;
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
                    getVietnameseStatus(status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
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
                      Column(
                        children: [
                          Text(
                            "Ngày: ${request.startTime}",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 15,
                              fontFamily: 'Quicksand',
                            ),
                          ),
                          Text(
                            "Thời gian: ${request.endTime}",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 15,
                              fontFamily: 'Quicksand',
                            ),
                          ),
                        ],
                      )
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
                    ] else if (status == "assigned" && index >= 0) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            processingRequest(request, index);
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
                    ] else if (status == "processing" && index >= 0) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            finishRequest(request, index);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Hoàn thành (Ngày: $index)",
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
                Navigator.of(context).pop();
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
