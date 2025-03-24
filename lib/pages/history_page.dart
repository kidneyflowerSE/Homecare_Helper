import 'package:flutter/material.dart';
import 'package:homecare_helper/data/model/request.dart';
import 'package:homecare_helper/pages/order_detail_page.dart';
import 'package:intl/intl.dart'; // For date formatting

// Assuming these are imported from your model files
// import 'package:your_app/models/requests.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Requests> _shortTermRequests = [];
  List<Requests> _longTermRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    // Mock data for demonstration
    _shortTermRequests = [
      Requests(
        customerInfo: CustomerInfo(
          fullName: "Nguyễn Văn A",
          phone: "0123456789",
          address: "123 Nguyễn Huệ, Quận 1",
          usedPoint: 0,
        ),
        service: RequestService(
          title: "Dọn dẹp nhà",
          coefficientService: 1.0,
          coefficientOther: 0.5,
          cost: 300000,
        ),
        location: RequestLocation(
          province: "TP.HCM",
          district: "Quận 1",
          ward: "Phường Bến Nghé",
        ),
        id: "1",
        oderDate: "2025-03-15",
        scheduleIds: ["S001"],
        startTime: "14:00",
        endTime: "16:00",
        requestType: "short_term",
        totalCost: 300000,
        status: "completed",
        deleted: false,
        comment: Comment(
          review: "Dịch vụ rất tốt, sẽ sử dụng lại",
          loseThings: false,
          breakThings: false,
        ),
        profit: 90000,
      ),
      Requests(
        customerInfo: CustomerInfo(
          fullName: "Trần Thị B",
          phone: "0987654321",
          address: "456 Lê Lợi, Quận 3",
          usedPoint: 10,
        ),
        service: RequestService(
          title: "Sửa điện nước",
          coefficientService: 1.2,
          coefficientOther: 0.8,
          cost: 450000,
        ),
        location: RequestLocation(
          province: "TP.HCM",
          district: "Quận 3",
          ward: "Phường 6",
        ),
        id: "2",
        oderDate: "2025-03-12",
        scheduleIds: ["S002"],
        startTime: "09:00",
        endTime: "11:00",
        requestType: "short_term",
        totalCost: 450000,
        status: "completed",
        deleted: false,
        comment: Comment(
          review: "Thợ làm việc chuyên nghiệp",
          loseThings: false,
          breakThings: false,
        ),
        profit: 135000,
      ),
      Requests(
        customerInfo: CustomerInfo(
          fullName: "Phạm Văn D",
          phone: "0909090909",
          address: "101 Võ Văn Tần, Quận 10",
          usedPoint: 0,
        ),
        service: RequestService(
          title: "Vệ sinh máy lạnh",
          coefficientService: 1.5,
          coefficientOther: 0.5,
          cost: 500000,
        ),
        location: RequestLocation(
          province: "TP.HCM",
          district: "Quận 10",
          ward: "Phường 8",
        ),
        id: "4",
        oderDate: "2025-03-08",
        scheduleIds: ["S004"],
        startTime: "10:00",
        endTime: "12:00",
        requestType: "short_term",
        totalCost: 500000,
        status: "cancelled",
        deleted: false,
        comment: Comment(
          review: "Khách hàng đổi lịch",
          loseThings: false,
          breakThings: false,
        ),
        profit: 0,
      ),
    ];

    _longTermRequests = [
      Requests(
        customerInfo: CustomerInfo(
          fullName: "Lê Văn C",
          phone: "0909123456",
          address: "789 Lý Tự Trọng, Quận 5",
          usedPoint: 5,
        ),
        service: RequestService(
          title: "Giúp việc theo giờ",
          coefficientService: 1.0,
          coefficientOther: 0.6,
          cost: 3200000,
        ),
        location: RequestLocation(
          province: "TP.HCM",
          district: "Quận 5",
          ward: "Phường 6",
        ),
        id: "3",
        oderDate: "2025-03-10",
        scheduleIds: ["S003", "S004", "S005"],
        startTime: "13:00",
        endTime: "15:00",
        requestType: "long_term",
        totalCost: 3200000,
        status: "completed",
        deleted: false,
        comment: Comment(
          review: "Nhân viên đúng giờ và làm việc tốt",
          loseThings: false,
          breakThings: false,
        ),
        profit: 960000,
        startDate: "2025-03-01",
      ),
    ];

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      if (!mounted) {
        _isLoading = false;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      body: Column(
        children: [
          Container(
            color: Colors.green,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                labelColor: Colors.green,
                dividerColor: Colors.transparent,
                unselectedLabelColor: Colors.white,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Tab(text: "Đơn ngắn hạn"),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Tab(text: "Đơn dài hạn"),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Short-term requests
                _shortTermRequests.isEmpty
                    ? _buildEmptyState("Bạn chưa có đơn ngắn hạn nào")
                    : _buildRequestsList(_shortTermRequests),

                // Long-term requests
                _longTermRequests.isEmpty
                    ? _buildEmptyState("Bạn chưa có đơn dài hạn nào")
                    : _buildRequestsList(_longTermRequests),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildRequestsList(List<Requests> requests) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(Requests request) {
    final bool isCompleted = request.status == "completed";
    final String statusText = isCompleted ? "Hoàn thành" : "Đã hủy";

    // Format date
    String formattedDate = "";
    try {
      final DateTime orderDate = DateTime.parse(request.oderDate);
      formattedDate = DateFormat('dd/MM/yyyy').format(orderDate);
    } catch (e) {
      formattedDate = request.oderDate;
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
                    color: isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.cancel,
                    color: isCompleted ? Colors.green : Colors.red,
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
                    color: isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: isCompleted ? Colors.green : Colors.red,
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
                    "${request.customerInfo.address}, ${request.location.ward}, ${request.location.district}, ${request.location.province}"),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.calendar_today,
                    "${formattedDate}, ${request.startTime} - ${request.endTime}"),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.attach_money, formattedPrice),
                if (!isCompleted && request.comment.review.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      Icons.info_outline, "Lý do: ${request.comment.review}"),
                ],
              ],
            ),
          ),

          // Rating if completed
          if (isCompleted) ...[
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
                      // Assuming rating is from 1-5 stars
                      // For demo, we'll use a random rating based on the request ID
                      final int rating = int.parse(request.id) % 5 + 1;
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
          ],

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

// // Order Detail Page
// class OrderDetailPage extends StatelessWidget {
//   final Requests request;

//   const OrderDetailPage({Key? key, required this.request}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Chi tiết đơn hàng",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//             color: Colors.white,
//             fontFamily: 'Quicksand',
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.green,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSectionTitle("Thông tin khách hàng"),
//             _buildInfoCard([
//               _buildInfoRow("Tên khách hàng", request.customerInfo.fullName),
//               _buildInfoRow("Số điện thoại", request.customerInfo.phone),
//               _buildInfoRow("Địa chỉ",
//                   "${request.customerInfo.address}, ${request.location.ward}, ${request.location.district}, ${request.location.province}"),
//               if (request.customerInfo.usedPoint != null &&
//                   request.customerInfo.usedPoint! > 0)
//                 _buildInfoRow(
//                     "Điểm sử dụng", "${request.customerInfo.usedPoint} điểm"),
//             ]),
//             const SizedBox(height: 16),
//             _buildSectionTitle("Thông tin dịch vụ"),
//             _buildInfoCard([
//               _buildInfoRow("Loại dịch vụ", request.service.title),
//               _buildInfoRow("Ngày đặt", _formatDate(request.oderDate)),
//               _buildInfoRow(
//                   "Thời gian", "${request.startTime} - ${request.endTime}"),
//               if (request.requestType == "long_term" &&
//                   request.startDate != null)
//                 _buildInfoRow("Ngày bắt đầu", _formatDate(request.startDate!)),
//               _buildInfoRow("Chi phí", _formatCurrency(request.totalCost)),
//               _buildInfoRow("Lợi nhuận", _formatCurrency(request.profit)),
//               _buildInfoRow("Trạng thái",
//                   request.status == "completed" ? "Hoàn thành" : "Đã hủy"),
//             ]),
//             if (request.comment.review.isNotEmpty) ...[
//               const SizedBox(height: 16),
//               _buildSectionTitle("Đánh giá & Ghi chú"),
//               _buildInfoCard([
//                 _buildInfoRow("Nhận xét", request.comment.review),
//                 if (request.comment.loseThings)
//                   _buildInfoRow("Thất lạc đồ", "Có"),
//                 if (request.comment.breakThings)
//                   _buildInfoRow("Hư hỏng đồ", "Có"),
//               ]),
//             ],
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   "Quay lại",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontFamily: 'Quicksand',
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Quicksand',
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(List<Widget> children) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: children,
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[700],
//                 fontFamily: 'Quicksand',
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 fontFamily: 'Quicksand',
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(String dateString) {
//     try {
//       final DateTime date = DateTime.parse(dateString);
//       return DateFormat('dd/MM/yyyy').format(date);
//     } catch (e) {
//       return dateString;
//     }
//   }

//   String _formatCurrency(num amount) {
//     final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
//     return formatter.format(amount);
//   }
// }
