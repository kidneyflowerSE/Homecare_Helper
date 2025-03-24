import 'package:flutter/material.dart';
import 'package:homecare_helper/data/model/request.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends StatelessWidget {
  final Requests request;

  const OrderDetailPage({Key? key, required this.request}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = request.status == "completed";
    final statusText = isCompleted ? "Hoàn thành" : "Đã hủy";
    final statusColor = isCompleted ? Colors.green : Colors.red;

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
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // // Status Banner
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.symmetric(vertical: 16),
            //   color: statusColor.withOpacity(0.1),
            //   child: Column(
            //     children: [
            //       Icon(
            //         isCompleted ? Icons.check_circle : Icons.cancel,
            //         color: statusColor,
            //         size: 48,
            //       ),
            //       const SizedBox(height: 8),
            //       Text(
            //         statusText,
            //         style: TextStyle(
            //           color: statusColor,
            //           fontSize: 18,
            //           fontWeight: FontWeight.bold,
            //           fontFamily: 'Quicksand',
            //         ),
            //       ),
            //       const SizedBox(height: 4),
            //       Text(
            //         "Mã đơn: ${request.id}",
            //         style: TextStyle(
            //           color: Colors.grey[700],
            //           fontSize: 14,
            //           fontFamily: 'Quicksand',
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            _buildTimelineView(),

            // Service Information
            _buildSection(
              title: "Thông tin dịch vụ",
              icon: Icons.cleaning_services,
              children: [
                _buildInfoRow("Loại dịch vụ", request.service.title),
                _buildInfoRow(
                    "Loại yêu cầu", _formatRequestType(request.requestType)),
                _buildInfoRow("Ngày đặt", _formatDate(request.oderDate)),
                if (request.startDate != null)
                  _buildInfoRow(
                      "Ngày bắt đầu", _formatDate(request.startDate!)),
                _buildInfoRow(
                    "Thời gian", "${request.startTime} - ${request.endTime}"),
                _buildInfoRow("Hệ số dịch vụ",
                    request.service.coefficientService.toString()),
                _buildInfoRow(
                    "Hệ số khác", request.service.coefficientOther.toString()),
              ],
            ),

            // Customer Information
            _buildSection(
              title: "Thông tin khách hàng",
              icon: Icons.person,
              children: [
                _buildInfoRow("Tên khách hàng", request.customerInfo.fullName),
                _buildInfoRow("Số điện thoại", request.customerInfo.phone),
                _buildInfoRow("Địa chỉ", request.customerInfo.address),
                _buildInfoRow(
                    "Điểm sử dụng", "${request.customerInfo.usedPoint} điểm"),
              ],
            ),

            // Location Information
            _buildSection(
              title: "Địa chỉ thực hiện",
              icon: Icons.location_on,
              children: [
                _buildInfoRow("Tỉnh/Thành phố", request.location.province),
                _buildInfoRow("Quận/Huyện", request.location.district),
                _buildInfoRow("Phường/Xã", request.location.ward),
              ],
            ),

            // Financial Information
            _buildSection(
              title: "Thông tin thanh toán",
              icon: Icons.attach_money,
              children: [
                _buildInfoRow(
                    "Chi phí dịch vụ", _formatCurrency(request.service.cost)),
                _buildInfoRow(
                    "Tổng chi phí", _formatCurrency(request.totalCost)),
                _buildInfoRow("Lợi nhuận", _formatCurrency(request.profit)),
              ],
            ),

            // Schedule Information
            _buildSection(
              title: "Lịch trình",
              icon: Icons.schedule,
              children: [
                _buildInfoRow("Mã lịch trình", request.scheduleIds.join(", ")),
                if (request.helperId != null)
                  _buildInfoRow("Mã nhân viên", request.helperId!),
              ],
            ),

            // Feedback and Comments
            _buildSection(
              title: "Đánh giá & Phản hồi",
              icon: Icons.rate_review,
              children: [
                _buildInfoRow(
                    "Đánh giá",
                    request.comment.review.isEmpty
                        ? "Chưa có đánh giá"
                        : request.comment.review),
                _buildInfoRow("Mất mát đồ đạc",
                    request.comment.loseThings ? "Có" : "Không"),
                _buildInfoRow("Hư hỏng đồ đạc",
                    request.comment.breakThings ? "Có" : "Không"),

                // Rating Stars
                if (isCompleted) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Số sao: ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontFamily: 'Quicksand',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        children: List.generate(5, (index) {
                          // Assuming rating is from 1-5 stars
                          // Using a mock rating based on the request ID
                          final int rating = int.parse(request.id) % 5 + 1;
                          return Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Handle printing or sharing the order details
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Đang in thông tin đơn hàng...")),
                        );
                      },
                      icon: const Icon(Icons.print, color: Colors.white),
                      label: const Text(
                        "In thông tin đơn hàng",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.green),
                      label: const Text(
                        "Quay lại",
                        style: TextStyle(
                          color: Colors.green,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                          color: Colors.green,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineView() {
    // Lấy trạng thái từ widget.request (có thể thay đổi tùy theo dữ liệu của bạn)
    // String orderStatus = widget.request.status;
    String orderStatus = 'assigned';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildTimelineItem(
            title: 'Đã đặt đơn',
            // time: _formatDate(widget.request.oderDate),
            time: '55',
            isActive: true,
            isFirst: true,
          ),
          if (orderStatus == 'assigned') ...[
            _buildTimelineItem(
              title: 'Đã xác nhận',
              time: 'Hoàn thành',
              isActive: true,
            ),
            _buildTimelineItem(
              title: 'Đang thực hiện',
              time: 'Đang chờ',
              isActive: false,
            ),
            _buildTimelineItem(
              title: 'Đã hoàn thành',
              time: 'Đang chờ',
              isActive: false,
              isLast: true,
            ),
          ],
          if (orderStatus == 'processing') ...[
            _buildTimelineItem(
              title: 'Đã xác nhận',
              time: 'Hoàn thành',
              isActive: true,
            ),
            _buildTimelineItem(
              title: 'Đang thực hiện',
              time: 'Hoàn thành',
              isActive: true,
            ),
            _buildTimelineItem(
              title: 'Đã hoàn thành',
              time: 'Đang chờ',
              isActive: false,
              isLast: true,
            ),
          ],
          if (orderStatus == 'done') ...[
            _buildTimelineItem(
              title: 'Đã xác nhận',
              time: 'Hoàn thành',
              isActive: true,
            ),
            _buildTimelineItem(
              title: 'Đang thực hiện',
              time: 'Hoàn thành',
              isActive: true,
            ),
            _buildTimelineItem(
              title: 'Đã hoàn thành',
              time: 'Hoàn thành',
              isActive: true,
              isLast: true,
            ),
          ],
          if (orderStatus == 'cancelled')
            _buildTimelineItem(
              title: 'Đơn bị huỷ',
              time: 'Đã huỷ',
              isActive: true,
              isLast: true,
              isCancelled: true,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String time,
    required bool isActive,
    bool isFirst = false,
    bool isLast = false,
    bool isCancelled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCancelled
                    ? Colors.red
                    : (isActive ? Colors.green : Colors.grey.shade300),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCancelled
                      ? Colors.red.shade100
                      : (isActive ? Colors.green.shade100 : Colors.white),
                  width: 3,
                ),
              ),
              child: isActive || isCancelled
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
            // Text('hehee'),
            const SizedBox(width: 10),

            if (!isLast)
              Container(
                height: 2,
                width: 40,
                color: isCancelled
                    ? Colors.red
                    : (isActive ? Colors.green : Colors.grey.shade300),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isCancelled
                ? Colors.red
                : (isActive ? Colors.black : Colors.grey),
            fontFamily: 'Quicksand',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            fontSize: 13,
            color: isCancelled
                ? Colors.red
                : (isActive ? Colors.green : Colors.grey),
            fontFamily: 'Quicksand',
          ),
        ),
        // SizedBox(height: isLast ? 0 : 20),
      ],
    );
  }

  // Widget _buildTimelineItem({
  //   required String title,
  //   required String time,
  //   required bool isActive,
  //   bool isFirst = false,
  //   bool isLast = false,
  //   bool isCancelled = false,
  // }) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       SizedBox(
  //         width: 30,
  //         child: Column(
  //           children: [
  //             Container(
  //               width: 20,
  //               height: 20,
  //               decoration: BoxDecoration(
  //                 color: isCancelled
  //                     ? Colors.red
  //                     : (isActive ? Colors.green : Colors.grey.shade300),
  //                 shape: BoxShape.circle,
  //                 border: Border.all(
  //                   color: isCancelled
  //                       ? Colors.red.shade100
  //                       : (isActive ? Colors.green.shade100 : Colors.white),
  //                   width: 3,
  //                 ),
  //               ),
  //               child: isActive || isCancelled
  //                   ? const Icon(Icons.check, color: Colors.white, size: 12)
  //                   : null,
  //             ),
  //             if (!isLast)
  //               Container(
  //                 width: 2,
  //                 height: 40,
  //                 color: isCancelled
  //                     ? Colors.red
  //                     : (isActive ? Colors.green : Colors.grey.shade300),
  //                 margin: const EdgeInsets.symmetric(vertical: 4),
  //               ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(width: 10),
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               title,
  //               style: TextStyle(
  //                 fontSize: 15,
  //                 fontWeight: FontWeight.w600,
  //                 color: isCancelled
  //                     ? Colors.red
  //                     : (isActive ? Colors.black : Colors.grey),
  //                 fontFamily: 'Quicksand',
  //               ),
  //             ),
  //             const SizedBox(height: 4),
  //             Text(
  //               time,
  //               style: TextStyle(
  //                 fontSize: 13,
  //                 color: isCancelled
  //                     ? Colors.red
  //                     : (isActive ? Colors.green : Colors.grey),
  //                 fontFamily: 'Quicksand',
  //               ),
  //             ),
  //             SizedBox(height: isLast ? 0 : 20),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Quicksand',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          // Section content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontFamily: 'Quicksand',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Quicksand',
              ),
            ),
          ),
        ],
      ),
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

  String _formatCurrency(num amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(amount);
  }

  String _formatRequestType(String requestType) {
    switch (requestType) {
      case 'short_term':
        return 'Ngắn hạn';
      case 'long_term':
        return 'Dài hạn';
      default:
        return requestType;
    }
  }
}
