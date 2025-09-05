class Addresses {
  String province;
  String district;
  String ward;
  String? id;
  String detailedAddress;

  Addresses({
    required this.province,
    required this.district,
    required this.ward,
    this.id,
    required this.detailedAddress,
  });

  factory Addresses.fromJson(Map<String, dynamic> map) {
    return Addresses(
      province: map['province'] ?? '',
      district: map['district'] ?? '',
      id: map['_id'] ?? '',
      detailedAddress: map['detailAddress'] ?? '', ward: map['ward'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'province': province,
      'district': district,
      'ward': ward,
      '_id': id,
      'detailAddress': detailedAddress,
    };
  }

  @override
  String toString() {
    return '$detailedAddress, $ward, $district, $province';
  }
}