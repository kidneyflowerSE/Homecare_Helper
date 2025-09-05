import 'package:flutter/material.dart';
import 'package:homecare_helper/data/model/RequestHelper.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends StatefulWidget {
  final RequestHelper request;

  const OrderDetailPage({Key? key, required this.request}) : super(key: key);

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chi tiết đơn hàng",
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Header
            _buildStatusCard(),
            const SizedBox(height: 16),

            // Customer Information
            _buildInfoCard("Thông tin khách hàng", [
              _buildInfoRow("Họ và tên", widget.request.customerInfo.fullName, Icons.person),
              _buildInfoRow("Số điện thoại", widget.request.customerInfo.phone, Icons.phone),
              _buildInfoRow("Địa chỉ", widget.request.customerInfo.address, Icons.location_on),
              _buildInfoRow("Điểm đã sử dụng", "${widget.request.customerInfo.usedPoint} điểm", Icons.stars),
            ]),

            const SizedBox(height: 16),

            // Service Information
            _buildInfoCard("Thông tin dịch vụ", [
              _buildInfoRow("Tên dịch vụ", widget.request.service.title, Icons.home_repair_service),
              _buildInfoRow("Giá cơ bản", "${NumberFormat('#,###').format(widget.request.service.cost)} VNĐ", Icons.attach_money),
              _buildInfoRow("Hệ số dịch vụ", "x${widget.request.service.coefficientService}", Icons.trending_up),
              _buildInfoRow("Hệ số khác", "x${widget.request.service.coefficientOther}", Icons.trending_up),
              _buildInfoRow("Hệ số OT", "x${widget.request.service.coefficientOt}", Icons.access_time),
            ]),

            const SizedBox(height: 16),

            // Order Information
            _buildInfoCard("Thông tin đơn hàng", [
              _buildInfoRow("Mã đơn hàng", widget.request.id, Icons.receipt),
              _buildInfoRow("Ngày đặt", _formatDate(widget.request.orderDate), Icons.calendar_today),
              _buildInfoRow("Thời gian bắt đầu", _formatDateTime(widget.request.startTime), Icons.schedule),
              _buildInfoRow("Thời gian kết thúc", _formatDateTime(widget.request.endTime), Icons.schedule_outlined),
              _buildInfoRow("Tổng chi phí", "${NumberFormat('#,###').format(widget.request.totalCost)} VNĐ", Icons.payment),
            ]),

            const SizedBox(height: 16),

            // Schedules List
            _buildSchedulesCard(),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (widget.request.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Chờ xử lý';
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        statusText = 'Đã xác nhận';
        break;
      case 'in_progress':
        statusColor = Colors.green;
        statusIcon = Icons.work;
        statusText = 'Đang thực hiện';
        break;
      case 'completed':
        statusColor = Colors.green[700]!;
        statusIcon = Icons.check_circle_outline;
        statusText = 'Hoàn thành';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Đã hủy';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = widget.request.status;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trạng thái đơn hàng',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'Quicksand',
                  ),
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Quicksand',
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Quicksand',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Lịch trình công việc',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Quicksand',
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.request.schedules.length} ca làm',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.request.schedules.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Chưa có lịch trình nào được tạo',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ),
              )
            else
              ...widget.request.schedules.map((schedule) => _buildScheduleItem(schedule)),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(Schedule schedule) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (schedule.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Chờ thực hiện';
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusIcon = Icons.work;
        statusText = 'Đang thực hiện';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Hoàn thành';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Đã hủy';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = schedule.status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                ),
              ),
              const Spacer(),
              Text(
                "${NumberFormat('#,###').format(schedule.helperCost)} VNĐ",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(_formatDate(schedule.workingDate)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text('${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}'),
            ],
          ),
          if (schedule.comment.review.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đánh giá:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(schedule.comment.review),
                  if (schedule.comment.loseThings || schedule.comment.breakThings) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (schedule.comment.loseThings)
                          const Chip(
                            label: Text('Làm mất đồ', style: TextStyle(fontSize: 10)),
                            backgroundColor: Colors.red,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        if (schedule.comment.breakThings) ...[
                          if (schedule.comment.loseThings) const SizedBox(width: 8),
                          const Chip(
                            label: Text('Làm hỏng đồ', style: TextStyle(fontSize: 10)),
                            backgroundColor: Colors.orange,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (widget.request.status.toLowerCase() == 'pending') ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showCancelDialog(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Hủy đơn'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _confirmOrder(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
            ),
          ),
        ] else if (widget.request.status.toLowerCase() == 'confirmed') ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () => _startWork(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Bắt đầu làm việc', style: TextStyle(color: Colors.white)),
            ),
          ),
        ] else if (widget.request.status.toLowerCase() == 'in_progress') ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () => _completeWork(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Hoàn thành', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã hủy đơn hàng')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );
  }

  void _confirmOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xác nhận đơn hàng')),
    );
  }

  void _startWork() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã bắt đầu làm việc')),
    );
  }

  void _completeWork() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã hoàn thành công việc')),
    );
  }

  String _formatCurrency(num amount) {
    return NumberFormat('#,###').format(amount) + ' VNĐ';
  }

  String _formatRequestType(String requestType) {
    switch (requestType.toLowerCase()) {
      case 'short_term':
        return 'Ngắn hạn';
      case 'long_term':
        return 'Dài hạn';
      default:
        return requestType;
    }
  }
}
