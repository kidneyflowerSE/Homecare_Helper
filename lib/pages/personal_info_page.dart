import 'package:flutter/material.dart';
import 'package:homecare_helper/data/model/helper.dart';
import 'package:intl/intl.dart';

class PersonalInfoPage extends StatefulWidget {
  final Helper helper;

  const PersonalInfoPage({Key? key, required this.helper}) : super(key: key);

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _experienceController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.helper.fullName ?? '');
    _phoneController = TextEditingController(text: widget.helper.phone ?? '');
    _addressController = TextEditingController(text: widget.helper.address ?? '');
    _experienceController = TextEditingController(text: widget.helper.experienceDescription ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Không có thông tin';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Thông tin cá nhân",
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
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar section
              _buildAvatarSection(),
              const SizedBox(height: 24),

              // Basic info
              _buildInfoCard("Thông tin cơ bản", [
                _buildEditableField("Họ và tên", _fullNameController, Icons.person),
                _buildEditableField("Số điện thoại", _phoneController, Icons.phone),
                _buildEditableField("Địa chỉ", _addressController, Icons.location_on),
                _buildReadOnlyField("Giới tính", widget.helper.gender ?? "Không có thông tin", Icons.wc),
                _buildReadOnlyField("Ngày sinh", _formatDate(widget.helper.birthDay), Icons.cake),
                _buildReadOnlyField("Nơi sinh", widget.helper.birthPlace ?? "Không có thông tin", Icons.place),
              ]),

              const SizedBox(height: 16),

              // Work info
              _buildInfoCard("Thông tin công việc", [
                _buildReadOnlyField("Mã nhân viên", widget.helper.helperId ?? "Không có thông tin", Icons.badge),
                _buildReadOnlyField("Ngày bắt đầu", _formatDate(widget.helper.startDate), Icons.work),
                _buildReadOnlyField("Kinh nghiệm", "${widget.helper.yearOfExperience} năm", Icons.timeline),
                _buildEditableField("Mô tả kinh nghiệm", _experienceController, Icons.description, maxLines: 3),
                _buildReadOnlyField("Trạng thái", widget.helper.status ?? "Không có thông tin", Icons.info),
              ]),

              const SizedBox(height: 16),

              // Physical info
              _buildInfoCard("Thông tin sức khỏe", [
                _buildReadOnlyField("Chiều cao", "${widget.helper.height} cm", Icons.height),
                _buildReadOnlyField("Cân nặng", "${widget.helper.weight} kg", Icons.monitor_weight),
                _buildReadOnlyField("Quốc tịch", widget.helper.nationality ?? "Không có thông tin", Icons.flag),
                _buildReadOnlyField("Trình độ học vấn", widget.helper.educationLevel ?? "Không có thông tin", Icons.school),
              ]),

              if (_isEditing) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            // Reset controllers
                            _fullNameController.text = widget.helper.fullName ?? '';
                            _phoneController.text = widget.helper.phone ?? '';
                            _addressController.text = widget.helper.address ?? '';
                            _experienceController.text = widget.helper.experienceDescription ?? '';
                          });
                        },
                        child: const Text("Hủy"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: Save changes
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Đã lưu thay đổi")),
                            );
                            setState(() {
                              _isEditing = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text("Lưu", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: widget.helper.avatar != null
                ? NetworkImage(widget.helper.avatar!)
                : const AssetImage('lib/images/staff/anhhuy.jpg') as ImageProvider,
            child: widget.helper.avatar == null
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    // TODO: Implement image picker
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Chức năng chọn ảnh sẽ được thêm")),
                    );
                  },
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                ),
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

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
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
                const SizedBox(height: 4),
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
}
