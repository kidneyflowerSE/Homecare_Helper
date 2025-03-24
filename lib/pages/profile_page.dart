import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Map<String, dynamic> _userProfile = {
    'name': 'Phạm Nguyễn Quốc Huy',
    'email': 'pnghuyuidev@gmail.com',
    'phone': '0901234567',
    'address': 'Quận 1, TP.HCM',
    'avgRating': 4.8,
    'totalJobs': 56,
    'totalEarnings': '12.500.000đ',
    'memberSince': '05/2024',
    'skills': ['Dọn dẹp nhà', 'Giặt ủi', 'Sửa điện nước', 'Vệ sinh máy lạnh'],
    'verification': {
      'identity': true,
      'address': true,
      'phone': true,
      'skills': true,
    },
    'availableStatus': true,
  };

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
                backgroundImage: AssetImage('lib/images/staff/anhhuy.jpg'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userProfile['name'],
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
                          "${_userProfile['avgRating']} | ${_userProfile['totalJobs']} công việc",
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
                      "Thành viên từ ${_userProfile['memberSince']}",
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
                  _userProfile['availableStatus']
                      ? "Đang hoạt động"
                      : "Đang nghỉ",
                  style: TextStyle(
                    color: _userProfile['availableStatus']
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Quicksand',
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _userProfile['availableStatus'],
                  onChanged: (value) {
                    setState(() {
                      _userProfile['availableStatus'] = value;
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
              _buildVerificationBadge("Xác thực", Icons.verified_user,
                  _userProfile['verification']['identity']),
              _buildVerificationBadge("Địa chỉ", Icons.location_on,
                  _userProfile['verification']['address']),
              _buildVerificationBadge("Điện thoại", Icons.phone,
                  _userProfile['verification']['phone']),
              _buildVerificationBadge("Kỹ năng", Icons.handyman,
                  _userProfile['verification']['skills']),
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
                  _userProfile['totalJobs'].toString(),
                  Icons.work,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  "Tổng thu nhập",
                  _userProfile['totalEarnings'],
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Kỹ năng",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                (_userProfile['skills'] as List<String>).map<Widget>((skill) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Quicksand',
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontFamily: 'Quicksand',
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
      _buildMenuItem("Thông tin cá nhân", Icons.person, () {}),
      _buildMenuItem("Chứng chỉ & Kỹ năng", Icons.verified, () {}),
      _buildMenuItem("Tài khoản ngân hàng", Icons.account_balance, () {}),
    ];
  }

  List<Widget> _buildWorkMenuItems() {
    return [
      _buildMenuItem("Lịch làm việc", Icons.calendar_today, () {}),
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
