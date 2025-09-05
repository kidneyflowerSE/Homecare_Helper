class Helper {
  String id;
  String? helperId;
  String? fullName;
  String? startDate;
  String? birthDay;
  String? phone;
  String? birthPlace;
  String? address;
  WorkingArea workingArea;
  String? jobDetail;
  List<String> jobs;
  num yearOfExperience;
  String? experienceDescription;
  String? avatar;
  List<String> healthCertificates;
  String? salaryId;
  String? gender;
  String? nationality;
  String? educationLevel;
  num height;
  num weight;
  String? status;
  String? workingStatus;

  Helper({
    required this.id,
    this.helperId,
    this.fullName,
    this.startDate,
    this.birthDay,
    this.phone,
    this.birthPlace,
    this.address,
    required this.workingArea,
    this.jobDetail,
    required this.jobs,
    required this.yearOfExperience,
    this.experienceDescription,
    this.avatar,
    required this.healthCertificates,
    this.salaryId,
    this.gender,
    this.nationality,
    this.educationLevel,
    required this.height,
    required this.weight,
    this.status,
    this.workingStatus,
  });

  factory Helper.fromJson(Map<String, dynamic> map) {
    try {
      return Helper(
        id: map['_id']?.toString() ?? '',
        helperId: map['helper_id']?.toString(),
        fullName: map['fullName']?.toString(),
        startDate: map['startDate']?.toString(),
        birthDay: map['birthDate']?.toString(),
        phone: map['phone']?.toString(),
        birthPlace: map['birthPlace']?.toString(),
        address: map['address']?.toString(),
        workingArea: map['workingArea'] != null && map['workingArea'] is Map<String, dynamic>
            ? WorkingArea.fromJson(map['workingArea'])
            : WorkingArea(province: '', districts: []),
        jobDetail: map['jobDetail']?.toString(),
        jobs: map['jobs'] != null && map['jobs'] is List
            ? List<String>.from(map['jobs'].map((item) => item.toString()))
            : [],
        yearOfExperience: map['yearOfExperience'] is num
            ? map['yearOfExperience']
            : (num.tryParse(map['yearOfExperience']?.toString() ?? '0') ?? 0),
        experienceDescription: map['experienceDescription']?.toString(),
        avatar: map['avatar']?.toString(),
        healthCertificates: map['healthCertificates'] != null && map['healthCertificates'] is List
            ? List<String>.from(map['healthCertificates'].map((item) => item.toString()))
            : [],
        salaryId: map['salaryId']?.toString(),
        gender: map['gender']?.toString(),
        nationality: map['nationality']?.toString(),
        educationLevel: map['educationLevel']?.toString(),
        height: map['height'] is num
            ? map['height']
            : (num.tryParse(map['height']?.toString() ?? '0') ?? 0),
        weight: map['weight'] is num
            ? map['weight']
            : (num.tryParse(map['weight']?.toString() ?? '0') ?? 0),
        status: map['status']?.toString(),
        workingStatus: map['workingStatus']?.toString(),
      );
    } catch (e) {
      print('Error parsing Helper from JSON: $e');
      print('Problematic JSON: $map');
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Helper &&
          runtimeType == other.runtimeType &&
          helperId == other.helperId &&
          fullName == other.fullName &&
          startDate == other.startDate &&
          birthDay == other.birthDay &&
          phone == other.phone &&
          birthPlace == other.birthPlace &&
          address == other.address &&
          workingArea == other.workingArea &&
          jobDetail == other.jobDetail &&
          jobs == other.jobs &&
          yearOfExperience == other.yearOfExperience &&
          experienceDescription == other.experienceDescription &&
          avatar == other.avatar &&
          healthCertificates == other.healthCertificates &&
          salaryId == other.salaryId &&
          gender == other.gender &&
          nationality == other.nationality &&
          educationLevel == other.educationLevel &&
          height == other.height &&
          weight == other.weight;

  @override
  int get hashCode =>
      helperId.hashCode ^
      fullName.hashCode ^
      startDate.hashCode ^
      birthDay.hashCode ^
      phone.hashCode ^
      birthPlace.hashCode ^
      address.hashCode ^
      workingArea.hashCode ^
      jobDetail.hashCode ^
      jobs.hashCode ^
      yearOfExperience.hashCode ^
      experienceDescription.hashCode ^
      avatar.hashCode ^
      healthCertificates.hashCode ^
      salaryId.hashCode ^
      gender.hashCode ^
      nationality.hashCode ^
      educationLevel.hashCode ^
      height.hashCode ^
      weight.hashCode;

  @override
  String toString() {
    return 'Cleaner{helperId: $helperId, fullName: $fullName, startDate: $startDate, birthDay: $birthDay, phone: $phone, birthPlace: $birthPlace, address: $address, workingArea: $workingArea, jobDetail: $jobDetail, jobs: $jobs, yearOfExperience: $yearOfExperience, experienceDescription: $experienceDescription, avatar: $avatar, healthCertificates: $healthCertificates, salaryId: $salaryId, gender: $gender, nationality: $nationality, educationLevel: $educationLevel, height: $height, weight: $weight}';
  }
}

class WorkingArea {
  late String province;
  late List<String> districts;

  WorkingArea({required this.province, required this.districts});

  factory WorkingArea.fromJson(Map<String, dynamic> map) {
    return WorkingArea(
      province: map['province'] ?? "Không có thông tin",
      districts: List<String>.from(map['districts'] ?? []),
    );
  }

  @override
  String toString() {
    return 'WorkingArea{province: $province, districts: $districts}';
  }
}
