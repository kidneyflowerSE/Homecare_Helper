class Requests {
  CustomerInfo customerInfo;
  RequestService service;
  RequestLocation location;
  String id;
  String oderDate;
  List<String> scheduleIds;
  String startTime;
  String endTime;
  String requestType;
  num totalCost;
  String status;
  bool deleted;
  Comment comment;
  num profit;
  String? helperId;
  String? startDate;

  Requests({
    required this.customerInfo,
    required this.service,
    required this.location,
    required this.id,
    required this.oderDate,
    required this.scheduleIds,
    required this.startTime,
    required this.endTime,
    required this.requestType,
    required this.totalCost,
    required this.status,
    required this.deleted,
    required this.comment,
    required this.profit,
    this.helperId,
    this.startDate,
  });

  factory Requests.fromJson(Map<String, dynamic> map) {
    return Requests(
      customerInfo:
          map['customerInfo'] != null
              ? CustomerInfo.fromJson(map['customerInfo'])
              : CustomerInfo(
                fullName: '',
                phone: '',
                address: '',
                usedPoint: 0,
              ),
      service:
          map['service'] != null
              ? RequestService.fromJson(map['service'])
              : RequestService(
                title: '',
                coefficientService: 0.0,
                coefficientOther: 0.0,
                cost: 0,
              ),
      // Provide a default or placeholder object
      location:
          map['location'] != null
              ? RequestLocation.fromJson(map['location'])
              : RequestLocation(province: '', district: '', ward: ''),
      id: map['_id'] ?? '',
      oderDate: map['orderDate'] ?? '',
      scheduleIds: List<String>.from(map['scheduleIds'] ?? []),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      requestType: map['requestType'] ?? '',
      totalCost: map['totalCost'] ?? 0,
      status: map['status'] ?? '',
      deleted: map['deleted'] ?? false,
      comment:
          map['comment'] != null
              ? Comment.fromJson(map['comment'])
              : Comment(review: '', loseThings: false, breakThings: false),
      // Default comment
      profit: map['profit'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerInfo': customerInfo.toJson(),
      'service': service.toJson(),
      'location': location.toJson(),
      '_id': id,
      'orderDate': oderDate,
      'scheduleIds': scheduleIds,
      'startTime': startTime,
      'endTime': endTime,
      'requestType': requestType,
      'totalCost': totalCost,
      'status': status,
      'deleted': deleted,
      'comment': comment.toJson(),
      'profit': profit,
      'helper_id': helperId,
      'startDate': startDate,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Requests &&
          runtimeType == other.runtimeType &&
          customerInfo == other.customerInfo &&
          service == other.service &&
          location == other.location &&
          id == other.id &&
          oderDate == other.oderDate &&
          scheduleIds == other.scheduleIds &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          requestType == other.requestType &&
          totalCost == other.totalCost &&
          status == other.status &&
          deleted == other.deleted &&
          comment == other.comment &&
          profit == other.profit;

  @override
  int get hashCode =>
      customerInfo.hashCode ^
      service.hashCode ^
      location.hashCode ^
      id.hashCode ^
      oderDate.hashCode ^
      scheduleIds.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      requestType.hashCode ^
      totalCost.hashCode ^
      status.hashCode ^
      deleted.hashCode ^
      comment.hashCode ^
      profit.hashCode;

  @override
  String toString() {
    return 'Requests{customerInfo: $customerInfo, service: $service, location: $location, id: $id, oderDate: $oderDate, scheduleIds: $scheduleIds, startTime: $startTime, endTime: $endTime, requestType: $requestType, totalCost: $totalCost, status: $status, deleted: $deleted, comment: $comment, profit: $profit, helperId: $helperId, startDate: $startDate}';
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

  factory Comment.fromJson(Map<String, dynamic> map) {
    return Comment(
      review: map['review'] ?? '',
      loseThings: map['loseThings'] ?? false,
      breakThings: map['breakThings'] ?? false,
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

class RequestLocation {
  String province;
  String district;
  String ward;

  RequestLocation({
    required this.province,
    required this.district,
    required this.ward,
  });

  factory RequestLocation.fromJson(Map<String, dynamic> map) {
    return RequestLocation(
      province: map['province'] ?? '',
      district: map['district'] ?? '',
      ward: map['ward'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'province': province, 'district': district, 'ward': ward};
  }

  @override
  String toString() {
    return 'RequestLocation{province: $province, district: $district, ward: $ward}';
  }
}

class RequestService {
  String title;
  num coefficientService;
  num coefficientOther;
  num cost;

  RequestService({
    required this.title,
    required this.coefficientService,
    required this.coefficientOther,
    required this.cost,
  });

  factory RequestService.fromJson(Map<String, dynamic> map) {
    return RequestService(
      title: map['title'] ?? '',
      coefficientService: map['coefficient_service'],
      coefficientOther: map['coefficient_other'],
      cost: map['cost'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'coefficient_service': coefficientService,
      'coefficient_other': coefficientOther,
      'cost': cost,
    };
  }

  @override
  String toString() {
    return 'RequestService{title: $title, coefficientService: $coefficientService, coefficientOther: $coefficientOther, cost: $cost}';
  }
}

class CustomerInfo {
  String fullName;
  String phone;
  String address;
  int? usedPoint;

  CustomerInfo({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.usedPoint,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> map) {
    return CustomerInfo(
      fullName: map['fullName'],
      phone: map['phone'],
      address: map['address'],
      usedPoint: map['usedPoint'],
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
