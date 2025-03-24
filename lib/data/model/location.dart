class Location {
  String name;
  List<District> districts;

  Location({
    required this.name,
    required this.districts,
  });

  // Hàm factory để ánh xạ từ JSON
  factory Location.fromJson(Map<String, dynamic> map) {
    return Location(
      name: map['Name'] ?? '',
      districts: (map['Districts'] as List<dynamic>)
          .map((districtJson) => District.fromJson(districtJson))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'Location{name: $name, districts: $districts}';
  }
}

class District {
  String name;
  String id;
  List<Ward> wards;

  District({
    required this.name,
    required this.id,
    required this.wards,
  });

  // Hàm factory để ánh xạ từ JSON
  factory District.fromJson(Map<String, dynamic> map) {
    return District(
      name: map['Name'] ?? '',
      id: map['_id'] ?? '',
      wards: (map['Wards'] as List<dynamic>)
          .map((wardJson) => Ward.fromJson(wardJson))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'District{name: $name, id: $id, wards: $wards}';
  }
}

class Ward {
  String name;
  String id;

  Ward({
    required this.name,
    required this.id,
  });

  // Hàm factory để ánh xạ từ JSON
  factory Ward.fromJson(Map<String, dynamic> map) {
    return Ward(
      name: map['Name'] ?? '',
      id: map['_id'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Ward{name: $name, id: $id}';
  }
}
