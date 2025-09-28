import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homecare_helper/services/fcm_service.dart';

class FCMStatusWidget extends StatefulWidget {
  @override
  _FCMStatusWidgetState createState() => _FCMStatusWidgetState();
}

class _FCMStatusWidgetState extends State<FCMStatusWidget> {
  String? _token;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    setState(() => _isLoading = true);
    String? token = FCMService.currentToken ?? await FCMService.getToken();
    setState(() {
      _token = token;
      _isLoading = false;
    });
  }

  Future<void> _copyToken() async {
    if (_token != null) {
      await Clipboard.setData(ClipboardData(text: _token!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token đã được copy!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ExpansionTile(
        leading: Icon(
          Icons.notifications_active,
          color: _token != null ? Colors.green : Colors.orange,
        ),
        title: Text(
          'Trạng thái thông báo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _token != null ? 'Hoạt động' : 'Đang khởi tạo...',
          style: TextStyle(
            color: _token != null ? Colors.green : Colors.orange,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FCM Token:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                if (_isLoading)
                  Center(child: CircularProgressIndicator())
                else if (_token != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      _token!,
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  )
                else
                  Text(
                    'Token chưa sẵn sàng',
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _token != null ? _copyToken : null,
                        icon: Icon(Icons.copy, size: 16),
                        label: Text('Copy Token'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loadToken,
                        icon: Icon(Icons.refresh, size: 16),
                        label: Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
