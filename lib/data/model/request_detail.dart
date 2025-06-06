class RequestDetail {
  String? id;
  String? workingDate;
  String? helperID;
  String? status;
  num? helperCost;

  RequestDetail({
    required this.id,
    required this.workingDate,
    required this.helperID,
    required this.status,
    required this.helperCost,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestDetail &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          workingDate == other.workingDate &&
          helperID == other.helperID &&
          status == other.status &&
          helperCost == other.helperCost;

  @override
  int get hashCode =>
      id.hashCode ^
      workingDate.hashCode ^
      helperID.hashCode ^
      status.hashCode ^
      helperCost.hashCode;

  factory RequestDetail.fromJson(Map<String, dynamic> map) {
    return RequestDetail(
      id: map['_id'],
      helperCost: map['helper_cost'] is double
          ? map['helper_cost'].toInt() // Convert double to int
          : map['helper_cost'], // Use as int if already int
      helperID: map['helper_id'],
      status: map['status'],
      workingDate: map['workingDate'],
    );
  }

  @override
  String toString() {
    return 'RequestDetail{id: $id, workingDate: $workingDate, helperID: $helperID, status: $status, helperCost: $helperCost}';
  }
}
