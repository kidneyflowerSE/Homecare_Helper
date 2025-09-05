import 'package:flutter/material.dart';
import 'package:homecare_helper/data/model/helper.dart';
import 'package:intl/intl.dart';

import '../data/model/RequestHelper.dart';
import '../data/repository/repository.dart';
import 'package:homecare_helper/pages/personal_info_page.dart';
import 'package:homecare_helper/pages/certificates_page.dart';
import 'package:homecare_helper/pages/schedule_page.dart';

class ProfilePage extends StatefulWidget {
  final String token;
  final String refreshToken;
  final Helper helper;

  const ProfilePage({Key? key, required this.token, required this.refreshToken, required this.helper})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<RequestHelper> assignedRequests = [];
  num totalCompletedJobs = 0;
  num totalEarnings = 0;
  double avgRating = 0.0;
  bool _isLoading = true;
  bool availableStatus = true;

  @override
  void initState() {
    super.initState();
    availableStatus = widget.helper.workingStatus == "working";
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
          _calculateStatistics();
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

  void _calculateStatistics() {
    final completedRequests = assignedRequests.where((request) {
      return request.schedules.isNotEmpty &&
          request.schedules.first.status == "completed";
    }).toList();

    totalCompletedJobs = completedRequests.length;

    // Calculate total earnings from completed jobs
    totalEarnings = completedRequests.fold(0, (sum, request) {
      return sum + (request.schedules.isNotEmpty ? request.schedules.first.helperCost : 0);
    });

    // Calculate average rating (mock calculation based on ID)
    if (completedRequests.isNotEmpty) {
      int totalRating = completedRequests.fold(0, (sum, request) {
        return sum + ((request.id.hashCode % 5) + 1);
      });
      avgRating = totalRating / completedRequests.length;
    }
  }

  String _formatMemberSince() {
    try {
      final startDate = DateTime.parse(widget.helper.startDate ?? '');
      return DateFormat('MM/yyyy').format(startDate);
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatCurrency(num amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            _buildProfileHeader(),

            // Statistics
            _buildStatistics(),

            // Menu sections
            _buildMenuSection("Thông tin tài khoản", _buildAccountMenuItems()),
            _buildMenuSection("Thông tin công việc", _buildWorkMenuItems()),
            _buildMenuSection("Cài đặt và hỗ trợ", _buildSettingsMenuItems()),

            // Logout button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Đăng xuất",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ),
              ),
            ),

            // Version info
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                "Phiên bản 1.0.0",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Avatar and name
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: widget.helper.avatar != null
                    ? NetworkImage(widget.helper.avatar!)
                    : AssetImage('lib/images/staff/anhhuy.jpg') as ImageProvider,
                onBackgroundImageError: (_, __) {},
                child: widget.helper.avatar == null
                    ? Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.helper.fullName ?? 'Không có tên',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${avgRating.toStringAsFixed(1)} | $totalCompletedJobs công việc",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontFamily: 'Quicksand',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Thành viên từ ${_formatMemberSince()}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Quicksand',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.edit),
                color: Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  "Trạng thái",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Quicksand',
                  ),
                ),
                const Spacer(),
                Text(
                  availableStatus ? "Đang hoạt động" : "Đang nghỉ",
                  style: TextStyle(
                    color: availableStatus ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Quicksand',
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: availableStatus,
                  onChanged: (value) {
                    setState(() {
                      availableStatus = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Verification badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildVerificationBadge("Xác thực", Icons.verified_user, widget.helper.status == "active"),
              _buildVerificationBadge("Địa chỉ", Icons.location_on, widget.helper.address != null),
              _buildVerificationBadge("Điện thoại", Icons.phone, widget.helper.phone != null),
              _buildVerificationBadge("Kỹ năng", Icons.handyman, widget.helper.jobs.isNotEmpty),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge(String title, IconData icon, bool isVerified) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isVerified
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isVerified ? Colors.green : Colors.grey,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isVerified ? Colors.green : Colors.grey,
            fontFamily: 'Quicksand',
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
          Text(
            "Thống kê",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "Tổng công việc",
                  totalCompletedJobs.toString(),
                  Icons.work,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  "Tổng thu nhập",
                  _formatCurrency(totalEarnings),
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "Kinh nghiệm",
                  "${widget.helper.yearOfExperience} năm",
                  Icons.timeline,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  "Đánh giá",
                  avgRating.toStringAsFixed(1),
                  Icons.star,
                  Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Thông tin cá nhân",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand',
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow("Giới tính", widget.helper.gender ?? "Không có thông tin"),
          _buildInfoRow("Số điện thoại", widget.helper.phone ?? "Không có thông tin"),
          _buildInfoRow("Địa chỉ", widget.helper.address ?? "Không có thông tin"),
          _buildInfoRow("Khu vực làm việc", "${widget.helper.workingArea.province} - ${widget.helper.workingArea.districts.join(', ')}"),
          _buildInfoRow("Mô tả công việc", widget.helper.jobDetail ?? "Không có thông tin"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$title:",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Quicksand',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                fontFamily: 'Quicksand',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontFamily: 'Quicksand',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Quicksand',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          ...items,
        ],
      ),
    );
  }

  List<Widget> _buildAccountMenuItems() {
    return [
      _buildMenuItem("Thông tin cá nhân", Icons.person, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonalInfoPage(helper: widget.helper),
          ),
        );
      }),
      _buildMenuItem("Chứng chỉ & Kỹ năng", Icons.verified, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CertificatesPage(helper: widget.helper),
          ),
        );
      }),
      _buildMenuItem("Tài khoản ngân hàng", Icons.account_balance, () {}),
    ];
  }

  List<Widget> _buildWorkMenuItems() {
    return [
      _buildMenuItem("Lịch làm việc", Icons.calendar_today, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SchedulePage(helper: widget.helper,),
          ),
        );
      }),
      _buildMenuItem("Thống kê thu nhập", Icons.bar_chart, () {}),
      _buildMenuItem("Đánh giá từ khách hàng", Icons.star, () {}),
    ];
  }

  List<Widget> _buildSettingsMenuItems() {
    return [
      _buildMenuItem("Cài đặt thông báo", Icons.notifications, () {}),
      _buildMenuItem("Bảo mật tài khoản", Icons.security, () {}),
      _buildMenuItem("Trung tâm hỗ trợ", Icons.help, () {}),
      _buildMenuItem("Điều khoản sử dụng", Icons.description, () {}),
    ];
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
          if (title != "Điều khoản sử dụng") // No divider for last item
            Divider(height: 1, color: Colors.grey[200], indent: 48),
        ],
      ),
    );
  }
}
