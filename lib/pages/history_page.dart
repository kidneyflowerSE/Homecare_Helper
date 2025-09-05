import 'package:flutter/material.dart';
import 'package:homecare_helper/data/model/RequestHelper.dart';
import 'package:homecare_helper/data/model/request.dart';
import 'package:homecare_helper/pages/order_detail_page.dart';
import 'package:intl/intl.dart';

import '../data/repository/repository.dart';

class HistoryPage extends StatefulWidget {
  final String token;
  final String refreshToken;
  const HistoryPage({Key? key, required this.token, required this.refreshToken}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<RequestHelper> assignedRequests = [];
  List<RequestHelper> completedRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var repository = DefaultRepository();
      var assignedRequestsData =
      await repository.loadAssignedRequest(widget.token);

      if (mounted) {
        setState(() {
          assignedRequests = assignedRequestsData ?? [];
          _filterAndSortCompletedRequests();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterAndSortCompletedRequests() {
    // Filter only completed requests
    completedRequests = assignedRequests.where((request) {
      return request.schedules.isNotEmpty &&
             request.schedules.first.status == "completed";
    }).toList();

    // Sort by date (newest first)
    completedRequests.sort((a, b) {
      try {
        DateTime dateA = a.startTime;
        DateTime dateB = b.startTime;
        return dateB.compareTo(dateA); // Newest first
      } catch (e) {
        return 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lịch sử công việc",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
            fontFamily: 'Quicksand',
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : completedRequests.isEmpty
              ? _buildEmptyState("Bạn chưa có đơn hoàn thành nào")
              : _buildRequestsList(),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
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
            message,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Quicksand',
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedRequests.length,
      itemBuilder: (context, index) {
        final request = completedRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(RequestHelper request) {
    // Format date
    String formattedDate = "";
    try {
      final DateTime orderDate = DateTime.parse(request.orderDate);
      formattedDate = DateFormat('dd/MM/yyyy').format(orderDate);
    } catch (e) {
      formattedDate = request.orderDate;
    }

    // Format time from schedules
    String formattedTime = "";
    try {
      if (request.schedules.isNotEmpty) {
        final schedule = request.schedules.first;
        final startTime = schedule.startTime;
        final endTime = schedule.endTime;
        final timeFormat = DateFormat('HH:mm');
        formattedTime = "${timeFormat.format(startTime)} - ${timeFormat.format(endTime)}";
      }
    } catch (e) {
      formattedTime = "Không xác định";
    }

    // Format currency
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final String formattedPrice = formatter.format(request.totalCost);

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
                    Icons.check_circle,
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
                        request.customerInfo.fullName,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Quicksand',
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Hoàn thành",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w500,
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
                _buildDetailRow(Icons.location_on,
                    request.customerInfo.address),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.calendar_today,
                    "$formattedDate, $formattedTime"),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.attach_money, formattedPrice),
              ],
            ),
          ),

          // Rating section
          Divider(height: 1, color: Colors.grey[200]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  "Đánh giá: ",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Quicksand',
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 4),
                Row(
                  children: List.generate(5, (index) {
                    // Generate rating based on ID hash code instead of parsing as int
                    final int rating = (request.id.hashCode % 5) + 1;
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailPage(request: request),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(
                    color: Colors.green,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Xem chi tiết",
                  style: TextStyle(
                    color: Colors.green,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
              fontSize: 14,
              fontFamily: 'Quicksand',
            ),
          ),
        ),
      ],
    );
  }
}
