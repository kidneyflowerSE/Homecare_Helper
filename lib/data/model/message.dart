class Message {
  String phone;
  String? otp;

  Message({required this.phone, this.otp});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      phone: json['phone'],
      otp: json['otp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
    };
  }

  @override
  String toString() {
    return 'Message{phone: $phone, otp: $otp}';
  }
}
