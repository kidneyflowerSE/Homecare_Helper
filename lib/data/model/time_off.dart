class TimeOff {
  String id;
  String helperId;
  String dateOff;
  int startTime;
  int endTime;
  String reason;
  String status;

  TimeOff({
    required this.id,
    required this.helperId,
    required this.dateOff,
    required this.startTime,
    required this.endTime,
    required this.reason,
    required this.status,
  });

  factory TimeOff.fromJson(Map<String, dynamic> json) {
    return TimeOff(
      id: json['_id'] ?? '',
      helperId: json['helper_id'] ?? '',
      dateOff: json['dateOff'] ?? '',
      startTime: json['startTime'] ?? 0,
      endTime: json['endTime'] ?? 0,
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'helper_id': helperId,
      'dateOff': dateOff,
      'startTime': startTime,
      'endTime': endTime,
      'reason': reason,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'TimeOff{id: $id, helperId: $helperId, dateOff: $dateOff, startTime: $startTime, endTime: $endTime, reason: $reason, status: $status}';
  }
}
