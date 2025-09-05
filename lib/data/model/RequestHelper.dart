import 'dart:convert';

class RequestHelper {
  String id;
  CustomerInfo customerInfo;
  Service service;
  String orderDate;
  List<String> scheduleIds;
  DateTime startTime;
  DateTime endTime;
  num totalCost;
  String status;
  List<Schedule> schedules;

  RequestHelper({
    required this.id,
    required this.customerInfo,
    required this.service,
    required this.orderDate,
    required this.scheduleIds,
    required this.startTime,
    required this.endTime,
    required this.totalCost,
    required this.status,
    required this.schedules,
  });

  factory RequestHelper.fromJson(Map<String, dynamic> json) {
    return RequestHelper(
      id: json['_id'] ?? '',
      customerInfo: json['customerInfo'] != null
          ? CustomerInfo.fromJson(json['customerInfo'])
          : CustomerInfo(fullName: '', phone: '', address: '', usedPoint: 0),
      service: json['service'] != null
          ? Service.fromJson(json['service'])
          : Service(title: '', coefficientService: 1.0, coefficientOther: 1.0, coefficientOt: 1.0, cost: 0),
      orderDate: json['orderDate'] ?? '',
      scheduleIds: json['scheduleIds'] != null
          ? List<String>.from(json['scheduleIds'])
          : [],
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now(),
      totalCost: json['totalCost'] ?? 0,
      status: json['status'] ?? '',
      schedules: json['schedules'] != null
          ? (json['schedules'] as List)
              .map((e) => e != null ? Schedule.fromJson(e) : null)
              .where((e) => e != null)
              .cast<Schedule>()
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customerInfo': customerInfo.toJson(),
      'service': service.toJson(),
      'orderDate': orderDate,
      'scheduleIds': scheduleIds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalCost': totalCost,
      'status': status,
      'schedules': schedules.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'RequestHelper{id: $id, customerInfo: $customerInfo, service: $service, orderDate: $orderDate, scheduleIds: $scheduleIds, startTime: $startTime, endTime: $endTime, totalCost: $totalCost, status: $status, schedules: $schedules}';
  }
}

class Service {
  String title;
  double coefficientService;
  double coefficientOther;
  double coefficientOt;
  num cost;

  Service({
    required this.title,
    required this.coefficientService,
    required this.coefficientOther,
    required this.coefficientOt,
    required this.cost,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      title: json['title'] ?? '',
      coefficientService: (json['coefficient_service'] ?? 1.0).toDouble(),
      coefficientOther: (json['coefficient_other'] ?? 1.0).toDouble(),
      coefficientOt: (json['coefficient_ot'] ?? 1.0).toDouble(),
      cost: json['cost'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'coefficient_service': coefficientService,
      'coefficient_other': coefficientOther,
      'coefficient_ot': coefficientOt,
      'cost': cost,
    };
  }

  @override
  String toString() {
    return 'Service{title: $title, coefficientService: $coefficientService, coefficientOther: $coefficientOther, coefficientOt: $coefficientOt, cost: $cost}';
  }
}

class CustomerInfo {
  String fullName;
  String phone;
  String address;
  num usedPoint;

  CustomerInfo({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.usedPoint,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      usedPoint: json['usedPoint'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'usedPoint': usedPoint,
    };
  }

  @override
  String toString() {
    return 'CustomerInfo{fullName: $fullName, phone: $phone, address: $address, usedPoint: $usedPoint}';
  }
}

class Schedule {
  String id;
  String workingDate;
  DateTime startTime;
  DateTime endTime;
  String helperId;
  num cost;
  String status;
  num helperCost;
  Comment comment;

  Schedule({
    required this.id,
    required this.workingDate,
    required this.startTime,
    required this.endTime,
    required this.helperId,
    required this.cost,
    required this.status,
    required this.helperCost,
    required this.comment,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['_id'] ?? '',
      workingDate: json['workingDate'] ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now(),
      helperId: json['helper_id'] ?? '',
      cost: json['cost'] ?? 0,
      status: json['status'] ?? '',
      helperCost: json['helper_cost'] ?? 0,
      comment: json['comment'] != null
          ? Comment.fromJson(json['comment'])
          : Comment(review: '', loseThings: false, breakThings: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'workingDate': workingDate,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'helper_id': helperId,
      'cost': cost,
      'status': status,
      'helper_cost': helperCost,
      'comment': comment.toJson(),
    };
  }

  @override
  String toString() {
    return 'Schedule{id: $id, workingDate: $workingDate, startTime: $startTime, endTime: $endTime, helperId: $helperId, cost: $cost, status: $status, helperCost: $helperCost, comment: $comment}';
  }
}

class Comment {
  String review;
  bool loseThings;
  bool breakThings;

  Comment({
    required this.review,
    required this.loseThings,
    required this.breakThings,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      review: json['review'] ?? '',
      loseThings: json['loseThings'] ?? false,
      breakThings: json['breakThings'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review': review,
      'loseThings': loseThings,
      'breakThings': breakThings,
    };
  }

  @override
  String toString() {
    return 'Comment{review: $review, loseThings: $loseThings, breakThings: $breakThings}';
  }
}
