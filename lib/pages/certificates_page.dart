import 'package:flutter/material.dart';
import 'package:homecare_helper/data/model/helper.dart';

class CertificatesPage extends StatefulWidget {
  final Helper helper;

  const CertificatesPage({Key? key, required this.helper}) : super(key: key);

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chứng chỉ & Kỹ năng",
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
          children: [
            // Skills section
            _buildSkillsSection(),
            const SizedBox(height: 16),

            // Health certificates section
            _buildHealthCertificatesSection(),
            const SizedBox(height: 16),

            // Work experience section
            _buildExperienceSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCertificateDialog();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.handyman, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  "Kỹ năng & Dịch vụ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.helper.jobDetail ?? "Không có thông tin",
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Quicksand',
              ),
            ),
            const SizedBox(height: 16),
            if (widget.helper.jobs.isNotEmpty) ...[
              const Text(
                "Danh sách dịch vụ:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Quicksand',
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.helper.jobs.map((job) {
                  return Chip(
                    label: Text(job),
                    backgroundColor: Colors.green.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.green),
                  );
                }).toList(),
              ),
            ] else ...[
              const Text(
                "Chưa có dịch vụ nào được đăng ký",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'Quicksand',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCertificatesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medical_services, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  "Chứng chỉ sức khỏe",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.helper.healthCertificates.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemCount: widget.helper.healthCertificates.length,
                itemBuilder: (context, index) {
                  return _buildCertificateCard(widget.helper.healthCertificates[index], index);
                },
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    Icon(Icons.description, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      "Chưa có chứng chỉ sức khỏe",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Quicksand',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateCard(String certificateUrl, int index) {
    return GestureDetector(
      onTap: () {
        _showCertificateDialog(certificateUrl);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Image.network(
                certificateUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      _showDeleteConfirmDialog(index);
                    },
                    icon: const Icon(Icons.delete, color: Colors.white, size: 16),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timeline, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  "Kinh nghiệm làm việc",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.work, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "${widget.helper.yearOfExperience} năm kinh nghiệm",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Mô tả:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontFamily: 'Quicksand',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.helper.experienceDescription ?? "Chưa có mô tả kinh nghiệm",
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Quicksand',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCertificateDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text("Chứng chỉ"),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text("Không thể tải hình ảnh"),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCertificateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Thêm chứng chỉ"),
          content: const Text("Chức năng thêm chứng chỉ sẽ được phát triển trong phiên bản tiếp theo."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Đóng"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: const Text("Bạn có chắc chắn muốn xóa chứng chỉ này không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement delete certificate
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Chức năng xóa sẽ được thêm")),
                );
              },
              child: const Text("Xóa", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
