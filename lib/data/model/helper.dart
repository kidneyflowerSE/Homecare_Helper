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

  Helper({
    required this.id,
    required this.helperId,
    required this.fullName,
    required this.startDate,
    required this.birthDay,
    required this.phone,
    required this.birthPlace,
    required this.address,
    required this.workingArea,
    required this.jobDetail,
    required this.jobs,
    required this.yearOfExperience,
    required this.experienceDescription,
    required this.avatar,
    required this.healthCertificates,
    required this.salaryId,
    required this.gender,
    required this.nationality,
    required this.educationLevel,
    required this.height,
    required this.weight,
  });

  factory Helper.fromJson(Map<String, dynamic> map) {
    return Helper(
      id: map['_id'],
      helperId: map['helper_id'],
      fullName: map['fullName'],
      startDate: map['startDate'],
      birthDay: map['birthDate'],
      phone: map['phone'],
      birthPlace: map['birthPlace'],
      address: map['address'],
      workingArea: WorkingArea.fromJson(map['workingArea']),
      jobDetail: map['jobDetail'],
      jobs: List<String>.from(map['jobs']),
      yearOfExperience: map['yearOfExperience'],
      experienceDescription: map['experienceDescription'],
      avatar: map['avatar'],
      healthCertificates: List<String>.from(map['healthCertificates']),
      salaryId: map['salaryId'],
      gender: map['gender'],
      nationality: map['nationality'],
      educationLevel: map['educationLevel'],
      height: map['height'].toDouble(), // Convert to double
      weight: map['weight'].toDouble(), // Convert to double
    );
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

// class CreatedBy {
//   String accountId;
//   DateTime dateTime;
//
//   CreatedBy({required this.accountId, DateTime? dateTime}) :
//       dateTime = dateTime ?? DateTime.now();
// }
//
// class UpdatedBy {
//   String accountId;
//   DateTime updateAt;
//
//   UpdatedBy({required this.accountId, DateTime? updateAt}) :
//       updateAt = updateAt ?? DateTime.now();
// }
//
// class DeletedBy {
//   String accountId;
//   DateTime deletedAt;
//
//   DeletedBy({required this.accountId, DateTime? deletedAt}) :
//       deletedAt = deletedAt ?? DateTime.now();
// }
